import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _marketUrl = 'https://gonka.vip/api/market';
const _ttl = Duration(minutes: 10);

final marketPriceProvider =
    StateNotifierProvider<MarketPriceNotifier, AsyncValue<double?>>((ref) {
  return MarketPriceNotifier();
});

class MarketPriceNotifier extends StateNotifier<AsyncValue<double?>> {
  Timer? _timer;
  DateTime? _lastFetch;
  double? _cachedPrice;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  MarketPriceNotifier() : super(const AsyncValue.data(null)) {
    fetch();
    _timer = Timer.periodic(_ttl, (_) => fetch());
  }

  Future<void> fetch() async {
    if (_lastFetch != null &&
        _cachedPrice != null &&
        DateTime.now().difference(_lastFetch!) < _ttl) {
      return;
    }
    try {
      final response = await _dio.get(_marketUrl);
      final data = response.data;
      final stats = data is Map ? data['market_stats'] : null;
      final rawPrice = stats is Map ? stats['price'] : null;
      final price = (rawPrice is num) ? rawPrice.toDouble() : null;
      if (price == null || price <= 0) {
        if (mounted) state = const AsyncValue.data(null);
        return;
      }
      _cachedPrice = price;
      _lastFetch = DateTime.now();
      if (mounted) state = AsyncValue.data(price);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dio.close();
    super.dispose();
  }
}
