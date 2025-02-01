import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:minivid/presentation/screens/homescrren/setting_screen.dart';
import 'package:minivid/presentation/screens/onboarding/splash_screen.dart';
import 'package:minivid/utils/widget/add_screen_widget.dart';
import 'package:minivid/utils/widget/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  int _currentPageIndex = 1;

  final List<Widget> _pages = [
    const HomeScreenWidgeta(),
    const AddScreenWidget(),
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {
    {
      setState(() {
        _currentPageIndex = index;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut(); // Ensure user can pick a new account

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => SplashScreen()), // Redirect to login
      (route) => false, // Clear navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    firebase_auth.User? firebaseUser =
        firebase_auth.FirebaseAuth.instance.currentUser;
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentPageIndex],
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  backgroundColor: Colors.black,
                  currentIndex: _currentPageIndex,
                  selectedItemColor: Colors.teal,
                  unselectedItemColor: Colors.grey.shade100,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(LucideIcons.home),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(LucideIcons.plus),
                      label: '',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(LucideIcons.moreVertical),
                      label: '',
                    ),
                  ],
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
