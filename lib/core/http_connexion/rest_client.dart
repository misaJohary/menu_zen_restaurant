import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'rest_client.g.dart';


@injectable
@RestApi()
abstract class RestClient {
  @factoryMethod
  factory RestClient(
        Dio dio, {
        @Named('BaseUrl') String baseUrl,
      }) = _RestClient;
}
