// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$PaginationModelOmitDefaults(
  PaginationModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.mode, PaginationMode.infinite))
    json.remove('mode');
  if (isJsonDefault(instance.source, PaginationSource.data))
    json.remove('source');
  if (isJsonDefault(instance.pageSize, 20)) json.remove('pageSize');
  if (isJsonDefault(instance.pageSizeOptions, const [10, 20, 50, 100]))
    json.remove('pageSizeOptions');
  if (isJsonDefault(instance.strategy, PaginationStrategy.offset))
    json.remove('strategy');
  if (isJsonDefault(instance.keyPath, 'id')) json.remove('keyPath');
  if (isJsonDefault(instance.initialPage, 1)) json.remove('initialPage');
  if (isJsonDefault(instance.thresholdItems, 5)) json.remove('thresholdItems');
  if (isJsonDefault(instance.thresholdPixels, 0))
    json.remove('thresholdPixels');
  if (isJsonDefault(instance.cachePages, true)) json.remove('cachePages');
  if (isJsonDefault(instance.parameters, const {})) json.remove('parameters');
  if (isJsonDefault(instance.itemsPath, '')) json.remove('itemsPath');
  if (isJsonDefault(instance.totalPath, '')) json.remove('totalPath');
  if (isJsonDefault(instance.cursorPath, '')) json.remove('cursorPath');
  if (isJsonDefault(instance.pullToRefresh, false))
    json.remove('pullToRefresh');
  if (isJsonDefault(instance.refreshDisplacement, 40))
    json.remove('refreshDisplacement');
  if (isJsonDefault(instance.loadingNodeId, '')) json.remove('loadingNodeId');
  if (isJsonDefault(instance.errorNodeId, '')) json.remove('errorNodeId');
  if (isJsonDefault(instance.endNodeId, '')) json.remove('endNodeId');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationModel _$PaginationModelFromJson(Map json) => PaginationModel(
  name: json['name'] as String,
  mode:
      $enumDecodeNullable(
        _$PaginationModeEnumMap,
        json['mode'],
        unknownValue: PaginationMode.infinite,
      ) ??
      PaginationMode.infinite,
  source:
      $enumDecodeNullable(
        _$PaginationSourceEnumMap,
        json['source'],
        unknownValue: PaginationSource.data,
      ) ??
      PaginationSource.data,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
  pageSizeOptions:
      (json['pageSizeOptions'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [10, 20, 50, 100],
  strategy:
      $enumDecodeNullable(
        _$PaginationStrategyEnumMap,
        json['strategy'],
        unknownValue: PaginationStrategy.offset,
      ) ??
      PaginationStrategy.offset,
  keyPath: json['keyPath'] as String? ?? 'id',
  initialPage: (json['initialPage'] as num?)?.toInt() ?? 1,
  thresholdItems: (json['thresholdItems'] as num?)?.toInt() ?? 5,
  thresholdPixels: (json['thresholdPixels'] as num?)?.toDouble() ?? 0,
  cachePages: json['cachePages'] as bool? ?? true,
  apiId: json['apiId'] as String?,
  parameters:
      (json['parameters'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ) ??
      const {},
  itemsPath: json['itemsPath'] as String? ?? '',
  totalPath: json['totalPath'] as String? ?? '',
  cursorPath: json['cursorPath'] as String? ?? '',
  pullToRefresh: json['pullToRefresh'] as bool? ?? false,
  refreshColor: json['refreshColor'] == null
      ? null
      : ColorRGBA.fromJson(json['refreshColor']),
  refreshBackgroundColor: json['refreshBackgroundColor'] == null
      ? null
      : ColorRGBA.fromJson(json['refreshBackgroundColor']),
  refreshDisplacement: (json['refreshDisplacement'] as num?)?.toDouble() ?? 40,
  loadingNodeId: json['loadingNodeId'] as String? ?? '',
  errorNodeId: json['errorNodeId'] as String? ?? '',
  endNodeId: json['endNodeId'] as String? ?? '',
);

Map<String, dynamic> _$PaginationModelToJson(PaginationModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': _$PaginationModeEnumMap[instance.mode]!,
      'source': _$PaginationSourceEnumMap[instance.source]!,
      'pageSize': instance.pageSize,
      'pageSizeOptions': instance.pageSizeOptions,
      'strategy': _$PaginationStrategyEnumMap[instance.strategy]!,
      'keyPath': instance.keyPath,
      'initialPage': instance.initialPage,
      'thresholdItems': instance.thresholdItems,
      'thresholdPixels': instance.thresholdPixels,
      'cachePages': instance.cachePages,
      'apiId': ?instance.apiId,
      'parameters': instance.parameters,
      'itemsPath': instance.itemsPath,
      'totalPath': instance.totalPath,
      'cursorPath': instance.cursorPath,
      'pullToRefresh': instance.pullToRefresh,
      'refreshColor': ?instance.refreshColor?.toJson(),
      'refreshBackgroundColor': ?instance.refreshBackgroundColor?.toJson(),
      'refreshDisplacement': instance.refreshDisplacement,
      'loadingNodeId': instance.loadingNodeId,
      'errorNodeId': instance.errorNodeId,
      'endNodeId': instance.endNodeId,
    };

const _$PaginationModeEnumMap = {
  PaginationMode.pages: 'pages',
  PaginationMode.infinite: 'infinite',
  PaginationMode.bidirectional: 'bidirectional',
};

const _$PaginationSourceEnumMap = {
  PaginationSource.data: 'data',
  PaginationSource.cloud: 'cloud',
  PaginationSource.api: 'api',
};

const _$PaginationStrategyEnumMap = {
  PaginationStrategy.offset: 'offset',
  PaginationStrategy.page: 'page',
  PaginationStrategy.cursor: 'cursor',
};
