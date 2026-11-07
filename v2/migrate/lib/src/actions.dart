// v1 reactions (`BaseNode.reactions`, an icon's or a navigation item's
// `reactions`, a condition's other actions) → v2 reactions and actions
// (API v2 `Reaction`, `ActionDef`; DESIGN.md §5.2). Read with v1's own
// decoders; written as plain v2 JSON. Every v1 action type and trigger
// has a v2 form: nothing is dropped. An entry v1 can't decode keeps its
// JSON (it decodes as an unknown action) and is reported.
import 'package:codelessly_api/codelessly_api.dart';

import 'behaviours.dart' show migrateMotion;
import 'bindings.dart';
import 'logic.dart';
import 'migrate.dart';

/// Migrates actions with the layout's v1 [nodes] (a set value's property
/// names become the target node's binding paths) and a [report].
class ActionMigration {
  ActionMigration({this.nodes = const {}, MigrationReport? report}) : report = report ?? MigrationReport();

  final Map<String, BaseNode> nodes;
  final MigrationReport report;

  /// v1 reactions (JSON, or decoded) → v2 reactions. One v2 reaction per v1
  /// reaction: its trigger and a chain of its one action.
  List<Json> reactions(Object? v1) => [
    if (v1 is List)
      for (final r in v1)
        if (reaction(r) case final Json j) j,
  ];

  Json? reaction(Object? v1) {
    final Reaction r;
    try {
      r = v1 is Reaction ? v1 : Reaction.fromJson(v1 as Map);
    } catch (error) {
      report.undecodable['reaction ${v1 is Map ? v1['id'] : ''}'] = '$error';
      return null;
    }
    return {
      if (r.id.isNotEmpty) 'id': r.id,
      if (r.name.isNotEmpty && r.name != 'Action') 'name': r.name,
      'trigger': trigger(r.trigger),
      'actions': [action(r.action)],
    };
  }

  /// A v1 trigger. `interval` is a `timer`, `keyPress` a `keyDown`, the
  /// hold `duration` is `holdMs`.
  Json trigger(TriggerModel t) {
    final type = switch (t.type) {
      TriggerType.interval => 'timer',
      TriggerType.keyPress => 'keyDown',
      final x => x.name,
    };
    final interval = switch (t.type) {
      TriggerType.interval => t.effectiveIntervalMillis,
      TriggerType.timer => t.effectiveIntervalMs,
      _ => null,
    };
    return {
      'type': type,
      if (t.debounceMs != 0) 'debounceMs': t.debounceMs,
      if ((t.variable ?? '').isNotEmpty) 'variable': t.variable,
      if (interval != null && interval != 1000) 'intervalMs': interval,
      if ((t.key ?? '').isNotEmpty) 'key': t.key,
      if ((t.when ?? '').isNotEmpty) 'when': t.when,
      if (t.type == TriggerType.hold && t.duration != kDefaultHoldDuration) 'holdMs': t.duration,
      if (t.type == TriggerType.clock) ...{
        if ((t.every ?? '').isNotEmpty) 'every': t.every,
        if ((t.runWhen ?? '').isNotEmpty) 'runWhen': t.runWhen,
        if (t.lookaheadMs != 100) 'lookaheadMs': t.lookaheadMs,
      },
      if (TriggerType.viewport.contains(t.type) && t.visibleFraction != kDefaultVisibleFraction)
        'visibleFraction': roundNum(t.visibleFraction),
    };
  }

  List<Json> actions(Iterable<ActionModel> list) => [for (final a in list) action(a)];

  /// A v1 action as v2 JSON.
  Json action(ActionModel a) {
    final out = _action(a);
    return {...out, if (!a.enabled) 'enabled': false, if (a.nonBlocking) 'nonBlocking': true};
  }

  /// A decoded-or-not v1 action (JSON from a condition or an icon).
  Json actionJson(Map json) {
    try {
      return action(ActionModel.fromJson(json));
    } catch (error) {
      report.undecodable['action ${json['type']}'] = '$error';
      return {...json.cast<String, Object?>(), 'type': '${json['type'] ?? 'unknown'}'};
    }
  }

  Json _action(ActionModel a) => switch (a) {
    NavigationAction() => {
      'type': 'navigate',
      if (a.navigationType != NavigationType.push) 'mode': a.navigationType.name,
      if (a.destinationId.isNotEmpty) 'to': a.destinationId,
      if (a.params.isNotEmpty) 'params': a.params,
      if ((a.baseDestinationId ?? '').isNotEmpty) 'base': a.baseDestinationId,
      if ((a.baseParams ?? const {}).isNotEmpty) 'baseParams': a.baseParams,
      if (a.transition != PageTransition.platform) 'transition': a.transition.name,
      'transitionMs': ?a.transitionMs,
      'reverseTransitionMs': ?a.reverseTransitionMs,
      'routeTransition': ?a.routeTransition?.let(routeTransition),
    },
    ShowDialogAction() => {
      'type': 'openModal',
      'to': a.destinationId,
      if (a.params.isNotEmpty) 'params': a.params,
      if (a.presentation != DialogPresentation.dialog) 'presentation': a.presentation.name,
      if (!a.barrierDismissible) 'barrierDismissible': false,
      if (a.barrierColor case final ColorRGBA c when c != ColorRGBA.black54) 'barrierColor': V1Node.rgba(c),
      if (a.barrierBlur != 0) 'barrierBlur': roundNum(a.barrierBlur),
      if (a.showCloseButton) 'showCloseButton': true,
      if (a.showDragHandle) 'showDragHandle': true,
      if (a.alignment.data case final AlignmentData d when d.x != 0 || d.y != 0)
        'alignment': [roundNum(d.x), roundNum(d.y)],
      if (a.anchor != DialogAnchor.none) 'anchor': a.anchor.name,
      if (a.placement != DialogPlacement.belowStart) 'placement': a.placement.name,
      if (a.anchorGap != 4) 'anchorGap': roundNum(a.anchorGap),
      if (a.anchorOffset != 0) 'anchorOffset': roundNum(a.anchorOffset),
      if (_insets(a.insets) case final List<num> i when i.any((v) => v != 0)) 'insets': i,
      if (a.sheetWidth case final double w) 'sheetWidth': roundNum(w),
      if (a.sheetBelowWidth != 600) 'sheetBelowWidth': roundNum(a.sheetBelowWidth),
      if (a.maxHeightFactor != 1) 'maxHeightFactor': roundNum(a.maxHeightFactor),
      if (a.fullHeight) 'fullHeight': true,
      if (a.enterScale != 1) 'enterScale': roundNum(a.enterScale),
      'routeTransition': ?a.routeTransition?.let(routeTransition),
    },
    CloseModalAction() => {'type': 'closeModal', if (a.params.isNotEmpty) 'result': a.params},
    LinkAction() => {'type': 'openLink', 'url': a.url},
    MailchimpSubmitAction() => {
      'type': 'submitForm',
      'service': 'mailchimp',
      'emailField': a.primaryTextField,
      if (a.apiKey.isNotEmpty) 'apiKey': a.apiKey,
      if (a.dataCenter.isNotEmpty) 'dataCenter': a.dataCenter,
      if (a.listID.isNotEmpty) 'listId': a.listID,
      if (a.firstNameField.isNotEmpty) 'firstNameField': a.firstNameField,
      if (a.lastNameField.isNotEmpty) 'lastNameField': a.lastNameField,
    },
    SubmitAction() => {
      'type': 'submitForm',
      'service': a.service.name,
      'emailField': a.primaryTextField,
      if (a.apiKey.isNotEmpty) 'apiKey': a.apiKey,
    },
    SetValueAction() => {
      'type': 'setValue',
      'node': a.nodeID,
      'values': [for (final v in a.values) _nodeValue(a.nodeID, v)],
    },
    SetVariantAction() => {'type': 'setVariant', 'node': a.nodeID, 'variant': a.variantID},
    SetVariableAction() => {
      'type': 'setVariable',
      'variable': a.variable.name,
      ..._write(a.variable.type, a),
      if (a.animateMs.trim().isNotEmpty && a.animateMs.trim() != '0') 'animateMs': a.animateMs,
      if (a.curve != MotionCurve.linear) 'curve': a.curve.name,
    },
    CallFunctionAction() => {'type': 'callFunction', 'name': a.name, if (a.params.isNotEmpty) 'params': a.params},
    ApiCallAction() => {
      'type': 'callApi',
      'api': a.apiId ?? '',
      if (a.parameters.isNotEmpty) 'params': a.parameters,
      if (a.onSuccess.isNotEmpty) 'onSuccess': actions(a.onSuccess),
      if (a.onError.isNotEmpty) 'onError': actions(a.onError),
    },
    SetStorageAction() => {
      'type': 'setStorage',
      if (a.operation != StorageOperation.addOrUpdate)
        'operation': a.operation == StorageOperation.remove ? 'remove' : 'clear',
      if (a.operation != StorageOperation.clear) 'key': a.key,
      if (a.operation == StorageOperation.addOrUpdate) ...{
        if (a.variableType != VariableType.text) 'valueType': a.variableType.name,
        ..._write(a.variableType, a),
        if (a.skipIfAlreadyExists) 'skipIfExists': true,
      },
    },
    SetCloudStorageAction() => _cloudDocuments(a.subAction),
    LoadFromCloudStorageAction() => {
      'type': 'loadCloudData',
      'variable': a.variable?.name ?? '',
      if (!a.loadSingleDocument) 'single': false,
      if (a.documentId.isNotEmpty) 'id': a.documentId,
      'query': {
        'enabled': a.useCloudDatabase,
        'collectionPath': a.path,
        if (a.whereFilters.isNotEmpty) 'whereFilters': [for (final w in a.whereFilters) w.toJson()],
        if (a.orderByFilters.isNotEmpty) 'orderByFilters': [for (final o in a.orderByFilters) o.toJson()],
        if ((a.limit ?? 0) > 0) 'limit': a.limit,
        if (a.paging != QueryPaging.scroll) 'paging': a.paging.name,
        if (a.loadRelated.isNotEmpty) 'loadRelated': a.loadRelated,
      },
    },
    AuthAction() => {
      'type': 'auth',
      'operation': a.operation.name,
      if (a.email.isNotEmpty) 'email': a.email,
      if (a.password.isNotEmpty) 'password': a.password,
      if (a.displayName.isNotEmpty) 'displayName': a.displayName,
      if (a.photoUrl.isNotEmpty) 'photoUrl': a.photoUrl,
      if ((a.errorVariable?.name ?? '').isNotEmpty) 'errorVariable': a.errorVariable!.name,
    },
    ConditionalAction() => {
      'type': 'if',
      'condition': v2Predicate(a.expression),
      if (a.actions.isNotEmpty) 'then': actions(a.actions),
      if (a.elseActions.isNotEmpty) 'else': actions(a.elseActions),
    },
    ForEachAction() => {'type': 'forEach', 'items': a.items, if (a.actions.isNotEmpty) 'actions': actions(a.actions)},
    CloudFilesAction() => {
      if (a.operation != CloudFilesOperation.upload) 'operation': a.operation.name,
      'type': 'cloudFiles',
      'path': a.path,
      if (a.fileType != CloudFilesType.image) 'kind': a.fileType.name,
      if (!a.allowMultiple) 'allowMultiple': false,
      if (a.maxSizeMB != 10) 'maxSizeMB': a.maxSizeMB,
      if ((a.progressVariable?.name ?? '').isNotEmpty) 'progressVariable': a.progressVariable!.name,
      if (a.access != CloudFileAccess.public) 'access': a.access.name,
      if (a.actions.isNotEmpty) 'actions': actions(a.actions),
    },
    ShowToastAction() => _toast(a),
    ConfirmAction() => _confirm(a),
    DelayAction() => {
      'type': 'delay',
      'ms': a.milliseconds,
      if ((a.duration ?? '').trim().isNotEmpty) 'duration': a.duration,
    },
    CloudDataAction() => _cloudData(a),
    CloudBatchAction() => {
      'type': 'cloudBatch',
      'steps': [for (final s in a.steps) action(s)],
      if (a.transaction) 'transaction': true,
    },
    CopyToClipboardAction() => {'type': 'copyToClipboard', 'text': a.text},
    EditTextAction() => {
      'type': 'editText',
      'node': a.nodeId,
      'operation': a.operation.name,
      if (a.text.isNotEmpty) 'text': a.text,
      if (a.before.isNotEmpty) 'before': a.before,
      'after': ?a.after,
      if (a.numbered) 'numbered': true,
    },
    PaywallAction() => {'type': 'paywall', 'operation': a.operation.name, 'slot': ?a.slot, 'url': ?a.url},
    FocusAction() => {
      'type': 'focus',
      'node': a.nodeId,
      if (a.unfocus) 'unfocus': true,
      if (a.selectAll) 'selectAll': true,
    },
    ControlDragAction() => {
      'type': 'controlDrag',
      'node': a.nodeId,
      if (a.command != DragCommand.fling) 'command': a.command.name,
      if (a.direction != DragDirection.right) 'direction': a.direction.name,
      if (a.steps != '1') 'steps': a.steps,
    },
    SpeakAction() => {
      'type': 'speak',
      if (a.text.isNotEmpty) 'text': a.text,
      if (a.language.isNotEmpty) 'language': a.language,
      if (a.rate != '1') 'rate': a.rate,
      if ((a.pitch ?? '').isNotEmpty) 'pitch': a.pitch,
      if (a.stop) 'stop': true,
    },
    ScrollToAction() => {
      'type': 'scrollTo',
      'node': a.nodeId,
      if (a.durationMs != 400) 'durationMs': a.durationMs,
      if (a.curve != MotionCurve.easeInOut) 'curve': a.curve.name,
      if (a.alignment != 0) 'alignment': roundNum(a.alignment),
      if (a.offset != 0) 'offset': roundNum(a.offset),
      if (a.axis case 'horizontal' || 'vertical') 'axis': a.axis,
    },
    PlaySoundAction() => {
      'type': 'playSound',
      if (a.sound != 'wood') 'sound': a.sound,
      if (a.volume != '1') 'volume': a.volume,
      if (a.pitch != '1') 'pitch': a.pitch,
      if (a.at.isNotEmpty) 'at': a.at,
      if (a.url.isNotEmpty) 'url': a.url,
    },
    PlayAnimationAction() => {
      'type': 'playAnimation',
      'node': a.nodeId,
      if (a.animation.isNotEmpty) 'animation': a.animation,
    },
    AnimateVariableAction() => {
      'type': 'animateVariable',
      'variable': a.variable,
      if (a.mode != AnimateVariableMode.play) 'mode': a.mode.name,
      if (a.from.isNotEmpty) 'from': a.from,
      if (a.to != '1') 'to': a.to,
      if (a.durationMs != 1000) 'durationMs': a.durationMs,
      if ((a.duration ?? '').trim().isNotEmpty) 'duration': a.duration,
      if (a.curve != MotionCurve.linear) 'curve': a.curve.name,
    },
    // The haptic's own `when` formula (off when it gives nothing, false,
    // 0 or null) is v2's common `when` predicate.
    HapticAction() => {
      'type': 'haptic',
      if (a.kind != HapticKind.selection) 'kind': a.kind.name,
      if (a.when.trim().isNotEmpty) 'when': {'left': a.when, 'op': 'isTrue'},
    },
    RunScriptAction() => {
      'type': 'runScript',
      'script': a.scriptId,
      if (a.arguments.isNotEmpty) 'arguments': a.arguments,
      if ((a.resultVariable ?? '').isNotEmpty) 'resultVariable': a.resultVariable,
      if (a.onError.isNotEmpty) 'onError': actions(a.onError),
    },
    PaginateAction() => {
      'type': 'paginate',
      'controller': a.controller,
      if (a.command != PaginateCommand.next) 'command': a.command.name,
      if (a.page != '1') 'page': a.page,
      if (a.pageSize != '20') 'pageSize': a.pageSize,
    },
    _ => _unknown(a),
  };

  /// A v1 route transition as v2 `RouteTransition` JSON (colors `#AARRGGBB`,
  /// motions v2 `Motion`s).
  static Json routeTransition(RouteTransition t) {
    Json? side(TransitionSide? s) => s == null
        ? null
        : {
            if (s.motion != MotionModel.none) 'motion': migrateMotion(s.motion),
            if (s.reveal case final TransitionReveal r)
              'reveal': {
                if (r.shape != RevealShape.circle) 'shape': r.shape.name,
                if (r.origin != RevealOrigin.tap) 'origin': r.origin.name,
                if (r.x != 0) 'x': roundNum(r.x),
                if (r.y != 0) 'y': roundNum(r.y),
                if (r.startRadius != 0) 'startRadius': roundNum(r.startRadius),
              },
            if (s.curve != MotionCurve.fastOutSlowIn) 'curve': s.curve.name,
            if (s.delayMs != 0) 'delayMs': s.delayMs,
            'durationMs': ?s.durationMs,
          };
    final d = t.dismiss;
    return {
      'preset': ?t.preset?.name,
      'enter': ?side(t.enter),
      'exit': ?side(t.exit),
      'popEnter': ?side(t.popEnter),
      'popExit': ?side(t.popExit),
      'durationMs': ?t.durationMs,
      'reverseDurationMs': ?t.reverseDurationMs,
      'barrierColor': ?_color(t.barrierColor),
      'opaque': ?t.opaque,
      'swipeBack': ?t.swipeBack?.name,
      if (d != null)
        'dismiss': {
          if (d.direction != DragDirection.down) 'direction': d.direction.name,
          if (d.distance != 0.25) 'distance': roundNum(d.distance),
          if (d.velocity != 700) 'velocity': roundNum(d.velocity),
          if (d.spring != const TransitionSpring())
            'spring': {
              if (d.spring.stiffness != 380) 'stiffness': roundNum(d.spring.stiffness),
              if (d.spring.damping != 36) 'damping': roundNum(d.spring.damping),
              if (d.spring.mass != 1) 'mass': roundNum(d.spring.mass),
            },
        },
    };
  }

  Json _unknown(ActionModel a) {
    report.unmapped.update('action.${a.type.name}', (v) => v + 1, ifAbsent: () => 1);
    return {...Map<String, Object?>.from(a.toJson()), 'type': a.type.name};
  }

  /// A set value's value on node [nodeId]: its binding path (the v1 name
  /// when there's none; reported) and mode.
  Json _nodeValue(String nodeId, ValueModel v) {
    final node = nodes[nodeId];
    final path = node == null ? null : v2BindPath(node, v2TypeOf(node), v.name);
    if (path == null) {
      report.unmappedBindings.update('setValue.${node?.type ?? '?'}.${v.name}', (x) => x + 1, ifAbsent: () => 1);
    }
    return {
      'path': path ?? v.name,
      if (v.mode == SetValueMode.discrete) 'value': v2SetValue(v, path),
      if (v.mode == SetValueMode.toggle) 'mode': 'toggle',
      if (v.mode == SetValueMode.syncValue) 'mode': 'sync',
    };
  }

  /// A v1 data operation for a value of [type] as v2's flat write: `op`,
  /// `value`, `index`, `mapKey`.
  static Json _write(VariableType type, DataOperationInterface a) {
    final String op;
    var index = false, key = false;
    switch (type) {
      case VariableType.boolean:
        op = a.toggled ? 'toggle' : 'set';
      case VariableType.integer || VariableType.decimal:
        op = a.numberOperation.name;
      case VariableType.list:
        op = switch (a.listOperation) {
          ListOperation.replace || ListOperation.set => 'set',
          final o => o.name,
        };
        index = const {'insert', 'insertAll', 'removeAt', 'update'}.contains(op);
      case VariableType.map:
        op = switch (a.mapOperation) {
          MapOperation.replace || MapOperation.set => 'set',
          final o => o.name,
        };
        key = op == 'remove' || op == 'update';
      default:
        op = 'set';
    }
    return {
      if (op != 'set') 'op': op,
      if (op != 'toggle' && op != 'removeAt' && !(key && op == 'remove')) 'value': a.newValue,
      if (index) 'index': a.index,
      if (key) 'mapKey': a.mapKey,
    };
  }

  Json _cloudDocuments(SetCloudStorageSubAction s) => switch (s) {
    AddDocumentSubAction() => {
      'type': 'cloudDocuments',
      'operation': 'add',
      'path': s.path,
      if (s.documentId.isNotEmpty) 'id': s.documentId,
      if (s.autoGenerateId) 'autoId': true,
      if (!s.skipCreationIfDocumentExists) 'skipIfExists': false,
      'document': s.useRawValue ? s.rawValue : s.newValue,
      if (s.useRawValue) 'raw': true,
    },
    UpdateDocumentSubAction() => {
      'type': 'cloudDocuments',
      'operation': 'update',
      'path': s.path,
      'id': s.documentId,
      'field': s.key,
      if (s.variableType != VariableType.text) 'valueType': s.variableType.name,
      ..._write(s.variableType, s),
      if (s.useRawValue) ...{'value': s.rawValue, 'raw': true},
    },
    RemoveDocumentSubAction() => {'type': 'cloudDocuments', 'operation': 'remove', 'path': s.path, 'id': s.documentId},
    RemoveDocumentsSubAction() => {
      'type': 'cloudDocuments',
      'operation': 'removeMany',
      'path': s.path,
      if (s.documentIds.isNotEmpty) 'ids': s.documentIds,
      if (s.whereFilters.isNotEmpty) 'whereFilters': [for (final w in s.whereFilters) w.toJson()],
    },
    SetDocumentsSubAction() => {
      'type': 'cloudDocuments',
      'operation': 'setMany',
      'path': s.path,
      'document': s.documents,
      if (s.idField != 'id') 'idField': s.idField,
      if (s.merge) 'merge': true,
      if (s.replaceCollection) 'replaceCollection': true,
    },
  };

  Json _cloudData(CloudDataAction a) => {
    'type': 'cloudData',
    'operation': a.operation.name,
    'collection': a.collection,
    if (a.documentId.isNotEmpty) 'id': a.documentId,
    if (a.fields.isNotEmpty)
      'fields': [
        for (final f in a.fields)
          {
            'field': f.field,
            if (f.value.isNotEmpty) 'value': f.value,
            if (f.operation != CloudFieldOperation.set) 'operation': f.operation.name,
          },
      ],
    if (a.whereFilters.isNotEmpty) 'whereFilters': [for (final w in a.whereFilters) w.toJson()],
    if (a.orderByFilters.isNotEmpty) 'orderByFilters': [for (final o in a.orderByFilters) o.toJson()],
    'limit': ?a.limit,
    if (a.aggregateField.isNotEmpty) 'aggregateField': a.aggregateField,
    if (a.loadRelated.isNotEmpty) 'loadRelated': a.loadRelated,
    if (a.deleteSubcollections.isNotEmpty) 'deleteSubcollections': a.deleteSubcollections,
    if ((a.resultVariable?.name ?? '').isNotEmpty) 'resultVariable': a.resultVariable!.name,
  };

  Json _toast(ShowToastAction a) {
    final look = <String, Object?>{
      'backgroundColor': ?_color(a.backgroundColor),
      'textColor': ?_color(a.textColor),
      'messageColor': ?_color(a.messageColor),
      'actionColor': ?_color(a.actionColor),
      'closeColor': ?_color(a.closeColor),
      'accentColor': ?_color(a.accentColor),
      'iconColor': ?_color(a.iconColor),
      'iconDiscColor': ?_color(a.iconDiscColor),
      if (a.iconSize != 18) 'iconSize': roundNum(a.iconSize),
      if (a.iconDiscSize != 36) 'iconDiscSize': roundNum(a.iconDiscSize),
      if (a.bottomOffset != 104) 'bottomOffset': roundNum(a.bottomOffset),
      if (a.bottomOffsets.isNotEmpty)
        'bottomOffsets': {for (final e in a.bottomOffsets.entries) e.key.name: roundNum(e.value)},
      'radius': ?a.cornerRadius?.let(roundNum),
      'border': ?a.border?.let(_side),
      if ((a.shadows ?? const []).isNotEmpty) 'shadows': [...a.shadows!.map(V1Node.effect).nonNulls],
      'padding': ?a.padding?.let(_insets),
      if (a.maxWidth != 560) 'maxWidth': roundNum(a.maxWidth),
      if (a.minWidth != 0) 'minWidth': roundNum(a.minWidth),
      'titleStyle': ?a.titleStyle?.let(_textStyle),
      'messageStyle': ?a.messageStyle?.let(_textStyle),
      'actionStyle': ?a.actionStyle?.let(_textStyle),
      if (a.accentWidth != 4) 'accentWidth': roundNum(a.accentWidth),
      'fontFamily': ?a.fontFamily,
      'fontSize': ?a.fontSize?.let(roundNum),
      'fontWeight': ?a.fontWeight?.let((w) => int.parse(w.name.substring(1))),
      if (a.alignment != ToastAlignment.center) 'alignment': a.alignment.name,
      if (a.alignments.isNotEmpty) 'alignments': {for (final e in a.alignments.entries) e.key.name: e.value.name},
      if (a.sideMargin != 16) 'sideMargin': roundNum(a.sideMargin),
      if (a.sideMargins.isNotEmpty)
        'sideMargins': {for (final e in a.sideMargins.entries) e.key.name: roundNum(e.value)},
      if (a.offset.isNotEmpty) 'offset': a.offset,
      'actionBackgroundColor': ?_color(a.actionBackgroundColor),
      'actionBorder': ?a.actionBorder?.let(_side),
      'actionCornerRadius': ?a.actionCornerRadius?.let(roundNum),
      if ((a.actionShadows ?? const []).isNotEmpty) 'actionShadows': [...a.actionShadows!.map(V1Node.effect).nonNulls],
      if ((a.iconShadows ?? const []).isNotEmpty) 'iconShadows': [...a.iconShadows!.map(V1Node.effect).nonNulls],
      if (a.rotation != 0) 'rotation': roundNum(a.rotation),
      if (a.enterCurve != 'easeOutCubic') 'enterCurve': a.enterCurve,
      if (a.enterOffset != 0.25) 'enterOffset': roundNum(a.enterOffset),
    };
    return {
      'type': 'showToast',
      'message': a.message,
      if (a.title.isNotEmpty) 'title': a.title,
      if (a.duration != 2600) 'durationMs': a.duration,
      if (a.style != ToastStyle.neutral) 'style': a.style.name,
      if (a.position != ToastPosition.bottom) 'position': a.position.name,
      if (a.actionLabel.isNotEmpty) 'actionLabel': a.actionLabel,
      if (a.actions.isNotEmpty) 'actions': actions(a.actions),
      if (a.showClose || a.showCloseButton) 'showClose': true,
      if (a.icon case final MultiSourceIconModel i) 'icon': ?_glyph(i),
      if (look.isNotEmpty) 'look': look,
      if (a.variables.isNotEmpty) 'variables': a.variables,
    };
  }

  Json _confirm(ConfirmAction a) {
    final look = <String, Object?>{
      'barrierColor': ?_color(a.barrierColor),
      'backgroundColor': ?_color(a.backgroundColor),
      'textColor': ?_color(a.textColor),
      'confirmColor': ?_color(a.confirmColor),
      'confirmTextColor': ?_color(a.confirmTextColor),
      'cancelColor': ?_color(a.cancelColor),
      'cancelTextColor': ?_color(a.cancelTextColor),
      'radius': ?a.cornerRadius?.let(roundNum),
      'border': ?a.border?.let(_side),
      if ((a.shadows ?? const []).isNotEmpty) 'shadows': [...a.shadows!.map(V1Node.effect).nonNulls],
      'titleStyle': ?a.titleStyle?.let(_textStyle),
      'messageStyle': ?a.messageStyle?.let(_textStyle),
      'captionStyle': ?a.captionStyle?.let(_textStyle),
      'buttonStyle': ?a.buttonStyle?.let(_textStyle),
      'buttonRadius': ?a.buttonRadius?.let(roundNum),
      'buttonBorder': ?a.buttonBorder?.let(_side),
      if ((a.buttonShadows ?? const []).isNotEmpty) 'buttonShadows': [...a.buttonShadows!.map(V1Node.effect).nonNulls],
      'sheetWidth': ?a.sheetWidth?.let(roundNum),
      if (a.maxHeightFactor != 1) 'maxHeightFactor': roundNum(a.maxHeightFactor),
      if (a.showDragHandle) 'showDragHandle': true,
      if (a.barrierBlur != 0) 'barrierBlur': roundNum(a.barrierBlur),
      if (a.enterScale != 1) 'enterScale': roundNum(a.enterScale),
      'confirmBorder': ?a.confirmBorder?.let(_side),
      'cancelBorder': ?a.cancelBorder?.let(_side),
      if (a.icon case final MultiSourceIconModel i) 'icon': ?_glyph(i),
      if (a.iconSize != 24) 'iconSize': roundNum(a.iconSize),
      'iconColor': ?_color(a.iconColor),
      'iconDiscColor': ?_color(a.iconDiscColor),
      if (a.iconDiscSize != 52) 'iconDiscSize': roundNum(a.iconDiscSize),
      'iconDiscBorder': ?a.iconDiscBorder?.let(_side),
      if (a.centered) 'centered': true,
      if (a.expandButtons) 'expandButtons': true,
      'width': ?a.width?.let(roundNum),
      'maxWidth': ?a.maxWidth?.let(roundNum),
      'insets': ?a.insets?.let(_insets),
      'padding': ?a.padding?.let(_insets),
      'buttonHeight': ?a.buttonHeight?.let(roundNum),
    };
    return {
      'type': 'confirm',
      'title': a.title,
      if (a.message.isNotEmpty) 'message': a.message,
      if (a.caption.isNotEmpty) 'caption': a.caption,
      if (a.confirmLabel != 'OK') 'confirmLabel': a.confirmLabel,
      if (a.cancelLabel != 'Cancel') 'cancelLabel': a.cancelLabel,
      if (a.destructive) 'destructive': true,
      if (a.actions.isNotEmpty) 'actions': actions(a.actions),
      if (a.cancelActions.isNotEmpty) 'cancelActions': actions(a.cancelActions),
      if ((a.dialogId ?? '').isNotEmpty) 'dialog': a.dialogId,
      if (a.params.isNotEmpty) 'params': a.params,
      if (a.presentation != DialogPresentation.dialog) 'presentation': a.presentation.name,
      if (a.placement != DialogPlacement.belowStart) 'placement': a.placement.name,
      if (!a.barrierDismissible) 'barrierDismissible': false,
      if (look.isNotEmpty) 'look': look,
      if (a.variables.isNotEmpty) 'variables': a.variables,
    };
  }

  static String? _color(ColorRGBA? c) => c == null ? null : V1Node.rgba(c);

  static List<num> _insets(EdgeInsetsModel e) => [roundNum(e.l), roundNum(e.t), roundNum(e.r), roundNum(e.b)];

  static Json _side(BorderSideModel s) => {
    'color': V1Node.rgba(s.color),
    if (s.width != 1) 'width': roundNum(s.width),
    if (s.style == BorderStyleEnum.none) 'style': 'none',
  };

  /// A v1 text style model as a v2 `TextStyle`.
  static Json _textStyle(TextStyleModel s) => {
    'fontFamily': ?s.fontFamily,
    'fontWeight': ?s.fontWeight?.let((w) => int.parse(w.name.substring(1))),
    if (s.italic == true) 'fontStyle': 'italic',
    'fontSize': ?s.fontSize?.let(roundNum),
    'height': ?s.lineHeight?.let(roundNum),
    'letterSpacing': ?s.letterSpacing?.let(roundNum),
    'color': ?_color(s.color),
  };

  static Json? _glyph(MultiSourceIconModel icon) {
    if (!icon.show) return null;
    return switch (icon.type) {
      IconTypeEnum.icon when icon.icon != null => {
        'source': icon.type.name,
        ...Map<String, Object?>.from(icon.icon!.toJson()),
      },
      IconTypeEnum.image when icon.iconImage != null => {'source': icon.type.name, 'image': icon.iconImage},
      _ => null,
    };
  }
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
