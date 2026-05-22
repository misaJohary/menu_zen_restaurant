import '../entities/customer_reservation_entity.dart';
import '../entities/reservation_request_status.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/customer_reservation_create_params.dart';

abstract class CustomerReservationsRepository {
  Future<MultiResult<Failure, CustomerReservationEntity>> create(
    CustomerReservationCreateParams params,
  );

  Future<MultiResult<Failure, List<CustomerReservationEntity>>> listMine({
    ReservationRequestStatus? status,
    int limit = 50,
    int offset = 0,
  });

  Future<MultiResult<Failure, CustomerReservationEntity>> get(int id);

  Future<MultiResult<Failure, CustomerReservationEntity>> cancel(int id);
}
