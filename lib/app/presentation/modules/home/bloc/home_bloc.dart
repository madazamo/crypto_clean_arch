import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../domain/models/ws_status/ws_status.dart';
import '../../../../domain/repositories/exchange_repository.dart';
import '../../../../domain/repositories/ws_repository.dart';
import 'home_state.dart';

class HomeBloc extends ChangeNotifier {
  HomeBloc({required this.wsRepository, required this.exchangeRepository});

  final ExchangeRepository exchangeRepository;
  final WsRepository wsRepository;
  StreamSubscription? _priceSubscription, _wsSubscription;
  HomeState _state = HomeState.loading();

  HomeState get state => _state;

  final _ids = ['bitcoin', 'binance-coin', 'monero', 'tether','litecoin', 'usd-coin', 'dogecoin', 'ethereum'];

  Future<void> init() async {
    _state.maybeWhen(
        loading: () {},
        orElse: () {
          _state = HomeState.loading();
          notifyListeners();
        });

    final result = await exchangeRepository.getPrices(_ids);

    _state = result.when(
        left: (failure) => HomeState.failed(failure),
        right: (cryptos) {
          startPriceListening();
          return HomeState.loaded(cryptos: cryptos);
        });
    notifyListeners();
  }

  Future<bool> startPriceListening() async {
    final connected = await wsRepository.connect(_ids);

    state.mapOrNull(
      loaded: (state) {
        if (connected) {
          _onPriceChanged();
        }
        _state = state.copyWith(
            wsStatus: connected ? WsStatus.connected() : WsStatus.failed());
        notifyListeners();
      },
    );
    state.whenOrNull(loaded: (cryptos, wsStatus) {});
    return connected;
  }

  void _onPriceChanged() {
    _priceSubscription?.cancel();
    _wsSubscription?.cancel();
    _priceSubscription = wsRepository.onPricesChanged.listen(
      (changes) {
        state.mapOrNull(loaded: (state) {
          final keys = changes.keys;
          _state = state.copyWith(
            cryptos: [
              ...state.cryptos.map(
                (crypto) {
                  if (keys.contains(crypto.id)) {
                    return crypto.copyWith(
                      price: changes[crypto.id]!,
                    );
                  }
                  return crypto;
                },
              ),
            ],
          );
          notifyListeners();
        });
      },
    );
    wsRepository.onStatusChanged.listen(
      (status) {
        state.mapOrNull(loaded: (state) {
          _state = state.copyWith(wsStatus: status);
          notifyListeners();
        });
      },
    );
  }

  @override
  void dispose() {
    _priceSubscription?.cancel();
    super.dispose();
  }
}
