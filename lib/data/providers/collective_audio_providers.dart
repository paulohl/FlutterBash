import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/call_mode_model.dart';
import '../services/collective_audio_service.dart';

final collectiveAudioProvider =
    FutureProvider.family<List<CallModeModel>, int>((ref, levelId) {
  final levelService = ref.watch(collectiveAudioServiceProvider);
  return levelService.getLevelCollectiveAudio(levelId);
});
