import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool showBackButton;
  final bool showNotificationIcon;
  final bool showNotificationDot;
  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = false,
    this.showBackButton = false,
    this.showNotificationIcon = true,
    this.showNotificationDot = false,
    this.onBackTap,
    this.onNotificationTap,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,

      // 👇 BACK BUTTON CONTROL
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBackTap ?? () => Navigator.pop(context),
      )
          : null,

      title: Text(
        title,
        style:  TextStyle(
          color:AppColors.textColor1,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),

      actions: [
        if (showNotificationIcon)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                ),
                onPressed: onNotificationTap,
              ),
              if (showNotificationDot)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
