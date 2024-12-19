// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final audioPlayerProvider = Provider.autoDispose((ref) {
  final audioPlayer = AudioPlayer();
  // audioPlayer.addListener(() {});

  ref.onDispose(() {
    audioPlayer.dispose();
  });
  return audioPlayer;
});

final audioPlayerOnceProvider = Provider.autoDispose((ref) {
  final audioPlayer = AudioPlayer();
  // audioPlayer.addListener(() {});

  ref.onDispose(() {
    audioPlayer.dispose();
  });
  return audioPlayer;
});

final commonAudioPlayerOnceProvider = Provider.autoDispose((ref) {
  final audioPlayer = AudioPlayer();
  // audioPlayer.addListener(() {});

  ref.onDispose(() {
    audioPlayer.dispose();
  });
  return audioPlayer;
});

extension AudioPlayerExtensions on AudioPlayer {
  Future<void> playAndCache(String url) async {
    try {
      // if (playing) {
      await stop();
      // }
      final file = await DefaultCacheManager().getFileFromCache(url);
      if (file == null) {
        await setUrl(url);
        DefaultCacheManager().downloadFile(url);
        debugPrint("played from url");
        await play();
      } else {
        debugPrint("played from cached");
        // await setAsset(file.file.path);
        await setAudioSource(AudioSource.file(file.file.path));
        await play();
        await stop();
      }
    } on PlayerException catch (e) {
      // iOS/macOS: maps to NSError.code
      // Android: maps to ExoPlayerException.type
      // Web: maps to MediaError.code
      // Linux/Windows: maps to PlayerErrorCode.index
      debugPrint("Error code: ${e.code}");
      // iOS/macOS: maps to NSError.localizedDescription
      // Android: maps to ExoPlaybackException.getMessage()
      // Web/Linux: a generic message
      // Windows: MediaPlayerError.message
      debugPrint("Error message: ${e.message}");
    } on PlayerInterruptedException catch (e) {
      // This call was interrupted since another audio source was loaded or the
      // player was stopped or disposed before this audio source could complete
      // loading.
      debugPrint("Connection aborted: ${e.message}");
    } catch (e) {
      // Fallback for all other errors
      debugPrint('An error occured: $e');
    }
  }
}
