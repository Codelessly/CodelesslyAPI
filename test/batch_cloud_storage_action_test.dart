import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('removeDocuments round-trips and omits defaults', () {
    final action = SetCloudStorageAction(
      subAction: const RemoveDocumentsSubAction(path: 'sessions'),
    );
    final Map json = action.toJson();
    expect(json['subAction'], {
      'path': 'sessions',
      'operation': 'removeDocuments',
    });
    expect(ActionModel.fromJson(json), action);

    final filtered = SetCloudStorageAction(
      subAction: const RemoveDocumentsSubAction(
        path: 'sessions',
        documentIds: r'${= ids}',
        whereFilters: [
          WhereQueryFilter(
            field: 'spot',
            operator: WhereQueryOperator.equal,
            value: 'Pipe',
          ),
        ],
      ),
    );
    final restored =
        ActionModel.fromJson(filtered.toJson()) as SetCloudStorageAction;
    expect(restored, filtered);
    expect(
      (restored.subAction as RemoveDocumentsSubAction)
          .whereFilters
          .single
          .value,
      'Pipe',
    );
    expect(SetCloudStorageOperation.removeDocuments.isBatch, isTrue);
    expect(SetCloudStorageOperation.removeDocuments.label, 'Remove Documents');
  });

  test('setDocuments round-trips and omits defaults', () {
    final action = SetCloudStorageAction(
      subAction: const SetDocumentsSubAction(
        path: 'sessions',
        documents: r'${seedSessions}',
      ),
    );
    expect(action.toJson()['subAction'], {
      'path': 'sessions',
      'documents': r'${seedSessions}',
      'operation': 'setDocuments',
    });
    final custom = SetCloudStorageAction(
      subAction: const SetDocumentsSubAction(
        path: 'sessions',
        documents: '[{"id": "a"}]',
        idField: 'key',
        merge: true,
        replaceCollection: true,
      ),
    );
    expect(ActionModel.fromJson(custom.toJson()), custom);
    expect(SetCloudStorageOperation.setDocuments.label, 'Set Documents');
  });

  test(
    'InputDecorationModel.contentPadding round-trips; omitted by default',
    () {
      final InputDecorationModel plain = InputDecorationModel();
      expect(plain.toJson().containsKey('contentPadding'), isFalse);
      expect(plain.contentPadding, isNull);

      final InputDecorationModel flush = plain.copyWith(
        contentPadding: EdgeInsetsModel.zero,
      );
      expect(flush.toJson()['contentPadding'], 0);
      expect(
        InputDecorationModel.fromJson(flush.toJson()).contentPadding,
        EdgeInsetsModel.zero,
      );
      expect(flush.copyWith(clearContentPadding: true).contentPadding, isNull);
    },
  );

  test(
    'ShowToastAction close button, action color, radius, font and offset',
    () {
      final ShowToastAction plain = ShowToastAction(message: 'Saved');
      expect(plain.toJson(), {'type': 'showToast', 'message': 'Saved'});
      expect(plain.showClose, isFalse);

      final ShowToastAction custom = plain.copyWith(
        actionLabel: 'UNDO',
        actionColor: ColorRGBA.fromHex('#F2542D'),
        showClose: true,
        cornerRadius: 8,
        fontSize: 13,
        fontFamily: 'Inter',
        fontWeight: FontWeightNumeric.w600,
        offset: r'${= screen.isMobile ? 96 : 24}',
      );
      final Map json = custom.toJson();
      expect(json['showClose'], isTrue);
      expect(json['cornerRadius'], 8);
      expect(json['fontSize'], 13);
      expect(json['fontFamily'], 'Inter');
      expect(json['fontWeight'], 'w600');
      expect(ActionModel.fromJson(json), custom);
      expect(
        custom.copyWith(clearFontFamily: true, clearFontWeight: true).toJson(),
        isNot(contains('fontFamily')),
      );
      expect(
        custom
            .copyWith(clearActionColor: true, clearCornerRadius: true)
            .toJson()
            .keys,
        isNot(contains('actionColor')),
      );
    },
  );
}
