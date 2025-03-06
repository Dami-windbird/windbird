from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
import requests
import random
from tool import serializers
from tool.serializers import PoemSerializer, IPSerializer, WeatherSerializer
from django.conf import settings  # 添加在文件顶部
import json
import re
from windbird.utils.validators import validate_ipv4
from django.core.validators import EMPTY_VALUES

def filter_response_data(data):
    """过滤敏感字段"""
    allowed_keys = {'status', 'count', 'info', 'infocode', 'lives'}
    return {k: v for k, v in data.items() if k in allowed_keys and v not in EMPTY_VALUES}

class WeatherAPI(APIView):
    """
    获取城市天气信息
    
    参数：
    - city (可选): 要查询的城市名称或adcode，默认使用北京
    
    示例：
    GET /api/tool/weather/?city=110000
    """
    def get(self, request):
        city = request.query_params.get('city', '110000')
        api_url = f"https://restapi.amap.com/v3/weather/weatherInfo?city={city}&key={settings.AMAP_API_KEY}"
        
        try:
            response = requests.get(api_url, timeout=5)
            response.raise_for_status()
            data = response.json()
            
            # 仅验证不修改数据结构
            serializer = WeatherSerializer(data=data)
            serializer.is_valid(raise_exception=True)
            
            # 返回原始API响应
            return Response(filter_response_data(data))
            
        except requests.exceptions.RequestException as e:
            return Response({"error": f"API请求失败: {str(e)}"}, status=503)
        except json.JSONDecodeError:
            return Response({"error": "无效的API响应"}, status=500)

class IPLocationAPI(APIView):
    """
    获取IP地理位置信息
    
    参数：
    - ip (可选): 要查询的IP地址，默认使用客户端IP
    
    示例：
    GET /api/tool/ip/
    """
    def get(self, request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR', '')
        ip = x_forwarded_for.split(',')[0] if x_forwarded_for else request.META.get('REMOTE_ADDR')
        
        try:
            validate_ipv4(ip)  # 使用通用验证器
        except serializers.ValidationError as e:
            return Response({"error": e.detail}, status=400)
        
        # 请求高德API
        api_url = f"https://restapi.amap.com/v3/ip?ip={ip}&key={settings.AMAP_API_KEY}"
        print(api_url)
        try:
            response = requests.get(api_url, timeout=5)
            response.raise_for_status()  # 检查HTTP错误
            data = response.json()
            
            # 处理高德API响应
            if data.get('status') == '1':
                serializer = IPSerializer(data=data)
                serializer.is_valid(raise_exception=True)
                return Response(serializer.data)
            else:
                return Response({"error": data.get('info')}, status=400)
                
        except requests.exceptions.RequestException as e:
            return Response({"error": f"API请求失败: {str(e)}"}, status=503)
        except json.JSONDecodeError:
            return Response({"error": "无效的API响应"}, status=500) 