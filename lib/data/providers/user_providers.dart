import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final userStateProvider =
//     StreamProvider<User?>((ref) => Supabase.instance.client.auth.userChanges());
//
// final userNameProvider = Provider<String>((ref) {
//   final User? user = ref.watch(userStateProvider).asData?.value;
//   if (user?.displayName != null) {
//     final splitedName = user!.displayName!.split(" ");
//     return splitedName.first ?? "";
//   } else {
//     return "";
//   }
// });
//
// final userFullNameProvider = Provider<String>((ref) {
//   final User? user = ref.watch(userStateProvider).asData?.value;
//   return user?.displayName ?? "";
// });
//
// final userImageProvider = Provider<String?>((ref) {
//   final User? user = ref.watch(userStateProvider).asData?.value;
//   return user?.photoURL;
// });
//
// final userProfileProvider = StreamProvider.autoDispose<UserModel?>((ref) {
//   final userRepo = ref.watch(userServiceProvider);
//   return userRepo.watchProfile(FirebaseAuth.instance.currentUser!.uid);
// });
// //
// // final userProfileProvider = FutureProvider.autoDispose<UserModel?>((ref) {
// //   final userRepo = ref.watch(userServiceProvider);
// //   return userRepo.getUserProfile(FirebaseAuth.instance.currentUser!.uid);
// // });
//
// final userProfileOnceProvider =
//     FutureProvider.family.autoDispose<UserModel?, String>((ref, uid) {
//   final userService = ref.watch(userServiceProvider);
//   return userService.getProfile(uid);
// });
//
// final otherUerProfileProvider =
//     StreamProvider.family.autoDispose<UserModel?, String>((ref, uid) {
//   final userService = ref.watch(userServiceProvider);
//   return userService.watchProfile(uid);
// });
