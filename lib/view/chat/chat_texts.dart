import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatTextsScreen extends StatefulWidget {
  final String conversationId;

  const ChatTextsScreen({super.key, required this.conversationId});

  @override
  State<ChatTextsScreen> createState() => _ChatTextsScreenState();
}

class _ChatTextsScreenState extends State<ChatTextsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        child: Column(
          children: [
            SafeArea(bottom: false, child: SizedBox(height: 12.h)),
            Text('Chat'),
          ],
        ),
      ),
    );
  }
}
