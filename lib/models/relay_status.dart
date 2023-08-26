import '../utils/client_connected.dart';

class RelayStatus {
  String addr;

  RelayStatus(this.addr);

  int connected = ClientConneccted.UN_CONNECT;

  int noteReceived = 0;

  int error = 0;
}
