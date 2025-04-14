import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

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
    selectedPort.config = _getConfig();
    updateState('Selected port: $port');
    open();
    streamPortsOpen();
  }

  void streamPortsOpen() {
    if (_reader != null) return;
    updateState('Open Stream');
    _reader = SerialPortReader(selectedPort, timeout: 1000);

    _readerStream = _reader!.stream.listen((Uint8List data) {
      updateState(' $data');
      updateState('-- UTF8: ${utf8.decoder.convert(data.toList())}');
    }, onError: (e) {
      updateState('Error: $e');
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

  void updateBaudRate(int baudRate) {
    selectedPort.config.baudRate = baudRate;
    updateState('BaudRate: $baudRate');
  }

  SerialPortConfig _getConfig([int? address]) {
    late SerialPortConfig config;
    if (address != null) {
      config = SerialPortConfig.fromAddress(address);
    } else {
      config = SerialPortConfig();
    }
    config
      ..baudRate = 9600 // Скорость
      ..bits = 8 // 8 бит данных
      ..stopBits = 1 // 1 стоп-бит
      ..parity = SerialPortParity.none // Без чётности
      ..setFlowControl(SerialPortFlowControl.rtsCts)
      ..rts = SerialPortRts.flowControl
      ..cts = SerialPortCts.flowControl
      ..dsr = SerialPortDsr.flowControl
      ..dtr = SerialPortDtr.flowControl; // Без управления потоком
    // ..parity = 1
    // config..stopBits = 1;
    return config;
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
        int mode = SerialPortMode.read;
        selectedPort.open(mode: mode);
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
      updateState("-- UTF8: ${utf8.decode(read)}");
    } catch (e) {
      updateState(e.toString());
    }
  }

  void close() {
    try {
      if (!selectedPort.isOpen) {
        updateState('Port already closed (${selectedPort.address})');
      } else {
        streamPortsClose();
        selectedPort.close();
        // selectedPort.dispose();
        updateState('Closed port: ${selectedPort.address}');
      }
    } catch (e) {
      updateState(e.toString());
    }
  }

  void updateState(String text) {
    log(text);
    status.add(text);
    notifyListeners();
  }
}
