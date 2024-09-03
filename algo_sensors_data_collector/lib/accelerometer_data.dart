class AccelerometerData {
  final DateTime date;
  final List<double> values;
  String activity_name;

  AccelerometerData(this.date, this.values, this.activity_name);

  Map<String, dynamic> toJson() {


    return {
      'date': date.toIso8601String(),
      'value': values,
      'activity_name':activity_name
    };
  }
}

