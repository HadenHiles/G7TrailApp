import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class AudioPlayerManager {
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  late AssetsAudioPlayer _audioPlayer;

  AudioPlayerManager(String url, bool? autoPlay) {
    _audioPlayer = AssetsAudioPlayer();
    init(url, autoPlay != null ? autoPlay : false);
  }

  void init(String url, bool autoPlay) async {
    try {
      await _audioPlayer.open(
        Audio.network(
          url,
          metas: Metas(
            title: "Beacon Audio Tour",
            artist: "Group of Seven Lake Superior Trail",
            album: "G7 Trail Audio Tour",
            image: MetasImage.asset("assets/images/app-icon.png"),
          ),
        ),
        autoStart: autoPlay,
        showNotification: true,
      );
    } catch (t) {
      //mp3 unreachable
      log("\nError loading audio file: \n" + t.toString());
    }
  }

  void play() {
    _audioPlayer.play();
    buttonNotifier.value = ButtonState.playing;
  }

  void pause() {
    _audioPlayer.pause();
    buttonNotifier.value = ButtonState.paused;
  }

  void stop() {
    _audioPlayer.stop();
    buttonNotifier.value = ButtonState.paused;
  }

  Duration currentDuration() {
    return _audioPlayer.current.value!.audio.duration;
  }

  Stream<Duration> position() {
    return _audioPlayer.currentPosition;
  }

  void seek(Duration pos) {
    _audioPlayer.seek(pos);
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
