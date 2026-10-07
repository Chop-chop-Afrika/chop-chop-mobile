import 'package:chop_chop_africa/Pages/home%20page/order_direct/stripe_checkout.dart';
import 'package:chop_chop_africa/Pages/home%20page/order_direct/track_order.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/models/charges_model.dart';
import 'package:chop_chop_africa/backend/models/make_payment_model.dart';
import 'package:chop_chop_africa/backend/order_provider.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Checkout extends StatefulWidget {
  final String orderId;
  final num subTotal;
  final int productNumber;
  final String storeId;
  const Checkout({super.key,required this.orderId, required this.subTotal, required this.productNumber, required this.storeId});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  bool _showNoteField = false;
  final TextEditingController _noteController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPaymentMethod = 'card';

  @override
  void initState() {
    super.initState();
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.fetchStoreInformation(widget.storeId);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    // Passing the subtotal makes the API return the exact fee breakdown for
    // this basket, so the summary below never computes the fees itself.
    orderProvider.getCharges(subtotal: widget.subTotal);
    orderProvider.getWalletBalance();
  }

  /// Formats an amount in the currency the charges endpoint reports (GBP).
  String _money(num? amount, {String? currency}) {
    final formatter = NumberFormat("#,##0.00", "en_GB");
    final String symbol = (currency ?? 'gbp').toLowerCase() == 'gbp' ? '£' : '';
    return '$symbol${formatter.format(amount ?? 0)}';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: IAColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Colors.black,
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              bodyLarge: TextStyle(fontSize: 13),
              bodyMedium: TextStyle(fontSize: 12),
              labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: IAColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Colors.black,
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              bodyLarge: TextStyle(fontSize: 13),
              bodyMedium: TextStyle(fontSize: 12),
              labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              hourMinuteTextStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              dayPeriodTextStyle: TextStyle(fontSize: 12),
              dialTextStyle: TextStyle(fontSize: 12),
              helpTextStyle: TextStyle(fontSize: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Checkout',
            style: TextStyle(fontSize: 16),
          ),
          leading: UiUtils.backButton(context),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.pH),
            child: Column(
              children: [
                Divider(
                  color: IAColors.veryLightGrey,
                ),
                TabBar(
                  labelColor: Colors.black,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  indicatorWeight: 0.01,
                  dividerColor: IAColors.veryLightGrey,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: IAColors.primary_60,
                        width: 2,
                      ),
                    ),
                  ),
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Delivery Now',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Schedule',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildDeliveryNowTab(),
            _buildScheduleTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryNowTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            2.gap,
            _buildWarningMessage('Delivery requires PIN confirmation'),
            2.gap,
            _buildAddressSection(),
            _buildNoteSection(),
            2.gap,
            _buildPaymentSummary(),
            2.gap,
            _buildPaymentMethod(),
            3.gap,
            _buildPlaceOrderButton(),
            2.gap,
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            2.gap,
            _buildWarningMessage(
                'Place your order ahead when you have little or no time on hand, delivered to your location'),
            2.gap,
            _buildAddressSection(),
            _buildNoteSection(),
            2.gap,
            _buildDateTimePickers(),
            2.gap,
            _buildPaymentSummary(),
            2.gap,
            _buildPaymentMethod(),
            3.gap,
            _buildPlaceOrderButton(),
            2.gap,
          ],
        ),
      ),
    );
  }

  Widget _buildWarningMessage(String message) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xffFFF9E6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xffF9A825), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Consumer<AddressProvider>(
      builder: (context, address, child) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      address.defaultAddress?.address ?? '25, Hassan Abodun street 2345, Ojodu, Lagos, Nigeria',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: IAColors.veryLightGrey, height: 1),
          ],
        );
      },
    );
  }

  Widget _buildNoteSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showNoteField = !_showNoteField;
              if (!_showNoteField) {
                _noteController.clear();
              }
            });
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.note_outlined, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Leave a Note for rider (Optional)',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Icon(
                      _showNoteField ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                  ],
                ),
              ),
              Divider(color: IAColors.veryLightGrey, height: 1),
            ],
          ),
        ),
        if (_showNoteField) ...[
          1.5.gap,
          TextFormField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your note here...',
              hintStyle: TextStyle(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          1.gap,
        ],
      ],
    );
  }

  Widget _buildDateTimePickers() {
    final dateFormat = DateFormat('EEEE, d MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery date',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? dateFormat.format(_selectedDate!)
                          : 'Select a delivery date',
                      style: TextStyle(fontSize: 13),
                    ),
                    Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ),
              Divider(color: IAColors.veryLightGrey, height: 1),
            ],
          ),
        ),
        1.5.gap,
        Text(
          'Delivery time',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select a delivery time',
                      style: TextStyle(fontSize: 13),
                    ),
                    Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ),
              Divider(color: IAColors.veryLightGrey, height: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final ChargesData? charges = orderProvider.charges;
        final ChargesBreakdown? breakdown = charges?.breakdown;
        final String currency = charges?.currency ?? 'gbp';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Payment Summary',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            1.2.gap,
            _buildSummaryRow(
              'Sub-total (${widget.productNumber} items)',
              _money(breakdown?.subtotal ?? widget.subTotal, currency: currency),
            ),
            0.8.gap,
            _buildSummaryRow(
              'Delivery Fee',
              charges == null
                  ? '--'
                  : _money(breakdown?.deliveryFee ?? charges.deliveryFee,
                      currency: currency),
            ),
            0.8.gap,
            _buildSummaryRow(
              'Service Fees',
              charges == null ? '--' : _money(breakdown?.serviceFee, currency: currency),
            ),
            Divider(height: 20, color: IAColors.veryLightGrey),
            _buildSummaryRow(
              'Total',
              charges == null
                  ? '--'
                  : _money(breakdown?.total ?? widget.subTotal, currency: currency),
              isTotal: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                'Payment Method',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        1.2.gap,
        _buildPaymentOption(
          'card',
          'Pay by Card',
          subtitle: 'Visa, Mastercard via Stripe',
        ),
        1.gap,
        Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final num? balance = orderProvider.walletBalance;
            return _buildPaymentOption(
              'wallet',
              balance == null
                  ? 'Wallet Balance'
                  : 'Wallet Balance  ${_money(balance)}',
              subtitle: 'Debited immediately',
              isLast: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String value,
    String label, {
    String? subtitle,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  value == 'card' ? Icons.credit_card : Icons.account_balance_wallet,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 13)),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: value,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue!;
                    });
                  },
                  activeColor: IAColors.primary,
                ),
              ],
            ),
          ),
          if (!isLast) Divider(color: IAColors.veryLightGrey, height: 1),
        ],
      ),
    );
  }

  /// Pays for the cart, then sends the customer to the live tracking page.
  ///
  /// A wallet payment settles in the make-payment response. A card payment
  /// comes back with a Stripe Checkout URL, and the webview closing proves
  /// nothing — Stripe confirms to the backend by webhook — so the payment is
  /// verified with payment-status before the order is treated as placed.
  Future<void> _placeOrder() async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final String addressId = addressProvider.defaultAddress?.id ?? '';
    if (addressId.isEmpty) {
      UiUtils.showSnackBarFromTop(
        context,
        'Choose a delivery address before placing your order',
      );
      return;
    }

    final payment = await orderProvider.makePayment(
      orderId: widget.orderId,
      addressId: addressId,
      paymentMethod: _selectedPaymentMethod,
      deliveryTime: storeProvider.storeInformation?.data?.deliveryTime ?? '',
      note: _noteController.text,
      scheduledDate: _scheduledDate(),
    );
    if (payment == null || !mounted) return;

    final String orderId = payment.orderId ?? widget.orderId;

    if (payment.needsCardCheckout) {
      final bool returned = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => StripeCheckout(checkoutUrl: payment.checkoutUrl!),
            ),
          ) ??
          false;
      if (!mounted) return;
      if (!returned) {
        UiUtils.showSnackBarFromTop(context, 'Payment was not completed');
        return;
      }

      // Stripe confirms to the backend by webhook, so there is a short wait
      // after the webview closes. Block the screen meanwhile — otherwise it
      // looks idle and the customer may tap Place Order a second time.
      final status = await UiUtils.runBlocking(
        context,
        'Confirming your payment',
        () => orderProvider.waitForPayment(orderId),
        subtitle: "This takes a few seconds. Please don't close the app.",
      );
      if (!mounted) return;
      if (status?.isPaid != true) {
        UiUtils.showSnackBarFromTop(
          context,
          'We have not received your payment yet. Check the order in a moment.',
        );
        return;
      }
    }

    _goToTracking(orderId);
  }

  /// Combines the date and time pickers into the ISO-8601 `scheduledDate` the
  /// API expects, or null when the customer did not schedule the order.
  String? _scheduledDate() {
    if (_selectedDate == null) return null;
    final time = _selectedTime;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    ).toUtc().toIso8601String();
  }

  void _goToTracking(String orderId) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => TrackOrder(orderId: orderId)),
      (route) => route.isFirst,
    );
  }

  Widget _buildPlaceOrderButton() {
    return Column(
      children: [
        SizedBox(
          height: 6.5.pH,
          width: double.infinity,
          child: Consumer<OrderProvider>(
            builder: (context, orderProvider, _) => ElevatedButton(
              onPressed: orderProvider.paying ? null : _placeOrder,
              child: orderProvider.paying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Place Order'),
            ),
          ),
        ),
        1.gap,
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 11, color: Colors.black54),
            children: [
              TextSpan(text: 'By placing your order you consent our '),
              TextSpan(
                text: 'Terms of use',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Policy',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
