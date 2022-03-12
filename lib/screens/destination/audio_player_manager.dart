import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerManager {
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  late AudioPlayer _audioPlayer;

  AudioPlayerManager(String url) {
    _init(url);
  }

  void _init(String url) async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setUrl(url);
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }
