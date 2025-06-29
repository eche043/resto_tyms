import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odrive_restaurant/common/config/api.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget {
  final String leadingImageAsset;
  final String title;
  final String? smsImageAsset;
  final String? notificationImageAsset;

  const CustomAppBar({
    required this.leadingImageAsset,
    required this.title,
    this.smsImageAsset,
    this.notificationImageAsset,
    super.key,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImageUrl();
  }

  Future<void> _loadProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('userAvatar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: UniqueKey(),
      top: MediaQuery.of(context).size.height * 0.04,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 40 + MediaQuery.of(context).padding.top,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (Navigator.canPop(context))
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back),
              )
            else
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Image.asset(
                  widget.leadingImageAsset,
                  height: 18,
                  width: 21,
                ),
              ),
            10.widthBox,
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontSize: 18,
              ),
            ),
            const Spacer(),
            /*if (widget.smsImageAsset != null) ...[
              8.widthBox,
              InkWell(
                onTap: () {
                  Get.to(() => const ChatScreen(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 500));
                },
                child: Image.asset(
                  widget.smsImageAsset!,
                  height: 24,
                  width: 24,
                ),
              ),
            ], */
            8.widthBox,
            if (widget.notificationImageAsset != null)
              InkWell(
                onTap: () {
                  Get.to(() => const NotificationsScreen(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 500));
                },
                child: Image.asset(
                  widget.notificationImageAsset!,
                  height: 24,
                  width: 24,
                ),
              ),
            8.widthBox,
            InkWell(
              onTap: () {
                Get.to(() => const ProfileEditScreen(),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 500));
              },
              child: CircleAvatar(
                  backgroundColor: white,
                  maxRadius: 25,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage("$serverImages/$profileImageUrl")
                          as ImageProvider<Object>
                      : const AssetImage(dpIcon) as ImageProvider<Object>),
            ),
          ],
        ),
      ),
    );
  }
}
