// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropdown_menu_style.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$DropdownMenuStyleModelOmitDefaults(
  DropdownMenuStyleModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.offset, 6)) json.remove('offset');
  if (isJsonDefault(instance.maxHeight, 320)) json.remove('maxHeight');
  if (isJsonDefault(instance.minWidth, 0)) json.remove('minWidth');
  if (isJsonDefault(instance.itemHeight, 40)) json.remove('itemHeight');
  if (isJsonDefault(instance.showCheck, false)) json.remove('showCheck');
  if (isJsonDefault(instance.checkSize, 18)) json.remove('checkSize');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DropdownMenuStyleModel _$DropdownMenuStyleModelFromJson(Map json) =>
    DropdownMenuStyleModel(
      color: json['color'] == null ? null : ColorRGBA.fromJson(json['color']),
      border: json['border'] == null
          ? null
          : BorderSideModel.fromJson(json['border'] as Map),
      radius: (json['radius'] as num?)?.toDouble(),
      shadows: (json['shadows'] as List<dynamic>?)
          ?.map((e) => Effect.fromJson(e as Map))
          .toList(),
      offset: (json['offset'] as num?)?.toDouble() ?? 6,
      maxHeight: (json['maxHeight'] as num?)?.toDouble() ?? 320,
      minWidth: (json['minWidth'] as num?)?.toDouble() ?? 0,
      padding: json['padding'] == null
          ? null
          : EdgeInsetsModel.fromJson(json['padding']),
      itemPadding: json['itemPadding'] == null
          ? null
          : EdgeInsetsModel.fromJson(json['itemPadding']),
      itemHeight: (json['itemHeight'] as num?)?.toDouble() ?? 40,
      selectedItemColor: json['selectedItemColor'] == null
          ? null
          : ColorRGBA.fromJson(json['selectedItemColor']),
      hoverItemColor: json['hoverItemColor'] == null
          ? null
          : ColorRGBA.fromJson(json['hoverItemColor']),
      selectedTextStyle: json['selectedTextStyle'] == null
          ? null
          : TextStyleModel.fromJson(json['selectedTextStyle'] as Map),
      showCheck: json['showCheck'] as bool? ?? false,
      checkColor: json['checkColor'] == null
          ? null
          : ColorRGBA.fromJson(json['checkColor']),
      checkSize: (json['checkSize'] as num?)?.toDouble() ?? 18,
    );

Map<String, dynamic> _$DropdownMenuStyleModelToJson(
  DropdownMenuStyleModel instance,
) => <String, dynamic>{
  'color': ?instance.color?.toJson(),
  'border': ?instance.border?.toJson(),
  'radius': ?instance.radius,
  'shadows': ?instance.shadows?.map((e) => e.toJson()).toList(),
  'offset': instance.offset,
  'maxHeight': instance.maxHeight,
  'minWidth': instance.minWidth,
  'padding': ?instance.padding?.toJson(),
  'itemPadding': ?instance.itemPadding?.toJson(),
  'itemHeight': instance.itemHeight,
  'selectedItemColor': ?instance.selectedItemColor?.toJson(),
  'hoverItemColor': ?instance.hoverItemColor?.toJson(),
  'selectedTextStyle': ?instance.selectedTextStyle?.toJson(),
  'showCheck': instance.showCheck,
  'checkColor': ?instance.checkColor?.toJson(),
  'checkSize': instance.checkSize,
};
