import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy_app/view/orderScreen/active_order_screen.dart';

import '../../global/global_instances.dart';

class LockBoxScreen extends StatefulWidget {
  final List<String> selectedOrderIds;

  const LockBoxScreen({Key? key, required this.selectedOrderIds}) : super(key: key);

  @override
  _LockBoxScreenState createState() => _LockBoxScreenState();
}

class _LockBoxScreenState extends State<LockBoxScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;
  bool isConnecting = false;
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    var status = await Permission.bluetoothScan.status;
    if (status.isDenied) {
      await Permission.bluetoothScan.request();
    }
    status = await Permission.bluetoothConnect.status;
    if (status.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
    checkBluetooth();
  }

  Future<void> checkBluetooth() async {
    bool isOn = await flutterBlue.isOn;
    setState(() {
      isBluetoothOn = isOn;
    });

    if (!isBluetoothOn) {
      showBluetoothDialog();
    }
  }

  void showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bluetooth Kapalı'),
        content: Text('Lütfen Bluetooth\'u açın.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> connectToDevice() async {
    setState(() {
      isConnecting = true;
    });

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    var subscription = flutterBlue.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (result.device.name == 'HC-06') {
          await flutterBlue.stopScan();
          try {
            await result.device.connect();
            setState(() {
              connectedDevice = result.device;
            });
            discoverServices(result.device);
            break;
          } catch (e) {
            print('Bağlantı hatası: $e');
          }
        }
      }
    });

    await Future.delayed(Duration(seconds: 4));
    subscription.cancel();
    setState(() {
      isConnecting = false;
    });
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            targetCharacteristic = characteristic;
          });
          break;
        }
      }
    }
  }

  Future<void> sendData(String data) async {
    if (targetCharacteristic != null) {
      await targetCharacteristic!.write(utf8.encode(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sipariş Teslimi"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Seçilen Siparişler:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...widget.selectedOrderIds.map((id) => Text(id)).toList(),
            SizedBox(height: 20),
            if (connectedDevice == null)
              ElevatedButton(
                onPressed: isConnecting ? null : connectToDevice,
                child: Text("Cihaza Bağlan"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            if (connectedDevice != null)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => sendData('O\n'),  // Komutun 'O\n' olarak gönderildiğinden emin olun
                    child: Text("Kutuyu Aç"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => sendData('C\n'),  // Komutun 'C\n' olarak gönderildiğinden emin olun
                    child: Text("Kutuyu Kapat"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.selectedOrderIds.forEach((orderId) {
                        orderViewModel.deliverOrderToRider(orderId);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveOrdersScreen(),),);

                      });
                    },
                    child: Text("Siparişi Kuryeye Teslim Et"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
