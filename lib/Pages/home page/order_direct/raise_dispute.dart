import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/order_detail_model.dart';
import '../../../backend/order_provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

/// Raises a dispute on a completed order.
///
/// The API only accepts this once the order is completed, and refuses a second
/// one while another is open or being investigated, so both of those come back
/// as a message from the server rather than being guessed at here.
class RaiseDispute extends StatefulWidget {
  final OrderDetailData order;

  const RaiseDispute({super.key, required this.order});

  @override
  State<RaiseDispute> createState() => _RaiseDisputeState();
}

class _RaiseDisputeState extends State<RaiseDispute> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Common reasons, so most people never have to type. Tapping one fills the
  /// box, which stays editable.
  static const List<String> _suggestions = [
    'Missing items from my order',
    'Items arrived damaged or spoiled',
    'Wrong items delivered',
    'Order never arrived',
    'Charged the wrong amount',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    UiUtils.hideKeyboard(context);

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final String? message = await UiUtils.runBlocking(
      context,
      'Raising your dispute',
      () => provider.disputeOrder(
        widget.order.id!,
        _reasonController.text.trim(),
      ),
    );
    if (!mounted || message == null) return;

    UiUtils.showSnackBarFromTop(context, message);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Report a problem', style: TextStyle(fontSize: 16)),
        leading: UiUtils.backButton(context),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(7),
          child: Divider(color: IAColors.veryLightGrey),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 5.pW),
          children: [
            2.gap,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffFBFBFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UiUtils.subTitles(
                      widget.order.stores?.name ?? 'Order', 15),
                  0.3.gap,
                  Text(
                    'Order #${widget.order.code ?? ''}',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            2.5.gap,
            UiUtils.subTitles('What went wrong?', 15),
            1.gap,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions
                  .map((reason) => GestureDetector(
                        onTap: () {
                          setState(() => _reasonController.text = reason);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _reasonController.text == reason
                                ? IAColors.primary.withValues(alpha: 0.12)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _reasonController.text == reason
                                  ? IAColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(reason,
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
            2.gap,
            TextFormField(
              controller: _reasonController,
              maxLines: 5,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Tell us what went wrong';
                if (text.length < 10) {
                  return 'Please add a little more detail';
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                hintText: 'Describe the problem in your own words',
                hintStyle: const TextStyle(fontSize: 14),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            1.gap,
            Text(
              'Our support team reviews every dispute and will get back to '
              'you. You can also raise a support ticket if you need help '
              'sooner.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            3.gap,
            SizedBox(
              height: 6.5.pH,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit dispute'),
              ),
            ),
            3.gap,
          ],
        ),
      ),
    );
  }
}
