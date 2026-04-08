class Failure {
  final String type;
  final String? message;

  Failure({this.type = 'Error', this.message = 'Error'});
}

class ServerFailure extends Failure {
  ServerFailure({
    super.type = 'Server Error',
    super.message = 'An error occurred due to server issues.',
  });
}

class InternetConnectionFailure extends Failure {
  InternetConnectionFailure({
    super.type = 'Internet Error',
    super.message = 'Please check your connexion internet',
  });
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({
    super.type = 'Unkown Error',
    super.message = 'An unkown error has occured',
  });
}
