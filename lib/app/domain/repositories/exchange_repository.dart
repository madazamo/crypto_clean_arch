import '../either/either.dart';
import '../failures/http_request_failure.dart';
import '../models/crypto/crypto.dart';


typedef GetPriceFuture = Future<Either<HttpRequestFailure, List<Crypto>>>;
abstract class ExchangeRepository {
   GetPriceFuture getPrices(List<String> ids);
}
