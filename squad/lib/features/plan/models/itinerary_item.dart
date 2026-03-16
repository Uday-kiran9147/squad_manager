import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/converters.dart';

part 'itinerary_item.freezed.dart';
part 'itinerary_item.g.dart';

@freezed
class ItineraryItem with _$ItineraryItem {
  const factory ItineraryItem({
    required String itemId,
    required String title,
    String? description,
    @TimestampConverter() required DateTime time,
    String? location,
    @Default(false) bool isCompleted,
  }) = _ItineraryItem;

  factory ItineraryItem.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemFromJson(json);
}
