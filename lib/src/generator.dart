import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:flutter/material.dart';


void cancelGifGeneration() {
  FFmpegKit.cancel();
}

Future<String?> generateGifFromVideo({
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
  required Offset cropLU,
  required Offset cropRD,
  required int rotation,
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

  String rotationOptionFront = '';
  String rotationOptionBack = '';

  if (rotation == 90) {
    rotationOptionFront = 'transpose=2,';
    rotationOptionBack = ',transpose=1';
  } else if (rotation == 180) {
    rotationOptionFront = 'hflip,vflip,';
  } else if (rotation == 270) {
    rotationOptionFront = 'transpose=1,';
    rotationOptionBack = ',transpose=2';
  }

  String ditherOption = '[s0]palettegen=max_colors=${maxColor.toStringAsFixed(0)}[p];[s1][p]paletteuse=dither=$dither:diff_mode=${useRectangle?'rectangle':'none'}';

  String cropOption = '${rotationOptionFront}crop=${(cropRD.dx - cropLU.dx).toStringAsFixed(0)}:${(cropRD.dy - cropLU.dy).toStringAsFixed(0)}:${(cropLU.dx).toStringAsFixed(0)}:${(cropLU.dy).toStringAsFixed(0)}$rotationOptionBack';

  String command = '''
  $trimOption -i "$path" -vf "$cropOption,fps=$fps,scale=iw*$scale:ih*$scale:flags=$algorithm,split[s0][s1];$ditherOption" $loopOption "$outputPath"
  ''';

  String? err = '';
  await FFmpegKit.execute(command.trim()).then((session) async {
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      err = null;
    } else if (ReturnCode.isCancel(returnCode)) {
      err = null;
    } else {
      err = await session.getOutput();
    }
  });
  return err;
}
