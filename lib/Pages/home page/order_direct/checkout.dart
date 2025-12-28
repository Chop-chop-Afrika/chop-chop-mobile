import 'package:chop_chop_africa/backend/address_provider.dart';
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
  String _selectedPaymentMethod = 'bank_transfer';

  @override
  void initState() {
    super.initState();
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.fetchStoreInformation(widget.storeId);
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
    final formatter = NumberFormat("#,##0.00", "en_US");
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
        _buildSummaryRow('Sub-total (${widget.productNumber} items)', '\$${formatter.format(widget.subTotal)}'),
        0.8.gap,
        _buildSummaryRow('Delivery Fee', '\$2'),
        0.8.gap,
        _buildSummaryRow('Service Fees', '\$2'),
        Divider(height: 20, color: IAColors.veryLightGrey),
        _buildSummaryRow('Total', '\$${formatter.format(widget.subTotal)}', isTotal: true),
      ],
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
        _buildPaymentOption('bank_transfer', 'Bank Transfer', null),
        1.gap,
        _buildPaymentOption('pay_online', 'Pay Online', null),
        1.gap,
        _buildPaymentOption('reward_balance', 'Reward Balance (\$20)', null),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, String? logo) {
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
                  value == 'bank_transfer'
                      ? Icons.account_balance
                      : value == 'pay_online'
                          ? Icons.language
                          : Icons.card_giftcard,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 13),
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
          if (value != 'reward_balance') Divider(color: IAColors.veryLightGrey, height: 1),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return Column(
      children: [
        SizedBox(
          height: 6.5.pH,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final storeProvider = Provider.of<StoreProvider>(context, listen: false);
              final addressProvider = Provider.of<AddressProvider>(context, listen: false);

              // Get delivery time from store information
              final deliveryTime = storeProvider.storeInformation?.data?.deliveryTime ?? '';

              // Get default address ID
              final addressId = addressProvider.defaultAddress?.id ?? '';


              // Map payment method
              String apiPaymentMethod = '';
              if (_selectedPaymentMethod == 'bank_transfer') {
                apiPaymentMethod = 'card';
              } else if (_selectedPaymentMethod == 'pay_online') {
                apiPaymentMethod = 'online';
              } else if (_selectedPaymentMethod == 'reward_balance') {
                apiPaymentMethod = 'reward_balance';
              }

              // Call create order API
              await storeProvider.createOrder(
                widget.orderId,
                addressId,
                deliveryTime,
                _noteController.text,
                apiPaymentMethod,
                context,
              );
            },
            child: Text('Place Order'),
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
