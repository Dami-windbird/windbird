from django.apps import AppConfig

class ToolConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'tool'  # 必须与目录名一致 