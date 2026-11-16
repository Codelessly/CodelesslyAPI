// Responsive rules for a desktop Page. These are media patches on the
// expanded document: the written-width layout stays as it was.
import '../json.dart';

/// Lets structural rows stack and grids take fewer columns on smaller pages.
/// Only the shape of the tree matters; labels, ids, and theme colors do not.
void reflowPage(Json document) {
  final nodes = (document['nodes'] as Map).cast<String, Object?>();

  Json? node(String id) => switch (nodes[id]) {
    final Map value => value.cast<String, Object?>(),
    _ => null,
  };
  List<String> children(Json n) => [
    for (final id in (n['children'] as List? ?? const []))
      if (id is String) id,
  ];
  void rule(Json n, int maxWidth, Json patch) {
    final media = (n['media'] as List?)?.cast<Object?>() ?? <Object?>[];
    media.add({'maxWidth': maxWidth, 'patch': patch});
    n['media'] = media;
  }

  // A row of substantial regions is a layout row, not an inline label.
  // Flex can turn vertical through a media patch while retaining its children.
  for (final id in nodes.keys.toList()) {
    final row = node(id);
    if (row == null || row['type'] != 'row') continue;
    final props =
        (row['props'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
    if (props['scrollable'] == true) continue;
    final ids = children(row);
    if (ids.length < 2) continue;
    final kids = [for (final child in ids) ?node(child)];
    final large = kids
        .where(
          (n) =>
              (n['type'] == 'column' &&
                  ((n['layout'] as Map?)?['width'] is Map ||
                      ((n['layout'] as Map?)?['width'] is num &&
                          ((n['layout'] as Map)['width'] as num) >= 160))) ||
              n['type'] == 'gridView' ||
              (n['type'] is String && (n['type'] as String).endsWith('Card')) ||
              const {
                'Segments',
                'PricingPlan',
                'Counter',
                'Media',
              }.contains(n['type']),
        )
        .length;
    final footerLinks = ids.length >= 3 &&
        props['mainAxisAlignment'] == 'spaceBetween' &&
        kids.every((n) => n['type'] == 'text' || n['type'] == 'textButton');
    if (large < 1 && !footerLinks) continue;
    // Navigation rows keep their horizontal bar and scrolling link strip.
    if (ids.any(
      (child) => children(node(child) ?? const {}).any(
        (grandchild) =>
            (node(grandchild)?['actions'] as List? ?? const []).isNotEmpty &&
            node(grandchild)?['type'] == 'textButton',
      ),
    ))
      continue;
    row['type'] = 'flex';
    props['direction'] = 'horizontal';
    row['props'] = props;
    rule(row, 699, {
      'props': {
        'direction': 'vertical',
        'crossAxisAlignment': 'stretch',
        'mainAxisAlignment': 'start',
      },
    });
    for (final child in ids) {
      final kid = node(child)!;
      if (kid['type'] == 'spacer') {
        rule(kid, 699, {'visible': false, 'layout': {'flex': null}});
        continue;
      }
      final layout =
          (kid['layout'] as Map?)?.cast<String, Object?>() ??
          <String, Object?>{};
      if (layout['flex'] == null && layout['width'] is! Map) continue;
      rule(kid, 699, {
        'layout': {
          'flex': null,
          'width': {'fill': 0},
          'height': {'hug': 0},
        },
      });
    }
  }
}
