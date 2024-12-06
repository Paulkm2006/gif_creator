import 'package:ffmpeg_kit_flutter_min_gpl/ffprobe_kit.dart';


final regexFR = RegExp(r'"r_frame_rate": "(\d*)\/1"');
final regexH = RegExp(r'"height": (\d*),');
final regexW = RegExp(r'"width": (\d*),');
final regexCodec = RegExp(r'"codec_tag_string": "(\w+)"');

Future<List<String?>> getMediaInfo(String path) async {
  var mediaInfo = await FFprobeKit.getMediaInformation(path);
  var res = await mediaInfo.getOutput();
  var frameRate = regexFR.firstMatch(res!)?.group(1);
  var height = regexH.firstMatch(res)?.group(1);
  var width = regexW.firstMatch(res)?.group(1);
  var codec = regexCodec.firstMatch(res);
  String? codecStr;
  if (codec != null) {
    codecStr = codec.group(1);
  }
  return [frameRate, height, width, codecStr];
}