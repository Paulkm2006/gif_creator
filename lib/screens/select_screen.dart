import 'package:flutter/material.dart';
import 'package:gif_creator/home.dart';
import 'package:provider/provider.dart';
import 'package:gif_creator/providers/video_state.dart';
import 'package:image_picker/image_picker.dart';

class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key});

  Future<void> _pickFile(BuildContext context) async {

    final ImagePicker picker = ImagePicker();
    final XFile? result = await picker.pickVideo(source: ImageSource.gallery);
    if (result != null) {
      if (!context.mounted) return;
      context.read<VideoState>().setVideo(result);
      // Find the nearest HomeState and change page
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
                  ? Text('Selected: ${state.video!.name}')
                  : const Text('No video selected');
            },
          ),
        ],
      ),
    );
  }
}
