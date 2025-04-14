import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class SerialPortProvider extends ChangeNotifier {
  late SerialPort selectedPort;
  List<String> availablePorts = [];
  List<SerialPort> ports = [];

  List<String> status = [];

  bool _reader = false;

  void initPort(SerialPort port) {
    selectedPort = port;
    // selectedPort.config = _getConfig();
    updateState('Selected port: $port');
    open();
    streamPortsOpen();
  }

  void streamPortsOpen() async {
    try {
      if (_reader) return;
      updateState('Open Stream');
      _reader = true;
      while (_reader && selectedPort.isOpened) {
        await selectedPort
            .readBytes(1024, timeout: Duration(milliseconds: 1000))
            .then((Uint8List data) {
          updateState(' $data');
          updateState('-- UTF8: ${utf8.decoder.convert(data.toList())}');
        }, onError: (e) {
          updateState('Error: $e');
        });
      }
    } catch (e) {
      updateState(e.toString());
    }
  }

  void streamPortsClose() {
    if (_reader) {
      _reader = false;
    }
    updateState('Close Stream');
  }

  void updateBaudRate(int baudRate) {
    selectedPort.BaudRate = baudRate;
    updateState('BaudRate: $baudRate');
  }

  // SerialPortConfig _getConfig([int? address]) {
  //   late SerialPortConfig config;
  //   if (address != null) {
  //     config = SerialPortConfig.fromAddress(address);
  //   } else {
  //     config = SerialPortConfig();
  //   }
  //   config
  //     ..baudRate = 9600 // Скорость
  //     ..bits = 8 // 8 бит данных
  //     ..stopBits = 1 // 1 стоп-бит
  //     ..parity = SerialPortParity.none // Без чётности
  //     ..setFlowControl(SerialPortFlowControl.rtsCts)
      // ..rts = SerialPortRts.flowControl
  //     ..cts = SerialPortCts.flowControl
  //     ..dsr = SerialPortDsr.flowControl
  //     ..dtr = SerialPortDtr.flowControl; // Без управления потоком
  //   // ..parity = 1
  //   // config..stopBits = 1;
  //   return config;
  // }

  void getPorts() {
    List<PortInfo> list = SerialPort.getPortsWithFullMessages();
    availablePorts = list.map((info) => info.portName).toList();
    ports = availablePorts
        .map((String port) => SerialPort(port, BaudRate: 9600))
        .toList();
    updateState('Available ports: $availablePorts');
  }

  void open() {
    try {
      if (selectedPort.isOpened) {
        updateState('Port already open (${selectedPort.portName})');
      } else {
        selectedPort.open();
        updateState('Opened port: ${selectedPort.portName}');
      }
    } catch (e) {
      updateState(e.toString());
    }
  }

  void read() async {
    try {
      await selectedPort
          .readBytes(1024, timeout: Duration(milliseconds: 1000))
          .then((Uint8List data) {
        updateState(' $data');
        updateState('-- UTF8: ${utf8.decoder.convert(data.toList())}');
      }, onError: (e) {
        updateState('Error: $e');
      });
    } catch (e) {
      updateState(e.toString());
    }
  }

  void close() {
    try {
      if (!selectedPort.isOpened) {
        updateState('Port already closed (${selectedPort.portName})');
      } else {
        streamPortsClose();
        selectedPort.close();
        // selectedPort.dispose();
        updateState('Closed port: ${selectedPort.portName}');
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
