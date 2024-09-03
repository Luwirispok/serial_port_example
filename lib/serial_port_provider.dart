import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialPortProvider extends ChangeNotifier {
  late SerialPort selectedPort;
  List<String> availablePorts = [];
  List<SerialPort> ports = [];

  List<String> status = [];

  void initPort(SerialPort port) {
    selectedPort = port;
    updateState('Selected port: $port');
  }

  void getPorts() {
    availablePorts = SerialPort.availablePorts;
    ports = availablePorts.map((String port) => SerialPort(port)).toList();
    updateState('Available ports: $availablePorts');
  }

  void open() {
    try {
      if (selectedPort.isOpen) {
        updateState('Port already open (${selectedPort.address})');
      } else {
        int mode = SerialPortMode.readWrite;
        selectedPort.open(mode: SerialPortMode.readWrite);
        updateState('Opened port: ${selectedPort.address} in mode $mode');
      }
    } catch (e) {
      updateState(e.toString());
    }
  }

  void read() {
    try {
      final read = selectedPort.read(1024);
      updateState("Read $read");
    } catch (e) {
      updateState(e.toString());
    }
  }

  void close() {
    try {
      selectedPort.openReadWrite();
      if (!selectedPort.isOpen) {
        updateState('Port already closed (${selectedPort.address})');
      } else {
        selectedPort.dispose();
        selectedPort.close();
        updateState('Closed port: ${selectedPort.address}');
      }
    } catch (e) {
      updateState(e.toString());
    }
  }

  void updateState(String text) {
    status.add(text);
    notifyListeners();
  }
}
