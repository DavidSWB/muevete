import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/privacy/data/bundled_privacy_policy.dart';
import 'package:muevete/features/privacy/data/privacy_policy_codec.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';

Map<String, dynamic> _versionMap() => {
  'version': 3,
  'effectiveFrom': Timestamp.fromDate(DateTime.utc(2027, 1, 15)),
  'textEs': [
    {
      'title': '1. Responsable',
      'blocks': [
        {'type': 'paragraph', 'text': 'Párrafo inicial.'},
        {'type': 'bullet', 'text': 'Viñeta.'},
        {'type': 'paragraph', 'text': 'Párrafo final.'},
      ],
    },
  ],
  'textEn': [
    {
      'title': '1. Controller',
      'blocks': [
        {'type': 'paragraph', 'text': 'Opening paragraph.'},
        {'type': 'bullet', 'text': 'Bullet.'},
        {'type': 'paragraph', 'text': 'Closing paragraph.'},
      ],
    },
  ],
  'policyCheckbox': {'es': 'Acepto la política.', 'en': 'I accept the policy.'},
  'healthDataCheckbox': {
    'es': 'Autorizo mis datos de salud.',
    'en': 'I authorize my health data.',
  },
  'changeSummary': {'es': 'Cambios.', 'en': 'Changes.'},
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('policy metadata', () {
    final map = {
      'currentVersion': 4,
      'minimumAcceptedVersion': 3,
      'requiresReacceptance': false,
      'effectiveFrom': Timestamp.fromDate(DateTime.utc(2027, 3, 1)),
    };

    test('reads every field', () {
      final metadata = PrivacyPolicyCodec.metadataFromMap(map);
      expect(metadata.currentVersion, 4);
      expect(metadata.minimumAcceptedVersion, 3);
      expect(metadata.requiresReacceptance, isFalse);
      expect(
        metadata.effectiveFrom.isAtSameMomentAs(DateTime.utc(2027, 3, 1)),
        isTrue,
      );
    });

    test('writes back the same values', () {
      final metadata = PrivacyPolicyCodec.metadataFromMap(map);
      final again = PrivacyPolicyCodec.metadataFromMap(
        PrivacyPolicyCodec.metadataToMap(metadata),
      );
      expect(again.currentVersion, 4);
      expect(again.minimumAcceptedVersion, 3);
      expect(again.requiresReacceptance, isFalse);
      expect(again.effectiveFrom, metadata.effectiveFrom);
    });

    test('rejects missing or inconsistent fields', () {
      for (final broken in <Map<String, dynamic>>[
        {...map}..remove('currentVersion'),
        {...map, 'currentVersion': '4'},
        {...map, 'currentVersion': 0},
        {...map}..remove('minimumAcceptedVersion'),
        {...map, 'minimumAcceptedVersion': 5},
        {...map, 'requiresReacceptance': 'yes'},
        {...map, 'effectiveFrom': 'not a date'},
      ]) {
        expect(
          () => PrivacyPolicyCodec.metadataFromMap(broken),
          throwsFormatException,
          reason: '$broken',
        );
      }
    });
  });

  group('policy version', () {
    test('keeps paragraphs and bullets in reading order per language', () {
      final version = PrivacyPolicyCodec.versionFromMap(_versionMap());
      expect(version.version, 3);
      expect(
        version.effectiveFrom.isAtSameMomentAs(DateTime.utc(2027, 1, 15)),
        isTrue,
      );

      final es = version.sectionsFor('es').single;
      expect(es.title, '1. Responsable');
      expect(es.blocks.map((b) => b.type), [
        PolicyBlockType.paragraph,
        PolicyBlockType.bullet,
        PolicyBlockType.paragraph,
      ]);
      expect(es.blocks.last.text, 'Párrafo final.');
      expect(version.sectionsFor('en').single.title, '1. Controller');
      expect(version.sectionsFor('fr').single.title, '1. Responsable');

      expect(version.policyCheckbox, {
        'es': 'Acepto la política.',
        'en': 'I accept the policy.',
      });
      expect(version.healthDataCheckbox['en'], 'I authorize my health data.');
      expect(version.changeSummary['es'], 'Cambios.');
    });

    test('writes back the same structure', () {
      final version = PrivacyPolicyCodec.versionFromMap(_versionMap());
      final map = PrivacyPolicyCodec.versionToMap(version);
      expect(
        (map['effectiveFrom'] as DateTime).isAtSameMomentAs(
          DateTime.utc(2027, 1, 15),
        ),
        isTrue,
      );
      expect(map['textEs'], _versionMap()['textEs']);
      expect(map['textEn'], _versionMap()['textEn']);
      expect(map['policyCheckbox'], _versionMap()['policyCheckbox']);
      expect(map['healthDataCheckbox'], _versionMap()['healthDataCheckbox']);
      expect(map['changeSummary'], _versionMap()['changeSummary']);
      expect(PrivacyPolicyCodec.versionFromMap(map).version, 3);
    });

    test('accepts an ISO date, as in the bundled file', () {
      final version = PrivacyPolicyCodec.versionFromMap({
        ..._versionMap(),
        'effectiveFrom': '2027-01-15T00:00:00Z',
      });
      expect(
        version.effectiveFrom.isAtSameMomentAs(DateTime.utc(2027, 1, 15)),
        isTrue,
      );
    });

    test('rejects anything that would show an empty or partial policy', () {
      Map<String, dynamic> withSection(Map<String, dynamic> section) => {
        ..._versionMap(),
        'textEs': [section],
      };
      for (final broken in <Map<String, dynamic>>[
        {..._versionMap(), 'version': 0},
        {..._versionMap(), 'textEs': <Object>[]},
        {..._versionMap()}..remove('textEn'),
        withSection({
          'title': ' ',
          'blocks': [
            {'type': 'paragraph', 'text': 'x'},
          ],
        }),
        withSection({'title': 'T', 'blocks': <Object>[]}),
        withSection({
          'title': 'T',
          'blocks': [
            {'type': 'heading', 'text': 'x'},
          ],
        }),
        withSection({
          'title': 'T',
          'blocks': [
            {'type': 'bullet', 'text': ''},
          ],
        }),
        {
          ..._versionMap(),
          'policyCheckbox': {'es': 'Acepto.'},
        },
        {
          ..._versionMap(),
          'healthDataCheckbox': {'es': 'Autorizo.', 'en': '  '},
        },
        {..._versionMap()}..remove('changeSummary'),
      ]) {
        expect(
          () => PrivacyPolicyCodec.versionFromMap(broken),
          throwsFormatException,
          reason: '$broken',
        );
      }
    });
  });

  group('bundled version 2', () {
    test(
      'loads from the app bundle with full text in both languages',
      () async {
        final version = await BundledPrivacyPolicy().load();
        expect(version.version, 2);
        for (final code in ['es', 'en']) {
          final sections = version.sectionsFor(code);
          expect(sections, hasLength(9));
          final text = sections
              .expand((s) => [s.title, ...s.blocks.map((b) => b.text)])
              .join('\n');
          expect(text, contains('David Camilo Eraso Oñate'));
          expect(text, contains('davidc.eraso221@umariana.edu.co'));
          expect(text, contains('nam5'));
          expect(text, contains('008'));
          expect(version.policyCheckbox[code], isNotEmpty);
          expect(version.healthDataCheckbox[code], isNotEmpty);
          expect(version.changeSummary[code], isNotEmpty);
        }
        expect(
          version.policyCheckbox['es'],
          startsWith(
            'He leído y acepto la política de tratamiento de datos personales',
          ),
        );
        expect(
          version.healthDataCheckbox['es'],
          startsWith(
            'Autorizo de forma expresa el tratamiento de mis datos de salud',
          ),
        );
      },
    );

    test('is treated as current and mandatory when used as metadata', () async {
      final version = await BundledPrivacyPolicy().load();
      final metadata = BundledPrivacyPolicy.metadataFor(version);
      expect(metadata.currentVersion, 2);
      expect(metadata.minimumAcceptedVersion, 2);
      expect(metadata.requiresReacceptance, isTrue);
      expect(metadata.effectiveFrom, version.effectiveFrom);
    });

    test('a broken bundle is reported, not shown', () async {
      final policy = BundledPrivacyPolicy(bundle: _StringBundle('[]'));
      await expectLater(policy.load(), throwsFormatException);
    });
  });
}

class _StringBundle extends CachingAssetBundle {
  _StringBundle(this.content);

  final String content;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(content.codeUnits));

  @override
  Future<String> loadString(String key, {bool cache = true}) async => content;
}
