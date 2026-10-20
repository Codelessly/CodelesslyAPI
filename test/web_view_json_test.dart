import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> webView(String id, Map<String, dynamic> properties) => {
  'id': id,
  'name': 'Web View',
  'type': 'webView',
  'basicBoxLocal': [0, 0, 300, 200],
  'properties': properties,
};

void main() {
  // WebViewProperties.fromJson picks the subclass from webviewType, and the
  // Google Maps and Twitter readers pick theirs from mapMode and embedType,
  // so these keys must be written even though each subclass has only one
  // value for them.
  final samples = {
    'webpage': webView('page', {
      'webviewType': 'webpage',
      'pageSourceType': 'url',
      'input': 'https://example.com',
    }),
    'googleMaps': webView('maps', {
      'webviewType': 'googleMaps',
      'mapMode': 'places',
      'query': 'Coffee',
      'url': 'https://maps.example.com',
    }),
    'twitter': webView('tweet', {
      'webviewType': 'twitter',
      'embedType': 'tweet',
      'tweetURL': 'https://x.com/a/status/1',
      'mediaAutoPlaybackPolicy': 'requireUserActionForAllMedia',
    }),
  };

  for (final MapEntry(key: kind, value: input) in samples.entries) {
    test('$kind web view writes its discriminators and reads back', () {
      final node = NodeJsonConverter().fromJson(input)!;
      final json = jsonDecode(jsonEncode(node.toJson())) as Map;
      final properties = json['properties'] as Map;
      expect(properties['webviewType'], kind);
      if (kind == 'googleMaps') expect(properties['mapMode'], 'places');
      if (kind == 'twitter') expect(properties['embedType'], 'tweet');

      final back = NodeJsonConverter().fromJson(json)!;
      expect(jsonDecode(jsonEncode(back.toJson())), json);
    });
  }
}
