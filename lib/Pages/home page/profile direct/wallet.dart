import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/wallet_transaction_model.dart';
import '../../../backend/order_provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

/// Wallet balance and the transaction ledger behind it.
class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    await provider.getWalletBalance();
    await provider.getWalletTransactions(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final bool nearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearBottom && provider.txHasMore && !provider.loadingTransactions) {
      provider.getWalletTransactions();
    }
  }

  String _money(num? amount) =>
      '£${NumberFormat("#,##0.00", "en_GB").format(amount ?? 0)}';

  String _date(String? raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw);
    return parsed == null
        ? ''
        : DateFormat('d MMM yyyy, HH:mm').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Wallet', style: TextStyle(fontSize: 16)),
        leading: UiUtils.backButton(context),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(7),
          child: Divider(color: IAColors.veryLightGrey),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final items = provider.walletTransactions;
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length + 2 + (provider.txHasMore ? 1 : 0),
              separatorBuilder: (_, index) => index == 0
                  ? const SizedBox.shrink()
                  : Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                if (index == 0) return _balanceCard(provider.walletBalance);
                if (index == 1) {
                  return Padding(
                    padding: EdgeInsets.only(top: 2.pH, bottom: 1.pH),
                    child: UiUtils.subTitles('Transactions', 15),
                  );
                }
                final i = index - 2;
                if (i >= items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _row(items[i]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _balanceCard(num? balance) => Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 2.pH),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xffFDF2DF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available balance',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            0.5.gap,
            Text(
              balance == null ? '--' : _money(balance),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );

  Widget _row(WalletTransaction tx) {
    final Color amountColour = tx.isFailed
        ? Colors.grey
        : tx.isDebit
            ? Colors.red.shade400
            : Colors.green.shade600;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade100,
        child: Icon(
          tx.isDebit ? Icons.arrow_upward : Icons.arrow_downward,
          size: 17,
          color: amountColour,
        ),
      ),
      title: Text(tx.subject, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        _date(tx.createdAt),
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${tx.isDebit ? '-' : '+'}${_money(tx.amount)}',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: amountColour),
          ),
          if (tx.isPending || tx.isFailed)
            Text(
              tx.isPending ? 'Pending' : 'Failed',
              style: TextStyle(
                  fontSize: 11,
                  color: tx.isPending ? Colors.orange.shade700 : Colors.grey),
            ),
        ],
      ),
    );
  }
}
