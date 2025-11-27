import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermissionDialog extends StatelessWidget {
  const StoragePermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Storage Permission Required'),
      content: const Text(
        'This app needs access to storage to play audio files. '
        'Please grant storage permission in app settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Request both permissions - the system will show appropriate dialog
            // based on Android version
            final audioStatus = await Permission.audio.request();
            final storageStatus = await Permission.storage.request();

            if (audioStatus.isGranted || storageStatus.isGranted) {
              if (context.mounted) Navigator.pop(context, true);
            } else {
              await openAppSettings();
            }
          },
          child: const Text('Open Settings'),
        ),
      ],
    );
  }
}
