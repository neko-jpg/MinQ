import 'dart:convert';
import 'dart:io';

class TutorialStep {
  TutorialStep({
    required this.title,
    required this.caption,
    required this.lottieSegment,
    required this.durationSeconds,
  });

  final String title;
  final String caption;
  final String lottieSegment;
  final int durationSeconds;

  Map<String, dynamic> toStoryboardJson(int index) => <String, dynamic>{
        'id': 'scene_${index + 1}',
        'title': title,
        'caption': caption,
        'durationMs': durationSeconds * 1000,
        'lottieSegment': lottieSegment,
      };
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart tool/tutorial_pipeline/generate_tutorial.dart <input.json> [output_dir]',
    );
    exitCode = 64;
    return;
  }

  final inputFile = File(args[0]);
  if (!await inputFile.exists()) {
    stderr.writeln('Input file not found: ${inputFile.path}');
    exitCode = 66;
    return;
  }

  final outputDir = Directory(args.length > 1 ? args[1] : 'build/tutorial');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final input = jsonDecode(await inputFile.readAsString()) as Map<String, dynamic>;
  final title = input['title'] as String? ?? 'MinQ チュートリアル';
  final stepsRaw = input['steps'] as List<dynamic>?;
  if (stepsRaw == null || stepsRaw.isEmpty) {
    stderr.writeln('No steps defined in input.');
    exitCode = 65;
    return;
  }

  final steps = <TutorialStep>[];
  for (final raw in stepsRaw) {
    if (raw is! Map<String, dynamic>) continue;
    final caption = (raw['caption'] as String?)?.trim() ?? '';
    if (caption.isEmpty) continue;
    steps.add(
      TutorialStep(
        title: (raw['title'] as String?)?.trim() ?? caption,
        caption: caption,
        lottieSegment:
            (raw['lottieSegment'] as String?)?.trim() ?? 'scenes/minq_default.json',
        durationSeconds: (raw['durationSeconds'] as num?)?.toInt() ?? 5,
      ),
    );
  }

  if (steps.isEmpty) {
    stderr.writeln('All steps were invalid or empty.');
    exitCode = 65;
    return;
  }

  final storyboard = <String, dynamic>{
    'title': title,
    'generatedAt': DateTime.now().toIso8601String(),
    'scenes': [
      for (var i = 0; i < steps.length; i++) steps[i].toStoryboardJson(i),
    ],
  };

  final voiceover = StringBuffer()
    ..writeln('# $title')
    ..writeln();
  for (var i = 0; i < steps.length; i++) {
    final step = steps[i];
    voiceover
      ..writeln('## Step ${i + 1}: ${step.title}')
      ..writeln(step.caption)
      ..writeln();
  }

  final metadata = <String, dynamic>{
    'stepCount': steps.length,
    'estimatedDurationSeconds':
        steps.fold<int>(0, (previous, element) => previous + element.durationSeconds),
    'segments': steps.map((step) => step.lottieSegment).toSet().length,
  };

  await File('${outputDir.path}/tutorial_storyboard.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(storyboard));
  await File('${outputDir.path}/voiceover_script.txt')
      .writeAsString(voiceover.toString());
  await File('${outputDir.path}/metadata.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(metadata));

  stdout.writeln('Tutorial assets generated in ${outputDir.path}');
}
