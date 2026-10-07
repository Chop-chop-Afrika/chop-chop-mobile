/// Maps the API's `phase` strings onto the steps shown on the customer's
/// tracking stepper. `status` is the coarse state, `phase` is finer — for
/// example `reached_vendor` and `rider_accepted_order` are both status 3.
class OrderStep {
  final String title;
  final String subtitle;

  const OrderStep(this.title, this.subtitle);
}

class OrderPhase {
  static const List<OrderStep> steps = [
    OrderStep('Booking Confirmation', 'Order is been pushed to vendor'),
    OrderStep('Rider Accepted', 'A rider has accepted your order'),
    OrderStep('Picking Order', 'Rider is at the store picking up'),
    OrderStep('In Transit', 'Your order is on the way'),
    OrderStep('Arrived', 'Rider is at your drop-off point'),
    OrderStep('Completed', 'Delivered — thank you!'),
  ];

  /// Phases that end the order. `canceled_by_rider` is deliberately absent:
  /// the docs say it returns the order to the pool for another rider.
  static const Set<String> _failed = {
    'canceled_by_customer',
    'canceled_by_vendor',
    'delivery_failed',
  };

  static const Map<String, int> _phaseToStep = {
    'booking_confirmation': 0,
    'order_confirmed': 0,
    'canceled_by_rider': 0,
    'rider_accepted_order': 1,
    'reached_vendor': 2,
    'rider_picked_order': 2,
    'order_in_transit': 3,
    'order_arrived': 4,
    'completed': 5,
  };

  /// Index of the furthest completed step, or -1 before anything is paid.
  static int stepFromPhase(String? phase) {
    if (phase == null) return -1;
    return _phaseToStep[phase] ?? -1;
  }

  /// Falls back to the coarse `status` code when no phase is available, which
  /// is the case for GET /user/orders/:id — it returns status but not phase.
  static int stepFromStatus(int? status) {
    switch (status) {
      case 1:
      case 2:
        return 0;
      case 3:
        return 1;
      case 4:
        return 3;
      case 5:
        return 4;
      case 6:
        return 5;
      default:
        return -1;
    }
  }

  static bool isFailed(String? phase) => phase != null && _failed.contains(phase);

  static bool isFailedStatus(int? status) => status == 7 || status == 8;

  static String labelFor(String? phase, int? status) {
    if (isFailed(phase) || isFailedStatus(status)) {
      switch (phase) {
        case 'canceled_by_customer':
          return 'You canceled this order';
        case 'canceled_by_vendor':
          return 'The store canceled this order';
        case 'delivery_failed':
          return 'Delivery could not be completed';
        default:
          return status == 7 ? 'Order canceled' : 'Delivery failed';
      }
    }
    if (phase == 'canceled_by_rider') return 'Looking for another rider';
    final int step = phase != null ? stepFromPhase(phase) : stepFromStatus(status);
    if (step < 0) return 'Awaiting payment';
    return steps[step].title;
  }
}

/// Package tracking. Packages carry their own status codes, with 0 meaning
/// created-but-not-yet-paid — Stripe confirms by webhook, so a package sits at
/// 0 for a few seconds after checkout closes.
class PackagePhase {
  static const List<OrderStep> steps = [
    OrderStep('Booking Confirmation', 'Payment received, finding a rider'),
    OrderStep('Rider Accepted', 'A rider is on the way to collect it'),
    OrderStep('In Transit', 'Your package is on its way'),
    OrderStep('Delivered', 'Handed over — thank you!'),
  ];

  static const Map<String, int> _phaseToStep = {
    'booking_confirmation': 0,
    'order_confirmed': 0,
    'canceled_by_rider': 0,
    'rider_accepted_order': 1,
    'reached_vendor': 1,
    'rider_picked_order': 2,
    'order_in_transit': 2,
    'order_arrived': 2,
    'completed': 3,
  };

  /// Status codes: 0 awaiting payment · 1 paid, waiting for a rider
  /// 2 rider accepted / in transit · 3 delivered · 4 canceled · 5 failed
  static int stepFromStatus(int? status) {
    switch (status) {
      case 1:
        return 0;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return -1;
    }
  }

  static int stepFromPhase(String? phase) =>
      phase == null ? -1 : (_phaseToStep[phase] ?? -1);

  static bool isAwaitingPayment(int? status) => (status ?? 0) == 0;

  static bool isFailed(int? status) => status == 4 || status == 5;

  static String labelFor(int? status) {
    switch (status) {
      case 0:
        return 'Awaiting payment confirmation';
      case 1:
        return 'Paid — finding a rider';
      case 2:
        return 'On its way';
      case 3:
        return 'Delivered';
      case 4:
        return 'Canceled';
      case 5:
        return 'Delivery could not be completed';
      default:
        return 'Pending';
    }
  }
}
