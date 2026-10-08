import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/referral_model.dart';
import '../../../backend/referral_provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

/// The full list of people the user has referred. The invite screen shows the
/// first few and links here via "See all".
class YourInvites extends StatefulWidget {
  const YourInvites({super.key});

  @override
  State<YourInvites> createState() => _YourInvitesState();
}

class _YourInvitesState extends State<YourInvites> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralProvider>(context, listen: false)
          .getInvites(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final provider = Provider.of<ReferralProvider>(context, listen: false);
    final nearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearBottom && provider.hasNextInvitesPage && !provider.loadingInvites) {
      provider.getInvites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your Invites', style: TextStyle(fontSize: 16)),
        leading: UiUtils.backButton(context),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(7),
          child: Divider(color: IAColors.veryLightGrey),
        ),
      ),
      body: Consumer<ReferralProvider>(
        builder: (context, provider, _) {
          final invites = provider.invites;
          if (invites.isEmpty) {
            return provider.loadingInvites
                ? const Center(child: CircularProgressIndicator())
                : _empty();
          }
          return RefreshIndicator(
            onRefresh: () => provider.getInvites(refresh: true),
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 5.pW),
              itemCount: invites.length + (provider.hasNextInvitesPage ? 1 : 0),
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                if (index >= invites.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return InviteRow(invite: invites[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.pW),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 46, color: Colors.grey.shade400),
              1.gap,
              UiUtils.subTitles('No invites yet', 15),
              0.5.gap,
              Text(
                'Share your referral code and the friends who join will show '
                'up here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
}

/// One referred person. The API returns only an email, so that stands in for
/// the name and its first letter for the avatar.
class InviteRow extends StatelessWidget {
  final ReferralInvite invite;

  const InviteRow({super.key, required this.invite});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          invite.initial,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ),
      title: Text(
        invite.displayName,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
