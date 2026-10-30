import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'tabs_node.g.dart';

/// A titled scene child in a Tabs node.
@JsonSerializable()
class TabsItem {
  /// Static tab label; dynamic title bindings are not supported.
  final String title;

  /// Scene node ID displayed by this tab.
  final String child;

  /// Creates a tab with a static label and child reference.
  const TabsItem({required this.title, required this.child});

  /// Decodes a tab.
  factory TabsItem.fromJson(Map json) => _$TabsItemFromJson(json);

  /// Encodes a tab.
  Map<String, dynamic> toJson() => _$TabsItemToJson(this);
}

/// BASIC Tabs container, distinct from the TabBar control.
@FlutterNode('CodelesslyTabs', family: 'codelessly', nodeType: 'tabs')
@JsonSerializable()
class TabsNode extends SceneNode with ChildrenMixin {
  @override
  final String type = 'tabs';

  /// Ordered tabs, each pointing to one scene child.
  @FlutterProp(
    'tabs',
    type: 'array',
    group: 'Content',
    control: 'children',
    required: true,
    flutterParam: false,
    note: 'Ordered static titles and scene child IDs.',
  )
  final List<TabsItem> tabs;

  /// Creates a tab container with at least one tab.
  TabsNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required List<TabsItem> tabs,
    super.parentID,
    super.reactions,
    super.variables,
  }) : tabs = List.unmodifiable(tabs) {
    if (tabs.isEmpty ||
        tabs.any(
          (tab) =>
              tab.title.trim().isEmpty ||
              tab.child.trim().isEmpty ||
              tab.child != tab.child.trim() ||
              tab.child == id,
        ) ||
        tabs.map((tab) => tab.child).toSet().length != tabs.length) {
      throw ArgumentError(
        'Tabs require one or more distinct, nonempty scene children.',
      );
    }
    setChildrenMixin(children: tabs.map((tab) => tab.child).toList());
  }

  /// Decodes a typed tab payload and verifies its ordered children projection.
  factory TabsNode.fromJson(Map json) {
    final items = json['tabs'];
    if (json['type'] != 'tabs' ||
        items is! List ||
        items.isEmpty ||
        items.any(
          (item) =>
              item is! Map ||
              item['title'] is! String ||
              item['child'] is! String,
        ) ||
        json['children'] is! List ||
        (json['children'] as List).length != items.length ||
        !List.generate(
          items.length,
          (i) => json['children'][i] == items[i]['child'],
        ).every((matches) => matches)) {
      throw ArgumentError('Invalid Tabs wire child references.');
    }
    return _$TabsNodeFromJson({
      'visible': true,
      'enabled': true,
      'edgePins': EdgePinsModel.standard.toJson(),
      'positioningMode': PositioningMode.align.name,
      'horizontalFit': SizeFit.fixed.name,
      'verticalFit': SizeFit.fixed.name,
      'flex': 1,
      'aspectRatioLock': false,
      ...json,
    });
  }

  @override
  Map toJson() {
    if (children.length != tabs.length ||
        List.generate(
          tabs.length,
          (i) => children[i] == tabs[i].child,
        ).any((matches) => !matches)) {
      throw StateError('Tabs children no longer match ordered tabs.');
    }
    return _$TabsNodeOmitDefaults(this, _$TabsNodeToJson(this));
  }
}
