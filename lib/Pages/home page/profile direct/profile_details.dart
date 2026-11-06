import 'package:chop_chop_africa/Pages/home%20page/profile%20direct/delete_account.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../utility/iacolors.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:phone_text_field/phone_text_field.dart' hide PhoneNumber;


class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateController = TextEditingController();
  String _initialCountryCode = 'NG';
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  /// The number as it was loaded from the server, in E.164. Used both as the
  /// fallback when the field is never touched and to tell whether anything
  /// actually changed.
  String _savedPhone = '';
  /// Whatever the phone field currently holds, in E.164.
  String _typedPhone = '';
  bool _isSaving = false;

  bool get _phoneChanged =>
      _typedPhone.isNotEmpty && _typedPhone != _savedPhone;

  @override
  void initState() {
    super.initState();
    initialProfile();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, _) {
        return Form(
          key: _globalKey,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerTheme: const DividerThemeData(
                color: Colors.transparent,
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text('Profile Details',
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),
                leading: UiUtils.backButton(context),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(7),
                  child: Divider(
                    color: IAColors.veryLightGrey,
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      1.gap,
                      _fieldLabel('First Name'),
                      _lockedField(_firstNameController),
                      _fieldLabel('Last Name'),
                      _lockedField(_lastNameController),
                      _fieldLabel('Email'),
                      _lockedField(_emailController),
                      _fieldLabel('D.O.B'),
                      _lockedField(_dateController),
                      _lockedNote(),
                      1.gap,
                      _fieldLabel('Phone Number'),
                      _phoneField(),
                      Text(
                        'Dispatch riders use this number to reach you, so keep it current.',
                        style: TextStyle(
                          fontSize: 12,
                          color: IAColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              persistentFooterButtons: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: SizedBox(
                        height: 6.5.pH,
                        width: 100.pW,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () => _save(profile),
                          child: _isSaving
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: LoadingIndicator(
                                      indicatorType: Indicator.ballPulse,
                                      colors: const [Colors.white],
                                      strokeWidth: 2,
                                      backgroundColor: Colors.transparent,
                                      pathBackgroundColor: Colors.black),
                                )
                              : Text('Update Profile'),
                        ),
                      ),
                    ),
                    0.5.gap,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: SizedBox(
                        height: 6.5.pH,
                        width: 100.pW,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: IAColors.danger,
                            backgroundColor: IAColors.white,
                            side: BorderSide(color: IAColors.danger),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return DeleteAccount();
                                  }));
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/trash.svg',
                                colorFilter: ColorFilter.mode(
                                    IAColors.danger, BlendMode.srcIn),
                              ),
                              0.5.gap,
                              Text('Delete Account'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save(ProfileProvider profile) async {
    if (!_globalKey.currentState!.validate()) return;
    final phone = _phoneChanged ? _typedPhone : _savedPhone;
    setState(() => _isSaving = true);
    await profile.updateProfile(
      _firstNameController.text,
      _lastNameController.text,
      _dateController.text,
      phone,
      context,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _savedPhone = phone;
    });
  }

  initialProfile() {
    Future.microtask(() async {
      var profile = Provider.of<ProfileProvider>(context, listen: false);
      await profile.getProfile();
      if (!mounted) return;

      final data = profile.getAllProfileInfo?.data;
      if (data == null) return;

      final saved = data.phone ?? '';
      // An account with no number on file would make the parser throw, so only
      // split it apart when there is something to split.
      String nsn = '';
      String isoCode = _initialCountryCode;
      if (saved.isNotEmpty) {
        try {
          final parsed = PhoneNumber.parse(saved);
          nsn = parsed.nsn;
          isoCode = parsed.isoCode.name;
        } catch (e) {
          print('Could not read the stored phone number "$saved": $e');
        }
      }

      setState(() {
        _emailController.text = data.email ?? '';
        _firstNameController.text = data.firstName ?? '';
        _lastNameController.text = data.lastName ?? '';
        _phoneController.text = nsn;
        _initialCountryCode = isoCode;
        _dateController.text = (data.dob ?? '').split('T').first;
        _savedPhone = saved;
        _typedPhone = saved;
      });
    });
  }

  /// Name, email and date of birth are shown but cannot be edited here, so
  /// they all get the same treatment: readable, muted, and inert.
  Widget _lockedField(TextEditingController controller) {
    return SizedBox(
      height: 9.5.pH,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        showCursor: false,
        enableInteractiveSelection: false,
        mouseCursor: SystemMouseCursors.basic,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontSize: 15, color: IAColors.darkGrey),
        decoration: _fieldDecoration(),
      ),
    );
  }

  Widget _phoneField() {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.grey[50],
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 13),
          bodySmall: TextStyle(fontSize: 12),
        ),
      ),
      child: SizedBox(
        height: 9.5.pH,
        child: PhoneTextField(
          // Rebuilds once the saved number arrives so the country shown
          // matches the number on file rather than the default.
          key: ValueKey(_initialCountryCode),
          controller: _phoneController,
          invalidNumberMessage: 'Please enter a valid phone number',
          autovalidateMode: AutovalidateMode.onUnfocus,
          initialCountryCode: _initialCountryCode,
          textStyle: TextStyle(
            fontSize: 15,
            color: IAColors.black,
          ),
          decoration: _fieldDecoration(hint: 'Enter Phone Number'),
          searchTextStyle: TextStyle(color: IAColors.dialogDark),
          searchFieldInputDecoration: InputDecoration(
            filled: true,
            fillColor: IAColors.fieldFill,
            suffixIcon: Icon(Icons.search),
            hintText: 'Search country',
          ),
          countryViewOptions: CountryViewOptions.countryCodeWithFlag,
          onChanged: (phoneNumber) {
            _typedPhone = phoneNumber.completeNumber;
          },
        ),
      ),
    );
  }

  /// One decoration for every field on the page, so fill, radius, padding and
  /// the reserved helper row are identical across them.
  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      filled: true,
      fillColor: IAColors.fieldFill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintText: hint,
      hintStyle: TextStyle(fontSize: 15, color: IAColors.grey),
      errorStyle: TextStyle(fontSize: 12),
      helperText: '',
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _lockedNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 14, color: IAColors.darkGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Contact support to change your name, email or date of birth.',
            style: TextStyle(
              fontSize: 12,
              color: IAColors.darkGrey,
            ),
          ),
        ),
      ],
    );
  }
}
