import '../../domain/repositories/exchange_repository.dart';
import '../services/remote/exchange_api.dart';

class ExchangeRepositoryImpl extends ExchangeRepository{
  final ExchangeAPI _api;

  ExchangeRepositoryImpl(this._api);

  @override
  GetPriceFuture getPrices(List<String> ids) {
    return _api.getPrices(ids);
  }

}
