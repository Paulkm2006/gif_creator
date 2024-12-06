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
        return state.video != null
            ? Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Editor(state.video!),
                          const SizedBox(height: 10),
                          const ParametersTab(),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.red[400]),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                ),
                                onPressed: () {
                                  state.revertEditedVideo();
                                  state.setScale(1.0);
                                  state.setFps(10.0);
                                  state.setLoopInf(true);
                                },
                                icon: const Icon(Icons.undo),
                                label: const Text('Revert'),
                              ),
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.green[400]),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                ),
                                onPressed: () {
                                  // Find the nearest HomeState and change page
                                  HomeState? homeState =
                                      context.findAncestorStateOfType<HomeState>();
                                  state.generateGif();
                                  homeState?.setPage(2); // Navigate to result screen
                                },
                                icon: const Icon(Icons.gif_box),
                                label: const Text('Create GIF'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
  double? fps; // Existing line

  @override
  void initState() {
    super.initState();
    final videoState = Provider.of<VideoState>(context, listen: false);
    if (videoState.controller == null) {
      videoState.initializeController(widget.video.path);
    }
    // Initialize trim range if not set
    if (videoState.trimRange == null && videoState.controller != null) {
      videoState.trimRange = RangeValues(
        0.0,
        videoState.controller!.value.duration.inMilliseconds.toDouble(),
      );
    }
    // Add listener to handle position updates
    videoState.controller!.addListener(_positionListener);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    super.dispose();
  }

  void _positionListener() {
    if (!mounted) return;
    final videoState = Provider.of<VideoState>(context, listen: false);
    final position = videoState.controller!.value.position;
    if (position > Duration(milliseconds: videoState.trimRange!.end.toInt())) {
      videoState.controller!.seekTo(Duration(milliseconds: videoState.trimRange!.start.toInt()));
      if (videoState.controller!.value.isPlaying) {
        videoState.controller!.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoState>(
      builder: (context, state, child) {
        if (state.controller == null || !state.controller!.value.isInitialized) {
          return const CircularProgressIndicator();
        }
        return Column(
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Scaffold(
                body: Center(
                  child: AspectRatio(
                    aspectRatio: state.controller!.value.aspectRatio,
                    child: VideoPlayer(state.controller!),
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
                      if (state.controller!.value.isPlaying) {
                        state.controller!.pause();
                      } else {
                        state.controller!.play();
                      }
                    });
                  },
                  child: ValueListenableBuilder(
                    valueListenable: state.controller!,
                    builder: (context, VideoPlayerValue value, child) {
                      return Icon(
                        value.isPlaying ? Icons.pause : Icons.play_arrow,
                      );
                    },
                  ),
                ),
                RangeSlider(
                  values: state.trimRange!,
                  min: 0.0,
                  max: state.controller!.value.duration.inMilliseconds.toDouble(),
                  onChangeEnd: (values) {
                    state.updateTrimRange(values);
                    state.controller!.seekTo(Duration(milliseconds: values.start.toInt()));
                  },
                  onChangeStart: (_){
                    state.controller!.pause();
                  },
                  onChanged: (values) {
                    if (state.trimRange!.start != values.start) {
                      state.controller!.seekTo(Duration(milliseconds: values.start.toInt()));
                    } else {
                      state.controller!.seekTo(Duration(milliseconds: values.end.toInt()));
                    }
                    state.updateTrimRange(values);
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: state.controller!,
                  builder: (context, VideoPlayerValue value, child) {
                    final minutes = value.position.inMinutes.toString().padLeft(2, '0');
                    final seconds = (value.position.inSeconds % 60).toString().padLeft(2, '0');
                    final milliseconds = (value.position.inMilliseconds % 1000).toString().padLeft(3, '0');
                    return Text(
                      '$minutes:$seconds:$milliseconds',
                    );
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${double2String(state.trimRange!.start)} - ${double2String(state.trimRange!.end)} / ${double2String(state.trimRange!.end - state.trimRange!.start)}',
                ),
              ],
            ),
            // Handle looping
          ],
        );
      },
    );
  }
}

String double2String(double value) {
  final dur = Duration(milliseconds: value.toInt());
  return '${dur.inMinutes}:${(dur.inSeconds % 60).toString().padLeft(2, '0')}:${(dur.inMilliseconds % 1000).toString().padLeft(3, '0')}';
}

class ParametersTab extends StatelessWidget {
  const ParametersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoState>(
      builder: (context, state, child) {
        final maxFps = double.parse(state.mediaInfo[0]!);
        return Form(
          child: Column(
            
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.autofps_select),
                  const Text('FPS'),
                  Slider.adaptive(
                    value: state.fps>maxFps? maxFps : state.fps,
                    onChanged: (value) {
                      state.setFps(value);
                    },
                    min: 1.0,
                    max: maxFps,
                    divisions: 29,
                    label: state.fps.toStringAsFixed(0),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.aspect_ratio),
                  const Text('Scale'),
                  Slider.adaptive(
                    value: state.scale,
                    onChanged: (value) {
                      state.setScale(value);
                    },
                    min: 0.05,
                    max: 1.0,
                    divisions: 19,
                    label: state.scale.toStringAsFixed(2),
                  ),
                ],
              ),
              SizedBox(
                width: 305.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.loop),
                    const Text('Loop'),
                    SizedBox(
                      width: 150, 
                      child: Slider.adaptive(
                        value: state.loopTime.toDouble(),
                        onChanged: (value) {
                          state.setLoopTime(value.toInt());
                        },
                        min: 0,
                        max: state.loopInfinite ? 0 : 5,
                        divisions: 5,
                        label: state.loopTime.toString(),
                      ),
                    ),
                    const Text("Infinite"),
                    Checkbox.adaptive(
                      value: state.loopInfinite,
                      onChanged: (value) {
                        state.setLoopInf(value!);
                      },
                    )
                  ],
                ),
              ),
              ExpansionTile(
                title: const Text('Advanced'), 
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.settings),
                      const Text('Algorithm'),
                      DropdownButton<String>(
                        value: state.algorithm,
                        onChanged: (value) {
                          state.setAlgorithm(value!);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'lanczos',
                            child: Text('Lanczos'),
                          ),
                          DropdownMenuItem(
                            value: 'bilinear',
                            child: Text('Bilinear'),
                          ),
                          DropdownMenuItem(
                            value: 'bicubic',
                            child: Text('Bicubic'),
                          ),
                          DropdownMenuItem(
                            value: 'neighbor',
                            child: Text('Neighbor'),
                          ),
                          DropdownMenuItem(
                            value: 'area',
                            child: Text('Area'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.palette),
                      const Text('Palette colors'),
                      Slider.adaptive(
                        value: state.maxColor,
                        onChanged: (value) {
                          state.setMaxColor(value);
                        },
                        min: 32.0,
                        max: 256.0,
                        divisions: 7,
                        label: state.maxColor.toStringAsFixed(0),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.colorize),
                      const Text('Sampling'),
                      DropdownButton<String>(
                        value: state.samplingMethod,
                        onChanged: (value) {
                          state.setSamplingMethod(value!);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'full',
                            child: Text('Full'),
                          ),
                          DropdownMenuItem(
                            value: 'diff',
                            child: Text('Diff'),
                          ),
                          DropdownMenuItem(
                            value: 'single',
                            child: Text('Single'),
                          ),
                        ],
                      ),
                    ],
                  ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.equalizer),
                        const Text('Dither'),
                        DropdownButton<String>(
                          value: state.dither,
                          onChanged: (value) {
                            state.setDither(value!);
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'sierra2_4a',
                              child: const Text('sierra2_4a'),
                            ),
                            DropdownMenuItem(
                              value: 'sierra3',
                              child: const Text('sierra3'),
                            ),
                            DropdownMenuItem(
                              value: 'bayer',
                              child: const Text('bayer'),
                            ),
                            DropdownMenuItem(
                              value: 'floyd_steinberg',
                              child: const Text('floyd_steinberg'),
                            ),
                          ],
                        ),
                        const Text('Use rectangle'),
                        Checkbox(
                          value: state.useRectangle,
                          onChanged: (value) {
                            state.setUseRectangle(value!);
                          },
                        ),
                      ],
                    )
                    ],
                  )
                ],
          )
        );
    });
  }
}