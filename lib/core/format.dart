import 'package:intl/intl.dart';

import '../models/enums.dart';
import '../models/property.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

/// ₦2,500,000
String formatNaira(num amount) => _naira.format(amount);

/// Compact Naira for cards/chips: ₦2.5M, ₦850K, ₦1.2B.
String formatNairaCompact(num amount) {
  if (amount >= 1000000000) {
    return '₦${(amount / 1000000000).toStringAsFixed(amount % 1000000000 == 0 ? 0 : 1)}B';
  }
  if (amount >= 1000000) {
    return '₦${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
  }
  if (amount >= 1000) {
    return '₦${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 0)}K';
  }
  return '₦$amount';
}

/// Price + unit, e.g. "₦2.5M/year", "₦85K/night", "₦45M".
String priceLabel(Property p, {bool compact = true}) {
  final price = compact ? formatNairaCompact(p.price) : formatNaira(p.price);
  return '$price${p.type.priceSuffix}';
}

/// "2 days ago", "3 weeks ago".
String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inDays >= 30) {
    final m = (diff.inDays / 30).floor();
    return '$m month${m == 1 ? '' : 's'} ago';
  }
  if (diff.inDays >= 7) {
    final w = (diff.inDays / 7).floor();
    return '$w week${w == 1 ? '' : 's'} ago';
  }
  if (diff.inDays >= 1) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  if (diff.inHours >= 1) return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
  return 'Just now';
}

String bedsLabel(Property p) {
  if (p.type == ListingType.land) {
    return p.sizeSqm != null ? '${p.sizeSqm!.toStringAsFixed(0)} sqm' : 'Plot';
  }
  return '${p.bedrooms} bed${p.bedrooms == 1 ? '' : 's'}';
}
