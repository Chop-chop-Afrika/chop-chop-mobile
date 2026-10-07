import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utility/iacolors.dart';

/// Hosts the Stripe Checkout page returned by POST /user/orders/make-payment.
///
/// Stripe sends the browser to /payment/return when the customer is done, which
/// is only a "you can close this" page — it is not proof of payment. So this
/// screen just pops when it sees that URL and leaves the caller to confirm with
/// GET /user/orders/:id/payment-status.
///
/// Pops `true` when Stripe redirected to the return page, `false` if the
/// customer backed out.
class StripeCheckout extends StatefulWidget {
  final String checkoutUrl;

  const StripeCheckout({super.key, required this.checkoutUrl});

  @override
  State<StripeCheckout> createState() => _StripeCheckoutState();
}

class _StripeCheckoutState extends State<StripeCheckout> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_isReturnUrl(url)) _finish(true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            if (_isReturnUrl(request.url)) {
              _finish(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            print('Stripe webview error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _isReturnUrl(String url) =>
      url.contains('/payment/return') || url.contains('/connect/return');

  void _finish(bool completed) {
    if (_popped || !mounted) return;
    _popped = true;
    Navigator.of(context).pop(completed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Payment', style: TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finish(false),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(7),
          child: Divider(color: IAColors.veryLightGrey),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
