import 'package:flutter/material.dart';
import 'package:gif_creator/home.dart';
import 'package:provider/provider.dart';
import 'package:gif_creator/providers/video_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gif_creator/src/info.dart';

class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key});

  Future<void> _pickFile(BuildContext context) async {
    
    final ImagePicker picker = ImagePicker();
    final XFile? result = await picker.pickVideo(source: ImageSource.gallery);
    if (result != null) {
      if (!context.mounted) return;
      await context.read<VideoState>().setVideo(result);
      var info = await getMediaInfo(result.path);
      if (!context.mounted) return;
      context.read<VideoState>().setMediaInfo(info);
      // Find the nearest HomeState and change page
      if(!context.mounted) return;
      HomeState? homeState = context.findAncestorStateOfType<HomeState>();
      homeState?.setPage(1); // Navigate to edit screen
    }

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: () => _pickFile(context),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Select Video'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<VideoState>().setVideo(null);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Clear Selection'),
          ),
          const SizedBox(height: 20),
          Consumer<VideoState>(
            builder: (context, state, child) {
              return state.video != null
                  ? Column(
                    children: [
                      Text('Selected: ${state.video!.name}'),
                      const SizedBox(height: 20),
                      FutureBuilder<int>(
                        future: state.video!.length(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final sizeMB = snapshot.data! / 1000000;
                            return Text("Size: ${sizeMB.toStringAsPrecision(3)} MB");
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      Column(
                          children: [
                            Text('Frame rate: ${state.mediaInfo[0]}'),
                            Text('Height: ${state.mediaInfo[1]}'),
                            Text('Width: ${state.mediaInfo[2]}'),
                            Text('Codec: ${state.mediaInfo[3]}'),
                          ],
                      )
                    ],
                  )
                  : const Text('No video selected');
            },
          ),
        ],
      ),
    );
  }
}
