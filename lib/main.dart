import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'splash_page.dart';
import 'widgets/mini_player.dart';
import 'audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.instance.player.setAudioSource(
    ConcatenatingAudioSource(children: []),
  );
  runApp(const LectureApp());
}

class LectureApp extends StatelessWidget {
  const LectureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lecture App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE0E0E0),
          thickness: 0.5,
          space: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Colors.deepOrange,
          inactiveTrackColor: Color(0xFFFFCCBC),
          thumbColor: Colors.deepOrange,
          overlayColor: Color(0x33FF7043),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // ignore: deprecated_member_use
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            ValueListenableBuilder<String?>(
              valueListenable: AudioManager.instance.currentLectureId,
              builder: (context, value, _) {
                if (value == null) return const SizedBox.shrink();
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: const MiniPlayer(),
                );
              },
            ),
          ],
        );
      },
      home: const SplashPage(),
    );
  }
}
