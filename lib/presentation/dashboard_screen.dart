import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:minivid/presentation/screens/bgm_music.dart';
import 'package:minivid/presentation/screens/drawing_screen.dart';
import 'package:minivid/presentation/screens/generated_video_screen.dart';
import 'package:minivid/presentation/screens/homescrren/add_screen.dart';
import 'package:minivid/utils/widget/custom_appbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.black54,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.black87,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: currentUser?.photoURL != null
                          ? NetworkImage(currentUser!.photoURL!)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentUser?.displayName ?? 'User Name',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.email ?? 'user@example.com',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                            onPressed: () {},
                            child: Text('Edit Profile')),
                        SizedBox(width: 12),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                            onPressed: () {},
                            child: Text('Share Profile')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading:
                        const Icon(LucideIcons.download, color: Colors.white),
                    title: Text(
                      'My Generated Videos',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return GeneratedVideoScreen();
                      }));
                    },
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inbox, color: Colors.white),
                    title: Text(
                      'Inbox',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    onTap: () {
                     
                    },
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.notifications, color: Colors.white),
                    title: Text(
                      'Notifications',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    onTap: () {},
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.draw, color: Colors.white),
                    title: Text(
                      'Canvas to video Generate',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    onTap: () {
                       Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return DrawingScreen();
                      }));
                    },
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
