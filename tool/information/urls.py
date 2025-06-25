from django.urls import path
from .views import WeatherAPI, IPLocationAPI

urlpatterns = [
    path('weather', WeatherAPI.as_view()),
    path('ip', IPLocationAPI.as_view()),
] 