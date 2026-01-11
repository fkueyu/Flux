import 'package:flutter_test/flutter_test.dart';
import 'package:flux/models/wled_segment.dart';

void main() {
  group('WledSegment', () {
    test('fromJson parses segment with colors', () {
      final json = {
        'id': 0,
        'start': 0,
        'stop': 30,
        'len': 30,
        'col': [
          [255, 0, 0],
          [0, 255, 0],
          [0, 0, 255],
        ],
        'fx': 5,
        'sx': 200,
        'ix': 150,
        'pal': 3,
        'c1': 100,
        'c2': 110,
        'c3': 120,
        'on': true,
        'sel': true,
        'rev': false,
        'mi': true,
      };

      final segment = WledSegment.fromJson(json);

      expect(segment.id, 0);
      expect(segment.start, 0);
      expect(segment.stop, 30);
      expect(segment.len, 30);
      expect(segment.col.length, 3);
      expect(segment.col[0], [255, 0, 0]);
      expect(segment.col[1], [0, 255, 0]);
      expect(segment.col[2], [0, 0, 255]);
      expect(segment.fx, 5);
      expect(segment.sx, 200);
      expect(segment.ix, 150);
      expect(segment.pal, 3);
      expect(segment.c1, 100);
      expect(segment.c2, 110);
      expect(segment.c3, 120);
      expect(segment.on, true);
      expect(segment.sel, true);
      expect(segment.rev, false);
      expect(segment.mi, true);
    });

    test('fromJson handles empty color array', () {
      final json = {
        'id': 1,
        'col': <List<int>>[],
        'on': true,
        'sel': false,
        'rev': false,
        'mi': false,
      };

      final segment = WledSegment.fromJson(json);

      expect(segment.col, isEmpty);
      expect(segment.primaryColor, [255, 160, 0]); // Default warm white
    });

    test('copyWith preserves unmodified fields', () {
      const original = WledSegment(
        id: 0,
        start: 0,
        stop: 30,
        fx: 10,
        sx: 128,
        ix: 128,
        pal: 5,
      );

      final modified = original.copyWith(fx: 20, pal: 10);

      expect(modified.id, 0);
      expect(modified.start, 0);
      expect(modified.stop, 30);
      expect(modified.fx, 20);
      expect(modified.sx, 128);
      expect(modified.ix, 128);
      expect(modified.pal, 10);
    });

    test('primaryColor returns first color', () {
      const segment = WledSegment(
        id: 0,
        col: [
          [100, 150, 200],
          [0, 0, 0],
        ],
      );

      expect(segment.primaryColor, [100, 150, 200]);
    });

    test('backgroundColor returns second color', () {
      const segment = WledSegment(
        id: 0,
        col: [
          [255, 0, 0],
          [0, 255, 0],
        ],
      );

      expect(segment.backgroundColor, [0, 255, 0]);
    });

    test('backgroundColor returns black when only one color', () {
      const segment = WledSegment(
        id: 0,
        col: [
          [255, 0, 0],
        ],
      );

      expect(segment.backgroundColor, [0, 0, 0]);
    });

    test('tertiaryColor returns third color', () {
      const segment = WledSegment(
        id: 0,
        col: [
          [255, 0, 0],
          [0, 255, 0],
          [0, 0, 255],
        ],
      );

      expect(segment.tertiaryColor, [0, 0, 255]);
    });
  });
}
