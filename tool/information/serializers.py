from rest_framework import serializers
from windbird.utils.validators import validate_ipv4

class PoemSerializer(serializers.Serializer):
    title = serializers.CharField()  # 标题字段
    content = serializers.CharField()  # 内容字段 

class IPSerializer(serializers.Serializer):
    ip = serializers.CharField(
        required=False,
        validators=[validate_ipv4],
        help_text="IPv4地址，格式：xxx.xxx.xxx.xxx"
    )
    status = serializers.CharField()
    province = serializers.CharField(required=False)
    city = serializers.CharField(required=False)
    adcode = serializers.CharField(required=False)
    city_id = serializers.SerializerMethodField()
    rectangle = serializers.CharField(required=False)
    info = serializers.CharField(required=False)
    infocode = serializers.CharField(required=False)

    def get_city_id(self, obj):
        return obj.get('adcode')

class WeatherSerializer(serializers.Serializer):
    status = serializers.CharField()
    count = serializers.CharField()
    info = serializers.CharField()
    infocode = serializers.CharField()
    lives = serializers.ListField(
        child=serializers.DictField(
            child=serializers.CharField(),
            allow_empty=True
        )
    ) 