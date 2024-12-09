import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:gif_creator/home.dart';
import 'package:gif_creator/providers/video_state.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return context.watch<VideoState>().generating
      ? Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red[400]),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              onPressed: () {
                context.read<VideoState>().cancelGeneration();
                context.read<VideoState>().cancelGeneration();
                        HomeState? homeState =
                            context.findAncestorStateOfType<HomeState>();
                homeState?.setPage(1);
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
            ),
            ]),
        ),
      )
      : context.watch<VideoState>().generationError
        ? Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red,),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(width: 300,
                      child: Text(context.watch<VideoState>().generationErrorMessage, overflow: TextOverflow.visible,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red[400]),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  onPressed: () {
                    context.read<VideoState>().cancelGeneration();
                    HomeState? homeState =
                              context.findAncestorStateOfType<HomeState>();
                    homeState?.setPage(1);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Return'),
                ),
              ],
            ),
          ),
        )
        :
      context.watch<VideoState>().gif == null
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.question_mark),
                Text('No GIF generated'),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Result'),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Image.file(
                      File(context.watch<VideoState>().gif!.path),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<int>(
                  future: context.watch<VideoState>().gif!.length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final sizeMB = snapshot.data! / 1000000;
                      return Text(
                          "Size: ${sizeMB.toStringAsPrecision(3)} MB");
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                Column(
                      children: [
                        Text('Frame rate: ${context.watch<VideoState>().resultInfo[0]}'),
                        Text('Height: ${context.watch<VideoState>().resultInfo[1]}'),
                        Text('Width: ${context.watch<VideoState>().resultInfo[2]}'),
                      ],
                  ),
                const SizedBox(height: 20),
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
                        context.read<VideoState>().setGif(null);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                    Consumer<VideoState>(
                      builder: (context, videoState, child) {
                      return  ElevatedButton.icon(
                        label: const Text('Save GIF'),
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          final gifPath = videoState.gif!.path;
                          final hasAccess = await Gal.hasAccess(toAlbum: true);
                          if (!hasAccess) {
                            await Gal.requestAccess(toAlbum: true);
                            return;
                          }
                          try {
                              await Gal.putImage(gifPath);
                              if(!context.mounted) return;  
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('GIF saved to gallery!'),
                                ),
                              );
                            } on GalException catch (e) {
                              if(!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save GIF: ${e.toString()}'),
                                ),
                              );
                            }
                        },
                      );
                      },
                    )
                  ],
                ),
              ],
            ),
          );
        }
}
