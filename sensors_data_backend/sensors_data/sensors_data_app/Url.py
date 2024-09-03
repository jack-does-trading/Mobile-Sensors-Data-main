from django.urls import path
from . import views

urlpatterns = [
    path('', views.get_data_func, name="get_data"),
    path('print_data', views.print_data, name="print_data"),
    
]