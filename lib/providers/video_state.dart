import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class VideoState extends ChangeNotifier {
  bool _mounted = true;
  XFile? _video;
  XFile? _gif;
  XFile? _editedVideo;

  XFile? get video => _video;
  XFile? get gif => _gif;
  XFile? get editedVideo => _editedVideo;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void setVideo(XFile? file) {
    if (!_mounted) return;
    _video = file;
    _editedVideo = file;
    notifyListeners();
  }

  void setGif(XFile? file) {
    if (!_mounted) return;
    _gif = file;
    notifyListeners();
  }

  void setEditedVideo(XFile? file) {
    if (!_mounted) return;
    _editedVideo = file;
    notifyListeners();
  }

  void revertEditedVideo() {
    if (!_mounted) return;
    _editedVideo = _video;
    notifyListeners();
  }
}