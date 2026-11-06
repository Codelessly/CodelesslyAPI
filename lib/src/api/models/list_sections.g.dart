// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_sections.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ListSectionsModelOmitDefaults(
  ListSectionsModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.groupBy, '')) json.remove('groupBy');
  if (isJsonDefault(instance.headerNodeId, '')) json.remove('headerNodeId');
  if (isJsonDefault(instance.sticky, true)) json.remove('sticky');
  if (isJsonDefault(instance.indexBar, false)) json.remove('indexBar');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListSectionsModel _$ListSectionsModelFromJson(Map json) => ListSectionsModel(
  groupBy: json['groupBy'] as String? ?? '',
  headerNodeId: json['headerNodeId'] as String? ?? '',
  sticky: json['sticky'] as bool? ?? true,
  indexBar: json['indexBar'] as bool? ?? false,
);

Map<String, dynamic> _$ListSectionsModelToJson(ListSectionsModel instance) =>
    <String, dynamic>{
      'groupBy': instance.groupBy,
      'headerNodeId': instance.headerNodeId,
      'sticky': instance.sticky,
      'indexBar': instance.indexBar,
    };
