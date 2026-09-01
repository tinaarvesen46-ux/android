import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('bin/generate.dart runs and produces output', () async {
    final result = await Process.run(
      'dart',
      [
        'run',
        'bin/generate.dart',
        '-n',
        '2',
        '-s',
        '99',
        '-o',
        'test_gen.svg',
      ],
    );

    expect(result.exitCode, 0, reason: 'stderr: ${result.stderr}');
    expect(result.stdout, contains('Generated test_gen_1.svg'));
    expect(result.stdout, contains('Generated test_gen_2.svg'));

    final f1 = File('test_gen_1.svg');
    final f2 = File('test_gen_2.svg');

    expect(f1.existsSync(), isTrue);
    expect(f2.existsSync(), isTrue);

    final svg1 = f1.readAsStringSync();
    expect(svg1, startsWith('<svg'));
    expect(svg1, endsWith('</svg>'));
    expect(svg1, contains('xmlns="http://www.w3.org/2000/svg"'));

    expect(svg1, isNot(equals(f2.readAsStringSync())));

    f1.deleteSync();
    f2.deleteSync();
  });

  test('bin/generate.dart is deterministic with seed', () async {
    final run1 = await Process.run(
      'dart',
      ['run', 'bin/generate.dart', '-s', '42', '-o', 'det_a.svg'],
    );
    final run2 = await Process.run(
      'dart',
      ['run', 'bin/generate.dart', '-s', '42', '-o', 'det_b.svg'],
    );

    expect(run1.exitCode, 0);
    expect(run2.exitCode, 0);

    final a = File('det_a.svg');
    final b = File('det_b.svg');

    expect(a.readAsStringSync(), equals(b.readAsStringSync()));

    a.deleteSync();
    b.deleteSync();
  });
}
