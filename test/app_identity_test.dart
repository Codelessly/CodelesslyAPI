import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

AppIdentity _full() => const AppIdentity(
      name: 'Wireless',
      shortName: 'Wireless',
      titleTemplate: r'${page.title} | ${app.name}',
      description: 'Phone plans without the fine print.',
      keywords: ['phone', 'plans'],
      canonicalUrl: 'https://wireless.example.com/',
      language: 'fr-CA',
      textDirection: IdentityTextDirection.rtl,
      robotsIndex: false,
      robotsFollow: true,
      themeColor: '#112233',
      themeColorDark: '#000000',
      backgroundColor: '#FFFFFF',
      favicon: IdentityImage(
        url: 'https://x/favicon.svg',
        contentType: 'image/svg+xml',
      ),
      faviconDark: IdentityImage(url: 'https://x/fd.png', width: 64, height: 64),
      iconSource: IdentityImage(
        url: 'https://x/icon.png',
        width: 1024,
        height: 1024,
        contentType: 'image/png',
        hash: 'abc',
        hasAlpha: false,
      ),
      iconPadding: 0.2,
      iconBackgroundColor: '#FF0000',
      appleTouchIcon: IdentityImage(url: 'https://x/apple.png'),
      social: SocialCard(
        title: 'OG title',
        description: 'OG desc',
        image: IdentityImage(url: 'https://x/og.png', width: 1200, height: 630),
        imageAlt: 'alt',
        cardType: SocialCardType.summary,
        twitterSite: '@wireless',
      ),
      manifest: PwaManifestSettings(
        display: PwaDisplayMode.minimalUi,
        orientation: PwaOrientation.portrait,
        startUrl: 'home',
        scope: '/',
        categories: ['utilities'],
        shortcuts: [PwaShortcut(name: 'Plans', url: 'plans', shortName: 'P')],
      ),
      splash: SplashSettings(
        backgroundColor: '#101010',
        backgroundColorDark: '#000000',
        logo: IdentityImage(url: 'https://x/logo.png'),
        logoDark: IdentityImage(url: 'https://x/logo-dark.png'),
      ),
      mobile: MobileIdentity(
        displayName: 'Wire',
        adaptiveIconForeground: IdentityImage(url: 'https://x/fg.png'),
        adaptiveIconBackgroundColor: '#00FF00',
        statusBarStyle: StatusBarStyle.light,
        launchScreen: SplashSettings(backgroundColor: '#222222'),
      ),
      pages: {
        'page1': PageIdentity(
          name: 'Plans',
          title: 'Our plans',
          description: 'All plans',
          path: 'plans',
        ),
      },
      assets: {'icon-192.png': 'https://x/icon-192.png'},
      assetsHash: 'deadbeef',
    );

void main() {
  group('AppIdentity JSON', () {
    test('round-trips every field', () {
      final AppIdentity identity = _full();
      final Map<String, dynamic> json =
          jsonDecode(jsonEncode(identity.toJson())) as Map<String, dynamic>;
      expect(AppIdentity.fromJson(json), identity);
      expect(json['version'], kAppIdentitySchemaVersion);
    });

    test('defaults round-trip and write no nulls', () {
      const AppIdentity identity = AppIdentity();
      final Map<String, dynamic> json = identity.toJson();
      expect(AppIdentity.fromJson(json), identity);
      void noNulls(Object? v) {
        if (v is Map) {
          for (final e in v.values) {
            expect(e, isNotNull);
            noNulls(e);
          }
        }
      }

      noNulls(json);
      expect(json.containsKey('titleTemplate'), isFalse);
    });

    test('ignores unknown keys and bad types', () {
      final AppIdentity identity = AppIdentity.fromJson({
        'name': 42,
        'themeColor': 'not a color',
        'iconPadding': 'x',
        'future': {'thing': true},
        'pages': {'a': 'nope', 'b': {}},
        'manifest': {'display': 'weird'},
      });
      expect(identity.name, isNull);
      expect(identity.themeColor, isNull);
      expect(identity.iconPadding, 0.1);
      expect(identity.pages, isEmpty);
      expect(identity.manifest.display, PwaDisplayMode.standalone);
    });

    test('migrates legacy shapes', () {
      final AppIdentity identity = AppIdentity.fromJson({
        'title': 'Old name',
        'ogTitle': 'T',
        'ogDescription': 'D',
        'ogImage': 'https://x/og.png',
        'twitterCard': 'summary',
        'robots': 'noindex, nofollow',
        'icon': 'https://x/icon.png',
        'themeColor': 0xFF336699,
        'backgroundColor': '0xFFFFFFFF',
        'iconBackgroundColor': '#abc',
        'keywords': 'a, b ,c',
        'manifest': {'display': 'minimal-ui', 'start_url': '/x'},
        'splash': {'color': {'r': 1, 'g': 0, 'b': 0}},
        'iconPadding': 0.9,
      });
      expect(identity.name, 'Old name');
      expect(identity.social.title, 'T');
      expect(identity.social.description, 'D');
      expect(identity.social.image?.url, 'https://x/og.png');
      expect(identity.social.cardType, SocialCardType.summary);
      expect(identity.robotsIndex, isFalse);
      expect(identity.robotsFollow, isFalse);
      expect(identity.iconSource?.url, 'https://x/icon.png');
      expect(identity.themeColor, '#336699');
      expect(identity.backgroundColor, '#FFFFFF');
      expect(identity.iconBackgroundColor, '#AABBCC');
      expect(identity.keywords, ['a', 'b', 'c']);
      expect(identity.manifest.display, PwaDisplayMode.minimalUi);
      expect(identity.manifest.startUrl, '/x');
      expect(identity.splash.backgroundColor, '#FF0000');
      expect(identity.iconPadding, 0.4, reason: 'clamped');
    });

    test('maybeFromJson tolerates missing identity (old bundles)', () {
      expect(AppIdentity.maybeFromJson(null), isNull);
      expect(AppIdentity.maybeFromJson('x'), isNull);
      expect(AppIdentity.maybeFromJson({}), const AppIdentity());
    });

    test('merge deep-merges and null removes', () {
      final AppIdentity merged = _full().merge({
        'social': {'title': 'New'},
        'description': null,
        'pages': {
          'page1': {'title': null},
        },
      });
      expect(merged.social.title, 'New');
      expect(merged.social.description, 'OG desc');
      expect(merged.description, isNull);
      expect(merged.pages['page1']!.title, isNull);
      expect(merged.pages['page1']!.name, 'Plans');
    });
  });

  group('colors', () {
    test('normalizeHexColor', () {
      expect(normalizeHexColor('#fff'), '#FFFFFF');
      expect(normalizeHexColor('112233'), '#112233');
      expect(normalizeHexColor('#11223380'), '#11223380');
      expect(normalizeHexColor('#112233ff'), '#112233');
      expect(normalizeHexColor(0x80112233), '#11223380');
      expect(normalizeHexColor('red'), isNull);
      expect(normalizeHexColor('#12345'), isNull);
    });
  });

  group('titles', () {
    test('renders the default template', () {
      expect(
        renderTitle(kDefaultTitleTemplate, appName: 'App', pageTitle: 'Home'),
        'Home · App',
      );
    });

    test('drops the separator next to an empty value', () {
      expect(renderTitle(kDefaultTitleTemplate, appName: 'App'), 'App');
      expect(
        renderTitle(kDefaultTitleTemplate, appName: '', pageTitle: 'Home'),
        'Home',
      );
      expect(
        renderTitle(r'${app.name}: ${page.title}!', appName: 'A'),
        'A',
      );
    });

    test('titleFor uses override, then stored name, then given name', () {
      final AppIdentity identity = _full();
      expect(identity.titleFor(pageId: 'page1'), 'Our plans | Wireless');
      expect(
        identity.merge({
          'pages': {
            'page1': {'title': null},
          },
        }).titleFor(pageId: 'page1'),
        'Plans | Wireless',
      );
      expect(identity.titleFor(pageId: 'x', pageName: 'Other'),
          'Other | Wireless');
      expect(identity.titleFor(), 'Wireless');
    });

    test('descriptionFor falls back to the project description', () {
      final AppIdentity identity = _full();
      expect(identity.descriptionFor('page1'), 'All plans');
      expect(identity.descriptionFor('nope'), identity.description);
    });
  });

  group('checklist', () {
    test('empty identity warns about name, description, icon, OG image', () {
      final codes = const AppIdentity().checklist().map((e) => e.code).toSet();
      expect(
        codes,
        containsAll([
          'missing-name',
          'missing-description',
          'missing-icon',
          'missing-social-image',
          'missing-theme-color',
        ]),
      );
    });

    test('non-square and transparent icons are flagged', () {
      final codes = const AppIdentity(
        iconSource: IdentityImage(
          url: 'u',
          width: 1024,
          height: 512,
          hasAlpha: true,
        ),
      ).checklist().map((e) => e.code).toSet();
      expect(codes, containsAll(['icon-not-square', 'ios-icon-transparent']));
    });

    test('stale assets and bad canonical are flagged', () {
      final codes = const AppIdentity(
        iconSource: IdentityImage(url: 'u', width: 1024, height: 1024),
        canonicalUrl: 'example.com',
      ).checklist().map((e) => e.code).toSet();
      expect(codes, containsAll(['assets-stale', 'bad-canonical']));
    });

    test('a complete identity has no warnings', () {
      AppIdentity identity = _full();
      identity = identity.merge({'assetsHash': identity.assetInputsHash});
      expect(
        identity
            .checklist()
            .where((e) => e.level != IdentityIssueLevel.info)
            .toList(),
        isEmpty,
      );
    });
  });

  group('assets and manifest', () {
    test('asset spec covers the required sizes', () {
      final Map<String, IdentityAssetSpec> byKey = {
        for (final s in IdentityAssets.all) s.key: s,
      };
      for (final int size in [16, 32]) {
        expect(byKey['favicon-$size.png']!.width, size);
      }
      expect(byKey['apple-touch-icon.png']!.width, 180);
      expect(byKey['icon-192.png']!.width, 192);
      expect(byKey['icon-512.png']!.width, 512);
      expect(byKey['maskable-512.png']!.maskable, isTrue);
      expect(byKey['favicon.ico']!.format, 'ico');
      expect(IdentityAssets.icoSizes, [16, 32, 48]);
      expect(byKey['og.png']!.width, 1200);
      expect(byKey['og.png']!.height, 630);
      expect(IdentityAssets.splash, isNotEmpty);
      expect(byKey.length, IdentityAssets.all.length, reason: 'unique keys');
    });

    test('assetInputsHash changes with the inputs', () {
      final AppIdentity a = _full();
      expect(a.assetInputsHash, a.assetInputsHash);
      expect(a.merge({'iconPadding': 0.3}).assetInputsHash,
          isNot(a.assetInputsHash));
    });

    test('toWebManifest scopes to the base URL', () {
      final AppIdentity identity = _full().merge({
        'assets': {
          'icon-512.png': 'https://x/512.png',
          'maskable-512.png': 'https://x/m512.png',
        },
      });
      final Map<String, dynamic> m =
          identity.toWebManifest(baseUrl: '/wireless/');
      expect(m['start_url'], '/wireless/home');
      expect(m['scope'], '/wireless/');
      expect(m['id'], '/wireless/');
      expect(m['display'], 'minimal-ui');
      expect(m['theme_color'], '#112233');
      final List icons = m['icons'] as List;
      expect(icons.map((e) => e['purpose']), containsAll(['any', 'maskable']));
      expect((m['shortcuts'] as List).single['url'], '/wireless/plans');
    });
  });
}
