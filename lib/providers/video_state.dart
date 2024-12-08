import 'dart:io';

import 'package:gif_creator/src/info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:gif_creator/src/generator.dart';
import 'package:path_provider/path_provider.dart';

class VideoState extends ChangeNotifier {
  bool _mounted = true;
  XFile? _video;
  XFile? _gif;
  VideoPlayerController? controller; // Added controller
  RangeValues? trimRange; // Added trim range
  
  double maxFps = 30.0;
  double fps = 10.0; 
  double scale = 0.25;

  List<String?> mediaInfo = ['0', '0', '0', '0'];
  List<String?> resultInfo = ['0', '0', '0', '0'];

  bool loopInfinite = true;
  int loopTime = 0;

  String algorithm = 'lanczos';
  double maxColor = 64.0;
  String samplingMethod = 'full';
  String dither = 'sierra2_4a';
  bool useRectangle = false;

  bool generating = false;

  Offset cropLU = Offset(0.0, 0.0);
  Offset cropRD = Offset(0.0, 0.0);

  void setPosLU(Offset lu) {
    cropLU = lu;
    notifyListeners();
  }

  void setPosRD(Offset rd) {
    cropRD = rd;
    notifyListeners();
  }

  void setDither(String value) {
    dither = value;
    notifyListeners();
  }
  void setUseRectangle(bool value) {
    useRectangle = value;
    notifyListeners();
  }
  void setMaxColor(double value) {
    maxColor = value;
    notifyListeners();
  }
  void setSamplingMethod(String value) {
    samplingMethod = value;
    notifyListeners();
  }

  void setAlgorithm(String value) {
    algorithm = value;
    notifyListeners();
  }

  void setMediaInfo(List<String?> info) {
    mediaInfo = info;
    notifyListeners();
  }
  
  void setFps(double value) {
    fps = value;
    notifyListeners();
  }

  void setScale(double value) {
    scale = value;
    notifyListeners();
  }

  void setLoopInf(bool value) { // Add this method
    loopInfinite = value;
    if(value) loopTime = 0;
    notifyListeners();
  }

  void setLoopTime(int value) { // Add this method
    loopTime = value;
    notifyListeners();
  }
  

  XFile? get video => _video;
  XFile? get gif => _gif;


  @override
  void dispose() {
    _mounted = false;
    controller?.dispose();
    super.dispose();
  }

  Future<void> setVideo(XFile? file) async {
    if (!_mounted) return;
    _video = file;
    controller?.dispose();
    if(file != null){
      initializeController(file.path);
    }
    notifyListeners();
  }

  void setGif(XFile? file) {
    if (!_mounted) return;
    _gif = file;
    notifyListeners();
  }


  void revertEditedVideo() {
    final videoSize = controller!.value.size;
    cropLU = Offset(0.0, 0.0);
    if (videoSize.width > videoSize.height) {
      cropRD = Offset(400, videoSize.height / videoSize.width * 400);
    } else {
      cropRD = Offset(videoSize.width / videoSize.height * 400, 400);
    }
    updateTrimRange(
        RangeValues(0.0, controller!.value.duration.inMilliseconds.toDouble()));
    fps = 10.0;
    scale = 0.25;
    loopInfinite = true;
    loopTime = 0;

    algorithm = 'lanczos';
    maxColor = 64.0;
    samplingMethod = 'full';
    dither = 'sierra2_4a';
    useRectangle = false;


    notifyListeners();
  }

  // Initialize the controller
  Future<void> initializeController(String path) async {
    controller = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        final videoSize = controller!.value.size;
        cropLU = Offset(0.0, 0.0);
        if (videoSize.width > videoSize.height) {
          cropRD = Offset(400, videoSize.height / videoSize.width * 400);
        } else {
          cropRD = Offset(videoSize.width / videoSize.height * 400, 400);
        }
        updateTrimRange(RangeValues(
            0.0, controller!.value.duration.inMilliseconds.toDouble()));
        notifyListeners();
      });
  }

  // Update trim range
  void updateTrimRange(RangeValues range) {
    trimRange = range;
    notifyListeners();
  }

  Future<void> generateGif() async {
    generating = true;
    if (_video == null) return;
    String videoPath = _video!.path;
    String outputPath = '${(await getApplicationDocumentsDirectory()).path}/output_${DateTime.now().millisecondsSinceEpoch}.gif';
    final videoSize = controller!.value.size;
    Offset RD, LU;
    if (videoSize.width > videoSize.height) {
      RD = Offset(cropRD.dx / 400 * videoSize.width, cropRD.dy / 400 * videoSize.width);
      LU = Offset(cropLU.dx / 400 * videoSize.width, cropLU.dy / 400 * videoSize.width);
    } else {
      RD = Offset(cropRD.dx / 400 * videoSize.height, cropRD.dy / 400 * videoSize.height);
      LU = Offset(cropLU.dx / 400 * videoSize.height , cropLU.dy / 400 * videoSize.height);
    }

    await generateGifFromVideo(
      videoPath: videoPath,
      outputPath: outputPath,
      fps: fps,
      scale: scale,
      loopInfinite: loopInfinite,
      loopTime: loopTime,
      algorithm: algorithm,
      trimRange: trimRange,
      samplingMethod: samplingMethod,
      dither: dither,
      maxColor: maxColor,
      useRectangle: useRectangle,
      cropLU: LU,
      cropRD: RD,
    );
    resultInfo = await getMediaInfo(outputPath);
    setGif(XFile(outputPath));
    generating = false;
  }
}