import 'dart:io';

import 'package:chop_chop_africa/Pages/home%20page/support_direct/support_messages.dart';
import 'package:chop_chop_africa/Pages/home%20page/support_direct/ticket_history.dart';
import 'package:chop_chop_africa/backend/support_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/image_services.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class Support extends StatefulWidget {
  /// When true this always shows the new-ticket form.
  ///
  /// Reached from the tab, Support redirects to the ticket list if the user
  /// already has tickets. The "new ticket" button needs the form itself, which
  /// that redirect would otherwise make unreachable.
  final bool forceForm;
  const Support({super.key, this.forceForm = false});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  String? _selectedCategory;
  final TextEditingController _messageController = TextEditingController();
  final ImageServices _imageServices = ImageServices();
  bool _isLoading = false;


  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<SupportProvider>(
      builder: (context, supportProvider, child) {
        // Show the ticket list instead of the form when the user already has
        // tickets — unless they explicitly asked to raise a new one.
        if (!widget.forceForm && supportProvider.userTicketsList.isNotEmpty) {
          return TicketHistory();
        }

        // Otherwise show the support form
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.pW),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    2.gap,
                    Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 6.pW,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    1.gap,
                    Text(
                      'Get help from our support team. We\'ll get back to you as soon as possible',
                      style: TextStyle(
                        fontSize: 3.5.pW,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    2.gap,
                    _buildSectionHeader('Category'),
                    1.gap,
                    _buildCategoryDropdown(),
                    2.gap,
                    _buildSectionHeader('Image attachment'),
                    1.gap,
                    _buildImageAttachment(),
                    2.gap,
                    _buildSectionHeader('Message'),
                    1.gap,
                    _buildMessageField(theme),
                    3.gap,
                    _buildSubmitButton(),
                    2.gap,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 3.5.pW,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 1.pW),
        Icon(
          Icons.info_outline,
          size: 4.pW,
          color: Colors.grey.shade600,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<SupportProvider>(
      builder: (context, supportProvider, child) {
        final categories = supportProvider.supportInfo?.data?.categories ?? [];

        // Set default category if not set and categories are available
        if (_selectedCategory == null && categories.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedCategory = categories.first;
            });
          });
        }

        if (categories.isEmpty) {
          return Container(
            padding: EdgeInsets.all(4.pW),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(2.pW),
              border: Border.all(color: Colors.grey.shade200, width: 0.2),
            ),
            child: Text(
              'Loading categories...',
              style: TextStyle(fontSize: 3.5.pW, color: Colors.grey.shade600),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.pW, vertical: 1.pW),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(2.pW),
            border: Border.all(color: Colors.grey.shade200, width: 0.2),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, size: 5.pW),
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category.substring(0, 1).toUpperCase() + category.substring(1),
                  style: TextStyle(fontSize: 3.5.pW),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildImageAttachment() {
    return Consumer<SupportProvider>(
      builder: (context, supportProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.pW, vertical: 3.pW),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(2.pW),
            border: Border.all(color: Colors.grey.shade200, width: 0.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (supportProvider.supportImage != null)
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1.pW),
                      child: Image.file(
                        File(supportProvider.supportImage!),
                        width: 10.pW,
                        height: 10.pW,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 2.pW),
                    Text(
                      'Image attached',
                      style: TextStyle(
                        fontSize: 3.5.pW,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Upload Image',
                  style: TextStyle(
                    fontSize: 3.5.pW,
                    color: Colors.grey.shade600,
                  ),
                ),
              TextButton(
                onPressed: () async {
                  await _imageServices.pickImages(
                    ImageSource.gallery,
                    'supportTicket',
                    context,
                  );
                },
                child: Text(
                  'Add Image',
                  style: TextStyle(
                    fontSize: 3.5.pW,
                    color: IAColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageField(ThemeData theme) {
    return TextFormField(
      controller: _messageController,
      maxLines: 8,
      style: theme.textTheme.bodySmall,
      decoration: InputDecoration(
        hintText:
            'To help us track down this issue, please include:\n• When it happened (timestamp)\n• What you expected to happen\n• What actually happened\nThese details will help us quickly identify and fix the problem!',
        hintStyle: TextStyle(
          fontSize: 3.pW,
          color: Colors.grey.shade500,
          height: 1.5,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.pW),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.pW),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.pW),
          borderSide: BorderSide(color: IAColors.primary, width: 0.5),
        ),
        contentPadding: EdgeInsets.all(4.pW),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 6.5.pH,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final supportProvider = Provider.of<SupportProvider>(context, listen: false);

          // Validate message
          if (_messageController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter a message'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Validate category
          if (_selectedCategory == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please wait for categories to load'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Set loading state
          setState(() {
            _isLoading = true;
          });

          // Create subject from category
          String subject = 'Support Request - ${_selectedCategory!.substring(0, 1).toUpperCase() + _selectedCategory!.substring(1)}';

          // Submit support ticket
          final ticketId = await supportProvider.createSupportTicket(
            _selectedCategory!,
            subject,
            _messageController.text.trim(),
          );

          // Clear loading state
          setState(() {
            _isLoading = false;
          });

          // Navigate to message screen if successful
          if (ticketId != null) {
            _messageController.clear();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SupportMessages(ticketId: ticketId),
              ),
            );
          }
        },
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulse,
                  colors: const [Colors.white],
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                  pathBackgroundColor: Colors.white,
                ),
              )
            : Text('Submit Message'),
      ),
    );
  }
}
