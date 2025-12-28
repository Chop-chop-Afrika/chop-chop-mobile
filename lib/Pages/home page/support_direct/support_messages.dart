import 'dart:io';

import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/backend/support_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/image_services.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SupportMessages extends StatefulWidget {
  final String ticketId;
  const SupportMessages({super.key, required this.ticketId});

  @override
  State<SupportMessages> createState() => _SupportMessagesState();
}

class _SupportMessagesState extends State<SupportMessages> {
  final TextEditingController _messageController = TextEditingController();
  final ImageServices _imageServices = ImageServices();

  @override
  void initState() {
    super.initState();
    final supportProvider = Provider.of<SupportProvider>(context, listen: false);
    supportProvider.getTicketDetails(widget.ticketId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Support',
          style: TextStyle(fontSize: 16),
        ),
        leading: UiUtils.backButton(context),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: IAColors.veryLightGrey,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer2<SupportProvider, ProfileProvider>(
              builder: (context, supportProvider, profileProvider, child) {
                final messages = supportProvider.ticketDetails?.data?.messages ?? [];
                final firstName = profileProvider.getAllProfileInfo?.data?.firstName ?? '';
                final lastName = profileProvider.getAllProfileInfo?.data?.lastName ?? '';

                if (messages.isEmpty) {
                  return Center(
                    child: Text('No messages yet'),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.pW, vertical: 2.pH),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message.senderType == 'user';

                    return _buildMessageBubble(
                      message: message.message ?? '',
                      attachment: message.attachment,
                      isUser: isUser,
                      userInitials: '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}',
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    String? attachment,
    required bool isUser,
    required String userInitials,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.pH),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(isUser: false, userInitials: ''),
            SizedBox(width: 2.pW),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(3.pW),
              decoration: BoxDecoration(
                color: isUser ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(3.pW),
                border: Border.all(color: Colors.grey.shade200, width: 0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (attachment != null && attachment.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.pW),
                      child: Image.network(
                        attachment,
                        width: 60.pW,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60.pW,
                            height: 40.pW,
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade600,
                              size: 8.pW,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 60.pW,
                            height: 40.pW,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (message.isNotEmpty) SizedBox(height: 2.pW),
                  ],
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 3.5.pW,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 2.pW),
            _buildAvatar(isUser: true, userInitials: userInitials),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser, required String userInitials}) {
    if (isUser) {
      // User avatar with initials
      return Container(
        width: 10.pW,
        height: 10.pW,
        decoration: BoxDecoration(
          color: IAColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            userInitials,
            style: TextStyle(
              color: Colors.white,
              fontSize: 4.pW,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      // Admin avatar with Chop Chop Afrika logo
      return Container(
        width: 10.pW,
        height: 10.pW,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/image 42.png',),
            fit: BoxFit.fill,
          ),
        ),
      );
    }
  }

  Widget _buildMessageInput() {
    return Consumer<SupportProvider>(
      builder: (context, supportProvider, child) {
        return Container(
          padding: EdgeInsets.fromLTRB(4.pW, 2.pH, 4.pW, 3.pH),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (supportProvider.supportImage != null && supportProvider.supportImage!.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 2.pH),
                  padding: EdgeInsets.all(3.pW),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(2.pW),
                    border: Border.all(color: Colors.grey.shade200, width: 0.3),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(1.5.pW),
                        child: Image.file(
                          File(supportProvider.supportImage!),
                          width: 15.pW,
                          height: 15.pW,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 3.pW),
                      Expanded(
                        child: Text(
                          'Image attached',
                          style: TextStyle(
                            fontSize: 3.5.pW,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          supportProvider.getSupportImage('');
                        },
                        child: Container(
                          padding: EdgeInsets.all(1.pW),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 4.pW,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.pW, vertical: 0.5.pH),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.pW),
                  border: Border.all(color: Colors.grey.shade400, width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Messages.....',
                          hintStyle: TextStyle(
                            fontSize: 3.5.pW,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 1.pH),
                        ),
                        style: TextStyle(fontSize: 3.5.pW),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _imageServices.pickImages(
                          ImageSource.gallery,
                          'supportMessage',
                          context,
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/svg/camera.svg',
                        width: 5.pW,
                        height: 5.pW,
                        colorFilter: ColorFilter.mode(
                          Colors.grey.shade700,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.pW),
                    GestureDetector(
                      onTap: () async {
                        final message = _messageController.text.trim();
                        if (message.isEmpty) return;

                        final supportProvider = Provider.of<SupportProvider>(context, listen: false);

                        // Send the message
                        await supportProvider.sendMessage(widget.ticketId, message);
                        print(supportProvider.supportImage);

                        // Clear the text field
                        _messageController.clear();
                      },
                      child: SvgPicture.asset(
                        'assets/svg/send.svg',
                        width: 5.pW,
                        height: 5.pW,
                        colorFilter: ColorFilter.mode(
                          IAColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
