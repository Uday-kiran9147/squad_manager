import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    } else {
      throw ArgumentError('Expected Timestamp or String, got ${json.runtimeType}');
    }
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}