import 'package:flutter_test/flutter_test.dart';
import 'package:flux/models/wled_state.dart';
import 'package:flux/models/wled_segment.dart';

void main() {
  group('WledState', () {
    test('fromJson parses complete response', () {
      final json = {
        'on': true,
        'bri': 128,
        'transition': 7,
        'ps': 1,
        'pl': -1,
        'mainseg': 0,
        'seg': [
          {
            'id': 0,
            'start': 0,
            'stop': 30,
            'len': 30,
            'col': [
              [255, 0, 0],
              [0, 255, 0],
              [0, 0, 255],
            ],
            'fx': 0,
            'sx': 128,
            'ix': 128,
            'pal': 0,
            'on': true,
            'sel': true,
            'rev': false,
            'mi': false,
          },
        ],
        'nl': {'on': false, 'dur': 60, 'mode': 1, 'tbri': 0, 'rem': -1},
        'udpn': {'send': false, 'recv': true},
      };

      final state = WledState.fromJson(json);

      expect(state.on, true);
      expect(state.bri, 128);
      expect(state.transition, 7);
      expect(state.ps, 1);
      expect(state.pl, -1);
      expect(state.mainSeg, 0);
      expect(state.seg.length, 1);
      expect(state.nl.on, false);
      expect(state.nl.dur, 60);
      expect(state.udpn.send, false);
      expect(state.udpn.receive, true);
    });

    test('fromJson handles minimal response', () {
      final json = {
        'on': false,
        'bri': 0,
        'seg': <Map<String, dynamic>>[],
        'nl': <String, dynamic>{},
        'udpn': <String, dynamic>{},
      };

      final state = WledState.fromJson(json);

      expect(state.on, false);
      expect(state.bri, 0);
      expect(state.seg, isEmpty);
    });

    test('copyWith creates modified copy', () {
      const original = WledState(on: true, bri: 100);
      final modified = original.copyWith(bri: 200, on: false);

      expect(modified.on, false);
      expect(modified.bri, 200);
      expect(original.on, true); // Original unchanged
      expect(original.bri, 100);
    });

    test('briPercent calculates correctly', () {
      const state = WledState(on: true, bri: 255);
      expect(state.briPercent, 1.0);

      const halfState = WledState(on: true, bri: 127);
      expect(halfState.briPercent, closeTo(0.498, 0.01));

      const offState = WledState(on: false, bri: 0);
      expect(offState.briPercent, 0.0);
    });

    test('primaryColor returns main segment color', () {
      final state = WledState(
        on: true,
        bri: 255,
        seg: [
          const WledSegment(
            id: 0,
            col: [
              [255, 128, 64],
            ],
          ),
        ],
      );

      expect(state.primaryColor, [255, 128, 64]);
    });

    test('primaryColor returns null when no segments', () {
      const state = WledState(on: true, bri: 255);
      expect(state.primaryColor, null);
    });
  });

  group('WledNightlight', () {
    test('fromJson parses nightlight config', () {
      final json = {'on': true, 'dur': 120, 'mode': 2, 'tbri': 50, 'rem': 3600};

      final nl = WledNightlight.fromJson(json);

      expect(nl.on, true);
      expect(nl.dur, 120);
      expect(nl.mode, 2);
      expect(nl.tbri, 50);
      expect(nl.rem, 3600);
    });

    test('default values are correct', () {
      const nl = WledNightlight();

      expect(nl.on, false);
      expect(nl.dur, 60);
      expect(nl.mode, 1);
      expect(nl.tbri, 0);
      expect(nl.rem, -1);
    });

    test('copyWith creates modified copy', () {
      const original = WledNightlight(on: false, dur: 60);
      final modified = original.copyWith(on: true, dur: 120);

      expect(modified.on, true);
      expect(modified.dur, 120);
      expect(original.on, false);
    });
  });

  group('WledUdpSync', () {
    test('fromJson parses sync config', () {
      final json = {'send': true, 'recv': false};

      final sync = WledUdpSync.fromJson(json);

      expect(sync.send, true);
      expect(sync.receive, false);
    });

    test('default values are correct', () {
      const sync = WledUdpSync();

      expect(sync.send, false);
      expect(sync.receive, true);
    });
  });
}
