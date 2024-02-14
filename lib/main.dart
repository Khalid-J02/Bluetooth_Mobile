import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    _startBluetoothScan();
  }

  void _startBluetoothScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name == 'your_device_name') {
          _connectToDevice(result.device);
          break;
        }
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    if (device.state == BluetoothDeviceState.disconnected) {
      await device.connect();
      setState(() {
        connectedDevice = device;
      });
    }
  }

  void _sendCommand(String command) async {
    if (connectedDevice != null && connectedDevice!.state == BluetoothDeviceState.connected) {
      List<BluetoothService> services = await connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            await characteristic.write(utf8.encode(command));
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Bluetooth Control'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularButton(
                  onPressed: () {
                    _sendCommand('Forward');
                  },
                  icon: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                CircularButton(
                  onPressed: () {
                    _sendCommand('Backward');
                  },
                  icon: Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                  )
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularButton(
                  onPressed: () {
                    _sendCommand('Right');
                  },
                  icon: Icon(
                    Icons.arrow_forward_outlined,
                    color: Colors.white,
                  )
                ),
                SizedBox(height: 20),
                CircularButton(
                  onPressed: () {
                    _sendCommand('Left');
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )
                ),
              ],
            ),
            CircularButton(
              onPressed: () {
                _sendCommand('Enable');
              },
              text: 'Enable',
            ),
          ],
        ),
      ),
    );
  }
}


class CircularButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? icon;
  final String? text;

  CircularButton({required this.onPressed, this.icon, this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
      ),
      child: icon ?? Text(text ?? ''),
    );
  }
}
