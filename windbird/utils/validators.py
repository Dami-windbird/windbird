import re
from rest_framework import serializers

def validate_ipv4(value):
    """
    验证IPv4地址格式
    有效示例：192.168.0.1
    无效示例：256.0.0.1
    """
    pattern = r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    if not re.fullmatch(pattern, value):
        raise serializers.ValidationError("无效的IPv4地址格式")
    return value 