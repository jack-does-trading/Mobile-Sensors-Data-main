from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
import csv
import os
from datetime import datetime

def get_data_func(request):
    return HttpResponse("Hey")

def tanu(request):
    return HttpResponse("")


 
def print_data(request):
    body_unicode = request.body.decode('utf-8')
    body_data = json.loads(body_unicode)

    gyro = body_data.get('gyro')
    acc = body_data.get('acc')
    gyro_turning=body_data.get('gyro_turning')
    acc_turning=body_data.get('acc_turning')

    location=body_data.get('location')
    start_time=body_data.get('start_time')
    energy_consumption=body_data.get('energy_consumption')
    battery_percentage=body_data.get('battery_percentage')

    gyro_file_name = body_data.get('fname') + "_gyro"
    acc_file_name = body_data.get('fname') + "_acc"
    gps_file_name=body_data.get('fname')+"_location"
    bandwidth_energy=body_data.get('fname')+"energy_bandwidth"
    gyro_turning_file_name = body_data.get('fname') + "_gyro_turning"
    acc_turning_file_name = body_data.get('fname') + "_acc_turning"

    save_csv(acc, 'acc', acc_file_name)
    save_csv(gyro, 'gyro', gyro_file_name)
    save_location_csv(location, gps_file_name)
    save_csv(acc_turning, 'acc_turning', acc_turning_file_name)
    save_csv(gyro_turning, 'gyro_turning', gyro_turning_file_name)


    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    content_length = int(request.META.get('CONTENT_LENGTH', 0))
    calculate_bandwidth(start_time,content_length,energy_consumption,bandwidth_energy,battery_percentage)
    return JsonResponse(current_time,safe=False)


def save_csv(data, sensor_name, file_name):
    folder_path = "Data_File"
    os.makedirs(folder_path, exist_ok=True)

    file_path = os.path.join(folder_path, f"{file_name}.csv")

    file_exists = os.path.isfile(file_path)

    mode = 'a' if file_exists else 'w'

    with open(file_path, mode, newline='') as csvfile:
        writer = csv.writer(csvfile)

        if not file_exists:
            writer.writerow(['sensor_name', 'date', 'value', 'activity_name'])

        for item in data:
            writer.writerow([sensor_name, item['date'], item['value'], item['activity_name']])

def save_location_csv(data, file_name):
    folder_path = "Data_File"
    os.makedirs(folder_path, exist_ok=True)

    file_path = os.path.join(folder_path, f"{file_name}.csv")

    file_exists = os.path.isfile(file_path)

    mode = 'a' if file_exists else 'w'

    with open(file_path, mode, newline='') as csvfile:
        writer = csv.writer(csvfile)

        if not file_exists:
            writer.writerow(['date', 'lat', 'long', 'activity_name'])

        for item in data:
            writer.writerow([item['date'], item['lat'], item['long'], item['activity_name']])



def calculate_bandwidth(start_time, content_length, energy, file_name,percentage):
    start_time = datetime.fromisoformat(start_time)
    current_time = datetime.now()
    time_difference = (current_time - start_time).total_seconds()
    bandwidth_mbps = (content_length * 8) / (time_difference * 1000000)

    folder_path = "Data_File"
    os.makedirs(folder_path, exist_ok=True)

    file_path = os.path.join(folder_path, f"{file_name}.csv")

    file_exists = os.path.isfile(file_path)

    mode = 'a' if file_exists else 'w'

    with open(file_path, mode, newline='') as csvfile:
        writer = csv.writer(csvfile)

        if not file_exists:
            writer.writerow(['bandwidth', 'energy','Battery Percentage'])

        writer.writerow([bandwidth_mbps, energy, percentage])

    print(f'Bandwidth: {bandwidth_mbps} Mbps          Energy: {energy}              Percentage:{percentage}')

   

    



