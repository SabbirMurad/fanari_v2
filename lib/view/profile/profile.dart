import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String user_id;

  const ProfileScreen({super.key, required this.user_id});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SizedBox(
        child: SingleChildScrollView(
          child: Column(children: [Text('Profile')]),
        ),
      ),
    );
  }
}
