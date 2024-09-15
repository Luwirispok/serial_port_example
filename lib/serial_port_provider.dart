import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialPortProvider extends ChangeNotifier {
  late SerialPort selectedPort;
  List<String> availablePorts = [];
  List<SerialPort> ports = [];

  List<String> status = [];

  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _readerStream;

  void initPort(SerialPort port) {
    selectedPort = port;
    updateState('Selected port: $port');
  }

  void streamPortsOpen() {
    if (_reader != null) return;
    updateState('Open Stream');
    _reader = SerialPortReader(selectedPort);

    _readerStream = _reader!.stream.listen((Uint8List data) {
      updateState(' $data');
      updateState('-- String: ${String.fromCharCodes(data)}');
      updateState('-- UTF8: ${utf8.decoder.convert(data.toList())}');
    });
  }

  void streamPortsClose() {
    if (_readerStream != null) {
      _readerStream!.cancel();
      _readerStream = null;
    }
    if (_reader != null) {
      _reader!.close();
      _reader = null;
    }
    updateState('Close Stream');
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
