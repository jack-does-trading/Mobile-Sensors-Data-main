class location_data{
  final double lat;
  final double long;
  final String activity_name;
  final DateTime date;

  location_data(this.lat,this.long, this.activity_name,this.date);

  Map<String, dynamic> toJson(){
    return {
      'lat': lat,
      'long': long,
      'activity_name':activity_name,
      'date':date.toIso8601String(),
    };
  }
}