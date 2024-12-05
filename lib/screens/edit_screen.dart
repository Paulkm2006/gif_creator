import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gif_creator/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:gif_creator/providers/video_state.dart';
import 'package:video_player/video_player.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoState>(
      builder: (context, state, child) {
        return state.editedVideo != null
            ? Column(
              children: [
                  Container(
                  width: double.infinity,
                  color: Colors.lightBlue,
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Working on: ${state.video!.name}',
                    style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Editor(state.editedVideo!),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.red[400]),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      onPressed: (){
                        state.revertEditedVideo();
                      }, 
                      icon: const Icon(Icons.undo),
                      label: const Text('Revert'),
                    ),
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.green[400]),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      onPressed: () {
                        // Find the nearest HomeState and change page
                        HomeState? homeState = context.findAncestorStateOfType<HomeState>();
                        homeState?.setPage(2); // Navigate to result screen
                      },
                      icon: const Icon(Icons.gif_box),
                      label: const Text('Create GIF'),
                    ),
                  ],
                ),
              ],
            )
            : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.question_mark),
                  Text('No video selected'),
                ],
              ),
            );
      },
    );
  }
}

class Editor extends StatefulWidget {

  final XFile video;
  const Editor(this.video, {super.key});


  @override
  State<Editor> createState() => EditorState();
}

class EditorState extends State<Editor> {

  late VideoPlayerController _controller;
  Duration _currentPosition = Duration.zero; // Added variable to track current position

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.video.path))
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(true);
    _controller.addListener(() { // Added listener to update currentPosition
      setState(() {
        _currentPosition = _controller.value.position;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        SizedBox(
          width: 300,
          height: 300, // Increased height to accommodate slider
          child: Scaffold(
            body:Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
            Slider( // Added Slider widget
              value: _currentPosition.inMilliseconds.toDouble(),
              min: 0.0,
              max: _controller.value.duration.inMilliseconds.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _controller.seekTo(Duration(milliseconds: value.toInt()));
                });
              },
            ),
            Text(
              '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}:${(_currentPosition.inMilliseconds % 1000).toString().padLeft(3, '0')}',
            ),
          ],
        ),
      ],
    );
  }
}