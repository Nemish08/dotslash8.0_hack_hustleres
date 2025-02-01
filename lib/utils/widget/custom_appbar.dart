import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minivid/presentation/dashboard_screen.dart';
import 'package:minivid/presentation/screens/onboarding/splash_screen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function()? onProfileTap;

  const CustomAppBar({Key? key, this.onProfileTap}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut(); // Ensure user can pick a new account

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => SplashScreen()), // Redirect to login
        (route) => false, // Clear navigation stack
      );
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "Profile Options",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "What would you like to do?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            Tooltip(
              message: 'Logout',
              child: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _logout();
                },
                icon: Icon(LucideIcons.logOut, color: Colors.red),
              ),
            ),
            Tooltip(
              message: 'Dashboard',
              child: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(),
                    ),
                  );
                },
                icon: Icon(LucideIcons.layoutDashboard, color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        children: [
          Icon(
            Icons.videocam_outlined,
            color: Colors.white,
            size: 30,
          ),
          Text(
            "MiniVid AI",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),
          ),
        ],
      ),
      actions: [
        SizedBox(width: 16),
        GestureDetector(
          onTap: widget.onProfileTap ?? _showProfileDialog,
          child: firebaseUser?.photoURL != null
              ? CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(firebaseUser!.photoURL!),
                )
              : CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 14,
                  backgroundImage: AssetImage('assets/images/user.png'),
                ),
        ),
        SizedBox(width: 16),
        Icon(Icons.menu, color: Colors.white),
        SizedBox(width: 16),
      ],
    );
  }
}
