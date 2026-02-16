import 'package:equiny/core/shared/interfaces/rest_client.dart';

abstract class Service {
  final RestClient restClient;

  Service(this.restClient);
}
