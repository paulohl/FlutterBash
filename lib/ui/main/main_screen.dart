import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/ui/main/tabs/calender/calender_screen.dart';
import 'package:xueli/ui/main/tabs/home/home_screen.dart';
import 'package:xueli/ui/main/tabs/schedule/schedule_screen.dart';
import 'package:xueli/ui/main/tabs/setting/settings_screen.dart';

import '../../constants/app_colors.dart';

// final notificationProvider = FutureProvider.autoDispose<String>((ref) {
//   final deviceProvide = ref.watch(deviceHelperProvider);
//   return deviceProvide.getDeviceFCMToken();
// });

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = useState(0);
    // ref.listen<AsyncValue<String>>(notificationProvider, (previous, next) {
    //   if (next.asData?.value != null) {
    //     ref.read(userServiceProvider).updateToken(
    //         next.asData!.value, FirebaseAuth.instance.currentUser!.uid);
    //   }
    // });
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Colors.white,
                Color(0xFFF9FBFF),
                Color(0xFFF5F9FF)
              ])),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: currentPosition.value,
                  children: const [
                    HomeScreen(),
                    ScheduleScreen(),
                    CalenderScreen(),
                    SettingsScreen(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset:
                            const Offset(0, 4), // changes position of shadow
                      ),
                    ],
                  ),
                  child: BottomNavigation(
                    currentPosition: currentPosition.value,
                    badge: 0,
                    onPressed: (int newPosition) {
                      currentPosition.value = newPosition;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BottomNavigation extends StatelessWidget {
  final int currentPosition;
  final Function(int) onPressed;
  final int badge;

  const BottomNavigation({
    Key? key,
    required this.currentPosition,
    required this.onPressed,
    this.badge = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BottomNavItem(
          label: context.tr(LocaleKeys.home),
          image: Assets.imagesHomeUnselected,
          selectedIcon: Assets.imagesHomeSelected,
          isSelected: currentPosition == 0,
          onTap: () {
            onPressed(0);
          },
        ),
        BottomNavItem(
          label: context.tr(LocaleKeys.schedule),
          image: Assets.imagesScheduleUnselected,
          selectedIcon: Assets.imagesScheduleSelected,
          isSelected: currentPosition == 1,
          badge: badge,
          onTap: () {
            onPressed(1);
          },
        ),
        BottomNavItem(
          label: context.tr(LocaleKeys.calender),
          image: Assets.imagesCalenderUnselected,
          selectedIcon: Assets.imagesCalendarSelected,
          isSelected: currentPosition == 2,
          onTap: () {
            onPressed(2);
          },
        ),
        BottomNavItem(
          label: context.tr(LocaleKeys.profile),
          image: Assets.imagesProfileUnselected,
          selectedIcon: Assets.imagesProfileSelected,
          isSelected: currentPosition == 3,
          onTap: () {
            onPressed(3);
          },
        ),
      ],
    );
  }
}

class BottomNavItem extends HookConsumerWidget {
  final String label;
  final String selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final String image;
  final int badge;

  BottomNavItem({
    Key? key,
    required this.label,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
    required this.image,
    this.badge = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        isSelected ? selectedIcon : image,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        label,
                        style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFBDB2AB)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
