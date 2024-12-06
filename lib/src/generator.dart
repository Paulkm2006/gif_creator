import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';

Future<void> generateGifFromVideo({
  required String videoPath,
  required String outputPath,
  required double fps,
  required double scale,
  required bool loopInfinite,
  required int loopTime,
  required String algorithm,
  required String samplingMethod,
  required String dither,
  required double maxColor,
  required bool useRectangle,
  RangeValues? trimRange,
}) async {
  var path = videoPath;
  FFmpegKitConfig.getSafParameterForRead(videoPath).then((safUrl) {
    path = safUrl!;
  });
  String loopOption = loopInfinite ? '-loop 0' : loopTime == 0 ? '-loop -1' : '-loop $loopTime';
  String trimOption = '';
  if (trimRange != null) {
    double start = trimRange.start / 1000.0;
    double duration = (trimRange.end - trimRange.start) / 1000.0;
    trimOption = '-ss $start -t $duration';
  }

  String ditherOption = '[s0]palettegen=max_colors=${maxColor.toStringAsFixed(0)}[p];[s1][p]paletteuse=dither=$dither:diff_mode=${useRectangle?'rectangle':'none'}';

  String command = '''
  $trimOption -i "$path" -vf "fps=$fps,scale=iw*$scale:ih*$scale:flags=$algorithm,split[s0][s1];$ditherOption" $loopOption "$outputPath"
  ''';

  await FFmpegKit.execute(command.trim());
}
