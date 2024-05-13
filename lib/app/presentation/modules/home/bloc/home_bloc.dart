import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:blockchain/app/domain/repositories/exchange_repository.dart';
import 'package:blockchain/app/domain/repositories/ws_repository.dart';
import 'package:blockchain/app/presentation/modules/home/bloc/home_events.dart';

import '../../../../domain/models/ws_status/ws_status.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    super.initialState, {
    required this.exchangeRepository,
    required this.wsRepository,
  }) {
    on<InitializeEvent>(_onInitialize);
    on<UpdateWsStatusEvent>(_onUpdateWsStatus);
    on<UpdateCryptoPriceEvent>(_onUpdateCryptoPrices);
    on<DeleteEvent>(_onDelete);
  }

  final ExchangeRepository exchangeRepository;
  final WsRepository wsRepository;
  StreamSubscription? _priceSubscription, _wsSubscription;

  final _ids = [
    'bitcoin',
    'binance-coin',
    'monero',
    'tether',
    'litecoin',
    'usd-coin',
    'dogecoin',
    'ethereum'
  ];

  Future<void> _onInitialize(
      InitializeEvent event, Emitter<HomeState> emit) async {
    state.maybeWhen(
      loading: () {},
      orElse: () => emit(
        HomeState.loading(),
      ),
    );

    final result = await exchangeRepository.getPrices(_ids);

    emit(
      result.when(
        left: (failure) => HomeState.failed(failure),
        right: (cryptos) {
          startPriceListening();
          return HomeState.loaded(cryptos: cryptos);
        },
      ),
    );
  }

  void _onUpdateWsStatus(
      UpdateWsStatusEvent event, Emitter<HomeState> emmiter) {
    state.mapOrNull(
      loaded: (state) {
        emit(
          state.copyWith(wsStatus: event.status),
        );
      },
    );
  }

  void _onUpdateCryptoPrices(
      UpdateCryptoPriceEvent event, Emitter<HomeState> emmiter) {
    state.mapOrNull(
      loaded: (state) {
        final keys = event.prices.keys;
        emit(
          state.copyWith(
            cryptos: [
              ...state.cryptos.map(
                (crypto) {
                  if (keys.contains(crypto.id)) {
                    return crypto.copyWith(
                      price: event.prices[crypto.id]!,
                    );
                  }
                  return crypto;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDelete(DeleteEvent event, Emitter<HomeState> emitter){
    state.mapOrNull(
        loaded: (state){
          final cryptos = [...state.cryptos];
          cryptos.removeWhere((element) => element.id == event.crypto.id);
          emit(state.copyWith(cryptos: cryptos),);
        }
      );
  }

  Future<bool> startPriceListening() async {
    final connected = await wsRepository.connect(_ids);
    add(
      UpdateWsStatusEvent(
        connected ? WsStatus.connected() : WsStatus.failed(),
      ),
    );
    await _wsSubscription?.cancel();
    await _priceSubscription?.cancel();
    _wsSubscription = wsRepository.onStatusChanged.listen(
      (status) => add(
        UpdateWsStatusEvent(status),
      ),
    );

    _priceSubscription = wsRepository.onPricesChanged.listen(
      (prices) => add(
        UpdateCryptoPriceEvent(prices),
      ),
    );

    return connected;
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _priceSubscription?.cancel();
    return super.close();
  }
}
