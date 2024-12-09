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
  bool generationError = false;
  String generationErrorMessage = '';

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
    if (file==null){
      File(_gif!.path).delete();
    }
    _gif = file;
    notifyListeners();
  }


  void revertEditedVideo() {
    final videoSize = controller!.value.size;
    cropLU = Offset(0.0, 0.0);
    if (videoSize.width > videoSize.height) {
      cropRD = Offset(300, videoSize.height / videoSize.width * 300);
    } else {
      cropRD = Offset(videoSize.width / videoSize.height * 300, 300);
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
          cropRD = Offset(300, videoSize.height / videoSize.width * 300);
        } else {
          cropRD = Offset(videoSize.width / videoSize.height * 300, 300);
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

  void cancelGeneration() {
    cancelGifGeneration();
    generating = false;
    generationError = true;
    generationErrorMessage = 'Cancelled';
    notifyListeners();
  }

  Future<void> generateGif() async {
    generating = true;
    generationError = false;
    if (_video == null) return;
    String videoPath = _video!.path;
    String outputPath = '${(await getApplicationDocumentsDirectory()).path}/output_${DateTime.now().millisecondsSinceEpoch}.gif';
    final videoSize = controller!.value.size;
    final rotation = controller!.value.rotationCorrection;
    Offset realRD, realLU;
    if (videoSize.width > videoSize.height) {
      realRD = Offset(cropRD.dx / 300 * videoSize.width, cropRD.dy / 300 * videoSize.width);
      realLU = Offset(cropLU.dx / 300 * videoSize.width, cropLU.dy / 300 * videoSize.width);
    } else {
      realRD = Offset(cropRD.dx / 300 * videoSize.height, cropRD.dy / 300 * videoSize.height);
      realLU = Offset(cropLU.dx / 300 * videoSize.height , cropLU.dy / 300 * videoSize.height);
    }

    String? res = await generateGifFromVideo(
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
      rotation: rotation,
      cropLU: realLU,
      cropRD: realRD,
    );
    if (res != null) {
      generationError = true;
      generationErrorMessage = res;
      generating = false;
      notifyListeners();
      return;
    }
    resultInfo = await getMediaInfo(outputPath);
    setGif(XFile(outputPath));
    generating = false;
  }
}