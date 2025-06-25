from django.urls import path, include

urlpatterns = [
    path('information/', include('tool.information.urls')),
] 