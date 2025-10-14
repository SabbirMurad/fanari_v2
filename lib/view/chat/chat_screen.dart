import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/view/chat/chat_texts.dart';
import 'package:fanari_v2/view/chat/widgets/conversation_item.dart';
import 'package:fanari_v2/view/chat/widgets/horizontal_options.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Widget _searchWidget() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 40.h,
        margin: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 18.w,
          bottom: 18.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            CustomSvg(
              'assets/icons/search.svg',
              color: AppColors.text,
              width: 20.w,
              height: 20.w,
            ),
            SizedBox(width: 12.w),
            Text(
              'Search ...',
              style: TextStyle(color: AppColors.text, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _skeletons() {
    return [
      ConversationItem.skeleton(context),
      ConversationItem.skeleton(context, textWidth: 240.w),
      ConversationItem.skeleton(context, textWidth: 272.w),
      ConversationItem.skeleton(context, textWidth: 148.w),
      ConversationItem.skeleton(context, textWidth: 240.w),
    ];
  }

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<ConversationModel> _conversations = <ConversationModel>[
    ConversationModel(
      uuid: '1',
      name: 'Group 1',
      image: null,
      online: true,
      texts: [],
      last_seen: 0,
      user_id: '1',
      typing: true,
    ),
    ConversationModel(
      uuid: '2',
      name: 'Group 2',
      image: null,
      online: true,
      texts: [
        TextModel(
          uuid: '1',
          owner: '2',
          conversation_id: '2',
          my_text: true,
          images: [],
          seen_by: [],
          created_at: DateTime.now().microsecondsSinceEpoch,
          videos: [],
          type: TextType.Text,
          text: 'Hello, how are you?',
        ),
      ],
      last_seen: 0,
      user_id: '1',
    ),
    ConversationModel(
      uuid: '3',
      name: 'Group 3',
      image: null,
      online: true,
      texts: [
        TextModel(
          uuid: '1',
          owner: '2',
          conversation_id: '2',
          my_text: true,
          images: [
            ImageModel(
              uuid: 'asdasdasd',
              url:
                  'https://images.pexels.com/photos/1535051/pexels-photo-1535051.jpeg',
              width: 400,
              height: 400,
              provider: AssetImage('assets/images/temp/user.jpg'),
            ),
          ],
          seen_by: [],
          created_at: DateTime.now().microsecondsSinceEpoch,
          videos: [],
          type: TextType.Image,
        ),
        TextModel(
          uuid: '1',
          owner: '2',
          conversation_id: '2',
          my_text: false,
          images: [
            ImageModel(
              uuid: 'asdasdasd',
              url:
                  'https://images.pexels.com/photos/1535051/pexels-photo-1535051.jpeg',
              width: 400,
              height: 400,
              provider: AssetImage('assets/images/temp/user.jpg'),
            ),
            ImageModel(
              uuid: 'asdasdasd',
              url:
                  'https://images.pexels.com/photos/341970/pexels-photo-341970.jpeg',
              width: 400,
              height: 400,
              provider: AssetImage('assets/images/temp/user.jpg'),
            ),
            ImageModel(
              uuid: 'asdasdasd',
              url:
                  'https://images.pexels.com/photos/1832959/pexels-photo-1832959.jpeg',
              width: 400,
              height: 400,
              provider: AssetImage('assets/images/temp/user.jpg'),
            ),
            ImageModel(
              uuid: 'asdasdasd',
              url:
                  'https://images.pexels.com/photos/1468379/pexels-photo-1468379.jpeg',
              width: 400,
              height: 400,
              provider: AssetImage('assets/images/temp/user.jpg'),
            ),
            ImageModel(
              uuid: 'asdasdasd',
              url:
                  'https://images.pexels.com/photos/1580271/pexels-photo-1580271.jpeg',
              width: 400,
              height: 400,
              provider: AssetImage('assets/images/temp/user.jpg'),
            ),
          ],
          seen_by: [],
          created_at: DateTime.now().microsecondsSinceEpoch,
          videos: [],
          type: TextType.Image,
        ),
      ],
      last_seen: 0,
      user_id: '1',
    ),
  ];

  final List<String> _chatOptions = ["All", "Unread", "Group", "Favorites"];

  String _selectedOption = "All";
  bool _selectMode = false;
  List<String> _selectedConversations = [];

  Widget _header() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      width: double.infinity,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 272),
        crossFadeState: _selectedConversations.isEmpty
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: Row(
          children: [
            GestureDetector(
              onTap: () => AppRoutes.pop(),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20.w,
                color: AppColors.text,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Chats',
              style: TextStyle(color: AppColors.text, fontSize: 19.sp),
            ),
          ],
        ),
        secondChild: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectMode = false;
                  _selectedConversations = [];
                });
              },
              child: Icon(Icons.close_rounded, size: 24, color: AppColors.text),
            ),
            SizedBox(width: 12.w),
            Text(
              '${_selectedConversations.length} Selected',
              style: TextStyle(color: AppColors.text, fontSize: 19.sp),
            ),
            Spacer(),
            SizedBox(width: 12),
            CustomSvg(
              'assets/icons/delete.svg',
              color: AppColors.text,
              size: 20,
            ),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(bottom: false, child: SizedBox(height: 12.h)),
            _header(),
            _searchWidget(),
            HorizontalOptions(
              options: _chatOptions,
              selectedOption: _selectedOption,
              onChange: (option) {
                setState(() {
                  _selectedOption = option;
                });
              },
            ),
            SizedBox(height: 12.h),
            if (isLoading) ..._skeletons(),
            if (!isLoading)
              ..._conversations.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return ConversationItem(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return ChatTextsScreen(
                            conversationId: item.uuid,
                            model: item,
                          );
                        },
                      ),
                    );
                  },
                  model: item,
                  bottomBorder: index != _conversations.length - 1,
                  onSelect: (id) {
                    if (_selectedConversations.isEmpty) {
                      setState(() {
                        _selectMode = true;
                      });
                    }
                    setState(() {
                      _selectedConversations.add(id);
                    });
                  },
                  onDeSelect: (id) {
                    setState(() {
                      _selectedConversations.remove(id);
                    });

                    if (_selectedConversations.isEmpty) {
                      setState(() {
                        _selectMode = false;
                      });
                    }
                  },
                  selectMode: _selectMode,
                  selected: _selectedConversations.contains(item.uuid),
                );
              }),
          ],
        ),
      ),
    );
  }
}
