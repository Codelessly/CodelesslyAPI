import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'modal_node.g.dart';

/// BASIC Modal's trigger and content are distinct children in the scene tree.
/// Presentation is initiated by the trigger's ShowDialogAction; this node does
/// not introduce a second action or change host-only transaction semantics.
@FlutterNode('CodelesslyModal', family: 'codelessly', nodeType: 'modal')
@JsonSerializable()
class ModalNode extends SceneNode with ChildrenMixin {
  @override
  final String type = 'modal';

  /// ID of the opening child.
  @FlutterProp(
    'trigger',
    type: 'string',
    group: 'Content',
    control: 'child',
    required: true,
    flutterParam: false,
    note: 'Scene child ID of the control that opens the modal.',
  )
  final String trigger;

  /// ID of the modal body child.
  @FlutterProp(
    'content',
    type: 'string',
    group: 'Content',
    control: 'child',
    required: true,
    flutterParam: false,
    note: 'Scene child ID of the modal body.',
  )
  final String content;

  /// Creates a modal with two ordered child references.
  ModalNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required this.trigger,
    required this.content,
    super.parentID,
    super.reactions,
    super.variables,
  }) {
    if (trigger.trim().isEmpty ||
        content.trim().isEmpty ||
        trigger != trigger.trim() ||
        content != content.trim() ||
        trigger == content ||
        trigger == id ||
        content == id) {
      throw ArgumentError(
        'Modal trigger and content must be distinct, nonempty child IDs.',
      );
    }
    setChildrenMixin(children: [trigger, content]);
  }

  /// Decodes a modal, refusing malformed or inconsistent child references.
  factory ModalNode.fromJson(Map json) {
    if (json['type'] != 'modal' ||
        json['trigger'] is! String ||
        json['content'] is! String ||
        json['children'] is! List ||
        (json['children'] as List).length != 2 ||
        json['children'][0] != json['trigger'] ||
        json['children'][1] != json['content']) {
      throw ArgumentError('Invalid Modal wire child references.');
    }
    return _$ModalNodeFromJson({
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
    if (children.length != 2 ||
        children[0] != trigger ||
        children[1] != content) {
      throw StateError('Modal children no longer match trigger and content.');
    }
    return _$ModalNodeOmitDefaults(this, _$ModalNodeToJson(this));
  }
}
