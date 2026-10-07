import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../custom widgets/top_snackbar.dart';
import 'iacolors.dart';


class UiUtils {
  static void showSnackBar(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
        ),
        duration: const Duration(seconds: 3),
      ));
    });
  }
  static void showSnackBarFromTop(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      OverlayEntry? entry;
      bool isRemoved = false;  // Add this flag

      // Create a safe removal function
      void removeEntry() {
        if (!isRemoved) {
          entry?.remove();
          isRemoved = true;
        }
      }

      entry = OverlayEntry(
        builder: (context) => TopSnackBar(
          message: message,
          onDismiss: removeEntry,  // Use the safe removal function
        ),
      );

      overlay.insert(entry);

      // Auto dismiss after 3 seconds
      Future.delayed(Duration(seconds: 3), removeEntry);  // Use the safe removal function
    });
  }

  static String formatNumber(dynamic number) {
    // Convert to double if needed
    final numValue = number is int ? number.toDouble() :
    (number is String ? double.tryParse(number) ?? 0.0 :
    (number is double ? number : 0.0));

    // Use NumberFormat from intl package
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return formatter.format(numValue);
  }
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? cancelActionText,
    required String defaultActionText,
    required Function(bool) onDismissed,
  }) async {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (cancelActionText != null)
              CupertinoDialogAction(
                child: Text(cancelActionText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            CupertinoDialogAction(
              child: Text(defaultActionText),
              onPressed: () {
                Navigator.of(context).pop(true);
                onDismissed(true);
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titleTextStyle: TextStyle(
              fontSize: 20,
              color: Colors.black54,
              fontWeight: FontWeight.w600
          ),
          content: Text(content),
          contentTextStyle: TextStyle(
              color: Colors.black54,
              fontSize: 17
          ),
          actions: <Widget>[
            if (cancelActionText != null)
              TextButton(
                child: Text(cancelActionText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            TextButton(
              child: Text(defaultActionText),
              onPressed: () {
                Navigator.of(context).pop(true);
                onDismissed(true);
              },
            ),
          ],
        ),
      );
    }
  }

  static void launchUrl(String url) async {
    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      await launcher.launchUrl(
        Uri.parse(url),
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> launchEmail(String toEmail, BuildContext context) async {
    final Email email = Email(
      body: '',
      subject: 'Help Needed with Indigenius AI',
      recipients: [toEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      print('Error sending email: $e');

      // If we get here, either there's no email app or another error occurred
      // Copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: toEmail));
      showSnackBar(context, 'Could not open email app. Email address copied to clipboard.');
      // Show a snackbar to inform the user
    }
  }
  static Widget backButton(BuildContext context){
    if(Platform.isAndroid){
      return IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back,color: Colors.black,),
      );
    }else{
      return IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,));
    }
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Widget subTitles(String title, double size){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title,
          style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w700
          ),
        )
      ],
    );
  }

  /// Runs [action] behind a non-dismissible overlay, so the user can see that
  /// something is happening and cannot tap anything meanwhile.
  ///
  /// The overlay is always torn down, including when [action] throws, so a
  /// failure can never leave the user stuck behind a barrier they cannot
  /// close. Use this for any awaited call the user triggered and must wait on.
  ///
  /// Note this does not use EasyLoading: the app sets `userInteractions = true`
  /// globally, which makes its mask let taps through to the screen below.
  static Future<T> runBlocking<T>(
    BuildContext context,
    String message,
    Future<T> Function() action, {
    String? subtitle,
  }) async {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    bool shown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 34,
                  width: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: IAColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    try {
      return await action();
    } finally {
      if (shown) {
        shown = false;
        navigator.pop();
      }
    }
  }
}
