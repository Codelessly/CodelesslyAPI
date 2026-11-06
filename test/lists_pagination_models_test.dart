import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Object? encodeDecode(Object? json) => jsonDecode(jsonEncode(json));

void main() {
  group('PaginationModel', () {
    test('defaults are omitted from JSON', () {
      expect(const PaginationModel(name: 'contacts').toJson(), {
        'name': 'contacts',
      });
    });

    test('round-trips every field', () {
      const PaginationModel model = PaginationModel(
        name: 'feed',
        mode: PaginationMode.bidirectional,
        source: PaginationSource.cloud,
        pageSize: 40,
        pageSizeOptions: [40, 80],
        strategy: PaginationStrategy.page,
        keyPath: 'uid',
        initialPage: 3,
        thresholdItems: 8,
        thresholdPixels: 600,
        cachePages: false,
        apiId: 'api',
        parameters: {'page': r'${page.page}'},
        itemsPath: 'results',
        totalPath: 'count',
        cursorPath: 'next',
        pullToRefresh: true,
        refreshColor: ColorRGBA.white,
        refreshBackgroundColor: ColorRGBA.black,
        refreshDisplacement: 60,
        loadingNodeId: 'l',
        errorNodeId: 'e',
        endNodeId: 'd',
      );
      final Map json = encodeDecode(model.toJson()) as Map;
      expect(PaginationModel.fromJson(json), model);
      expect(model.slotNodeIds, ['l', 'e', 'd']);
    });

    test('unknown enum values fall back', () {
      final PaginationModel model = PaginationModel.fromJson({
        'name': 'x',
        'mode': 'sideways',
        'source': 'ftp',
        'strategy': 'magic',
      });
      expect(model.mode, PaginationMode.infinite);
      expect(model.source, PaginationSource.data);
      expect(model.strategy, PaginationStrategy.offset);
    });

    test('a cloud source always pages by cursor', () {
      expect(
        const PaginationModel(
          name: 'x',
          source: PaginationSource.cloud,
        ).effectiveStrategy,
        PaginationStrategy.cursor,
      );
      expect(
        const PaginationModel(
          name: 'x',
          strategy: PaginationStrategy.page,
        ).effectiveStrategy,
        PaginationStrategy.page,
      );
    });
  });

  group('PaginateAction', () {
    test('reads through ActionModel.fromJson', () {
      final ActionModel action = ActionModel.fromJson({
        'type': 'paginate',
        'controller': 'contacts',
        'command': 'goTo',
        'page': r'${value}',
      });
      expect(action, isA<PaginateAction>());
      action as PaginateAction;
      expect(action.controller, 'contacts');
      expect(action.command, PaginateCommand.goTo);
      expect(action.page, r'${value}');
      expect(
        ActionModel.fromJson(encodeDecode(action.toJson()) as Map),
        action,
      );
    });

    test('defaults are omitted', () {
      expect(PaginateAction(controller: 'c').toJson(), {
        'type': 'paginate',
        'controller': 'c',
      });
    });
  });

  group('PaginationProperties.pageItems', () {
    test('ellipses stand for skipped pages', () {
      expect(PaginationProperties.pageItems(page: 5, pageCount: 16), [
        1,
        null,
        4,
        5,
        6,
        null,
        16,
      ]);
    });

    test('a single skipped page is shown instead of an ellipsis', () {
      expect(PaginationProperties.pageItems(page: 3, pageCount: 16), [
        1,
        2,
        3,
        4,
        null,
        16,
      ]);
    });

    test('few pages show every number', () {
      expect(PaginationProperties.pageItems(page: 1, pageCount: 4), [
        1,
        2,
        3,
        4,
      ]);
      expect(PaginationProperties.pageItems(page: 1, pageCount: 0), isEmpty);
    });

    test('the current page is clamped and siblings widen the window', () {
      expect(
        PaginationProperties.pageItems(
          page: 99,
          pageCount: 20,
          siblingCount: 2,
          boundaryCount: 2,
        ),
        [1, 2, null, 18, 19, 20],
      );
    });
  });

  group('nodes', () {
    test('a list without the new models writes none of their keys', () {
      final ListViewNode list = ListViewNode(
        id: 'l',
        name: 'l',
        basicBoxLocal: NodeBox(0, 0, 100, 100),
        properties: ListViewProperties(),
        children: const ['row'],
      );
      final Map json = list.toJson();
      for (final key in ['pagination', 'sections', 'reorder', 'swipeActions']) {
        expect(json.containsKey(key), isFalse, reason: key);
      }
      expect(list.slotNodeIds, isEmpty);
    });

    test('a list lists its slot children', () {
      final ListViewNode list = ListViewNode.fromJson({
        'type': 'listView',
        'id': 'l',
        'name': 'l',
        'basicBoxLocal': NodeBox(0, 0, 100, 100).toJson(),
        'properties': {},
        'children': ['row', 'spinner', 'header', 'hole'],
        'pagination': {'name': 'p', 'loadingNodeId': 'spinner'},
        'sections': {'groupBy': 'letter', 'headerNodeId': 'header'},
        'reorder': {'placeholder': 'node', 'placeholderNodeId': 'hole'},
      });
      expect(list.slotNodeIds, ['spinner', 'header', 'hole']);
      expect(list.sections!.isActive, isTrue);
      expect(list.reorder!.placeholder, ReorderPlaceholder.node);
      expect(list.triggerTypes, contains(TriggerType.swipeAction));
    });

    test('pagination and table nodes register with the converter', () {
      final BaseNode? pagination = NodeJsonConverter().fromJson(
        encodeDecode(
              (PaginationNode.empty()
                    ..controller = 'contacts'
                    ..properties.showPageSize = true)
                  .toJson(),
            )
            as Map,
      );
      expect(pagination, isA<PaginationNode>());
      expect((pagination as PaginationNode).controller, 'contacts');
      expect(pagination.properties.showPageSize, isTrue);

      final BaseNode? table = NodeJsonConverter().fromJson({
        'type': 'tableView',
        'id': 't',
        'name': 't',
        'basicBoxLocal': NodeBox(0, 0, 100, 100).toJson(),
        'children': ['c'],
        'properties': {
          'cellNodeId': 'c',
          'columns': [
            {'key': 'a', 'label': 'A'},
          ],
        },
      });
      expect(table, isA<TableViewNode>());
      table as TableViewNode;
      expect(table.properties.columns.single.label, 'A');
      expect(table.deniedTypes, ['tableView']);
      expect(table.toJson().containsKey('deniedTypes'), isFalse);
    });

    test('TableColumnModel reads bound values', () {
      expect(
        TableColumnModel.fromValue({'key': 'a', 'width': 80}),
        const TableColumnModel(key: 'a', label: 'a', width: 80),
      );
      expect(
        TableColumnModel.fromValue('Mon'),
        const TableColumnModel(key: 'Mon', label: 'Mon'),
      );
    });
  });

  test('new triggers serialize by name', () {
    for (final TriggerType type in [
      TriggerType.refresh,
      TriggerType.swipeAction,
    ]) {
      final TriggerModel model = TriggerModel(type: type);
      expect(TriggerModel.fromJson(encodeDecode(model.toJson()) as Map), model);
    }
  });
}
