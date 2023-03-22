// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_component.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomComponent _$CustomComponentFromJson(Map json) => CustomComponent(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      data: ComponentData.fromJson(
          Map<String, dynamic>.from(json['data'] as Map)),
      createdAt: jsonToDate(json['createdAt'] as int?),
      previewUrl: json['previewUrl'] as String?,
      blurhash: json['blurhash'] as String? ?? '',
    );

Map<String, dynamic> _$CustomComponentToJson(CustomComponent instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'data': instance.data.toJson(),
    'createdAt': dateToJson(instance.createdAt),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('previewUrl', instance.previewUrl);
  val['blurhash'] = instance.blurhash;
  return val;
}

ComponentData _$ComponentDataFromJson(Map json) => ComponentData(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      nodes: Map<String, dynamic>.from(json['nodes'] as Map),
    );

Map<String, dynamic> _$ComponentDataToJson(ComponentData instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'nodes': instance.nodes,
    };
