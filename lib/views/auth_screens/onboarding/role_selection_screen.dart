import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/model/role.dart';
import 'package:odrive_restaurant/providers/role_provider.dart';
import 'package:odrive_restaurant/views/auth_screens/onboarding/coming_soon_screen.dart';
import 'package:odrive_restaurant/views/auth_screens/onboarding/widget/role_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<UserRole> _roles = [
    UserRole.restaurant,
    UserRole.market,
    UserRole.supermarket,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        /* leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ), */
        title: Text(
          l10n.chooseYourRole,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                return RoleCard(
                  role: _roles[index],
                  onTap: () => _handleRoleSelection(_roles[index]),
                );
              },
            ),
          ),

          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _roles.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? const Color(0xFF4A7C59)
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _handleRoleSelection(UserRole role) {
    context.read<RoleProvider>().selectRole(role);

    if (role.isAvailable) {
      Get.offAll(() => const SignInScreen());
      //context.go('/login/${role.name.toLowerCase()}');
    } else {
      Get.off(() => ComingSoonScreen(
            role: role,
          ));

      //context.go('/coming-soon/${role.name.toLowerCase()}');
    }
  }
}
