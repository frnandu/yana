import '../utils/client_connected.dart';

class RelayStatus {
  String addr;

  RelayStatus(this.addr);

  bool connecting = false;

  int noteReceived = 0;

  int error = 0;
}
