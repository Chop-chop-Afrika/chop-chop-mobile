import 'package:chop_chop_africa/Pages/home%20page/profile%20direct/your_invites.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../backend/referral_provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

/// Referral screen: the user's code, what they have earned, and who they have
/// invited.
///
/// The design also had a Reward history screen with Awarded and Withdrawal
/// tabs. There is no API behind either — /referral/rewards returns the current
/// rewards, and nothing exposes withdrawals — so that screen is left out
/// rather than shipped empty.
class InviteFriend extends StatefulWidget {
  const InviteFriend({super.key});

  @override
  State<InviteFriend> createState() => _InviteFriendState();
}

class _InviteFriendState extends State<InviteFriend> {
  /// How many invites to preview before "See all".
  static const int _previewCount = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralProvider>(context, listen: false).loadAll();
    });
  }

  Future<void> _claim() async {
    final provider = Provider.of<ReferralProvider>(context, listen: false);
    final int total = provider.unclaimedRewards.length;
    final int claimed = await UiUtils.runBlocking(
      context,
      'Claiming your reward',
      () => provider.claimAllRewards(),
      subtitle: 'Crediting it to your wallet.',
    );
    if (!mounted) return;

    if (claimed == 0) {
      UiUtils.showSnackBarFromTop(context, 'Could not claim your reward');
    } else if (claimed < total) {
      // Rewards are claimed one at a time, so a partial result is possible.
      UiUtils.showSnackBarFromTop(
        context,
        'Claimed $claimed of $total rewards — try again for the rest',
      );
    } else {
      UiUtils.showSnackBarFromTop(context, 'Reward credited to your wallet');
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    UiUtils.showSnackBarFromTop(context, 'Referral code copied');
  }

  Future<void> _share(String shareText) async {
    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Invite a friend', style: TextStyle(fontSize: 16)),
        leading: UiUtils.backButton(context),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(7),
          child: Divider(color: IAColors.veryLightGrey),
        ),
      ),
      body: Consumer<ReferralProvider>(
        builder: (context, provider, _) {
          final code = provider.me?.referralCode;
          final shareText = provider.me?.shareText ??
              (code == null
                  ? null
                  : 'Join me on Chop Chop Africa! Use my code $code when you sign up.');

          return RefreshIndicator(
            onRefresh: provider.loadAll,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 5.pW),
              children: [
                2.gap,
                _rewardBalance(provider),
                2.gap,
                _infoCard(),
                2.5.gap,
                Text('Referral code',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                1.gap,
                _codeBox(code, provider.loadingMe),
                1.5.gap,
                _actions(code, shareText),
                3.gap,
                _invitesHeader(provider),
                1.gap,
                _invitesPreview(provider),
                3.gap,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _rewardBalance(ReferralProvider provider) {
    return Column(
      children: [
        Text('Available Reward',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        0.5.gap,
        provider.loadingRewards && provider.rewards.isEmpty
            ? const SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(
                '${provider.availableReward}XP',
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.w800),
              ),
        1.5.gap,
        SizedBox(
          height: 5.5.pH,
          child: ElevatedButton(
            onPressed: provider.hasClaimable ? _claim : null,
            style: ButtonStyle(
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                  provider.hasClaimable ? IAColors.primary : Colors.grey.shade300),
            ),
            child: Text(
              'Claim reward',
              style: TextStyle(
                  color: provider.hasClaimable
                      ? Colors.white
                      : Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xffFDF2DF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: IAColors.primary,
              child: const Icon(Icons.person_add_alt_1,
                  size: 13, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UiUtils.subTitles('Invite friends and earn reward', 14),
                  0.3.gap,
                  Text(
                    'Share your code with friends. You earn a reward when they '
                    'sign up and order.',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _codeBox(String? code, bool loading) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: loading && code == null
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  code ?? 'Unavailable',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 4),
                ),
        ),
      );

  Widget _actions(String? code, String? shareText) => Row(
        children: [
          Expanded(
            child: _actionButton(
              'Share',
              Icons.ios_share,
              filled: true,
              onTap: shareText == null ? null : () => _share(shareText),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              'Copy',
              Icons.copy,
              onTap: code == null ? null : () => _copyCode(code),
            ),
          ),
        ],
      );

  Widget _actionButton(String label, IconData icon,
      {bool filled = false, VoidCallback? onTap}) {
    return SizedBox(
      height: 5.pH,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon,
            size: 16, color: filled ? Colors.white : Colors.grey.shade800),
        label: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: filled ? Colors.white : Colors.grey.shade800)),
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
              filled ? IAColors.primary : Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _invitesHeader(ReferralProvider provider) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UiUtils.subTitles('Your invites', 15),
          if (provider.invites.length > _previewCount)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const YourInvites()),
              ),
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  color: IAColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: IAColors.primary,
                ),
              ),
            ),
        ],
      );

  Widget _invitesPreview(ReferralProvider provider) {
    if (provider.invites.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2.pH),
        child: Text(
          provider.loadingInvites
              ? 'Loading your invites…'
              : 'No one has used your code yet.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      );
    }
    final preview = provider.invites.take(_previewCount).toList();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffFBFBFB),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (int i = 0; i < preview.length; i++) ...[
            InviteRow(invite: preview[i]),
            if (i != preview.length - 1)
              Divider(color: Colors.grey.shade200, height: 1),
          ],
        ],
      ),
    );
  }
}
