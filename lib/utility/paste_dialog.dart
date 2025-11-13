import 'package:flutter/material.dart';

import 'custom_alert_dialog.dart';
import 'iacolors.dart';


class PasteDialog extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  const PasteDialog({super.key,this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomAlertDialog(
      borderRadius: BorderRadius.circular(14),
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8)
          ),
          child: Text(
            'Paste Code',
            style: TextStyle(
                fontSize: 12,
                color: IAColors.black
            ),
          ),
        ),
      ),
      // content: Text(
      //   'Do you want to paste this code: ${text.toUpperCase()}?',
      //   textAlign: TextAlign.center,
      // ),
      content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: 'Do you want to paste this code: ',
              style: TextStyle(
                  color: IAColors.dialogDark
              ),
              children: [
                TextSpan(
                    text: '${text?.toUpperCase()}?',
                    style: TextStyle(
                        color: IAColors.dialogDark,
                        fontWeight: FontWeight.w600
                    )
                )
              ]
          )
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            SizedBox(
              // width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text('Paste',
                  style: TextStyle(
                      color: IAColors.dialogDark
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
