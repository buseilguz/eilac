import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/view/orderScreen/open_box_screen.dart';
import '../../viewModel/order_view_model.dart';
import 'package:geolocator/geolocator.dart';

class CourierTrackingScreen extends StatefulWidget {
  final String courierId;
  final String orderId; // Yeni eklenen orderId parametresi

  const CourierTrackingScreen({required this.courierId, required this.orderId}); // Constructor'a orderId eklendi

  @override
  _CourierTrackingScreenState createState() => _CourierTrackingScreenState();
}

class _CourierTrackingScreenState extends State<CourierTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late BitmapDescriptor customIcon;
  bool _isMapCreated = false;
  LatLng? _courierLatLng;
  LatLng? _orderLatLng; // Siparişin konumu için LatLng değişkeni eklendi
  bool _isDeliveryButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _loadAssetsAndInitialize(); // Asenkron işlemleri başlat
  }

  void _loadAssetsAndInitialize() async {
    await _setCustomMapPin();
    loadOrderAddress(widget.orderId);
  }

  Future<void> _setCustomMapPin() async {
    try {
      customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(35, 35)),
        'images/kurye-ikon.png', // .png olarak değiştirildi
      );
      print('Bitmap başarıyla yüklendi');
    } catch (e) {
      print('Bitmap yükleme hatası: $e');
    }
  }

  Future<void> _moveCamera() async {
    if (_courierLatLng != null && _isMapCreated) {
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(_courierLatLng!));
    }
  }

  void loadOrderAddress(String orderId) {
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    orderViewModel.loadOrderAddress(orderId).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          List<Map<String, dynamic>> orderAddresses = orderViewModel.orderAddress;
          Map<String, dynamic>? orderData = orderAddresses.firstWhere(
                (order) => order['id'] == orderId,
            orElse: () => {},
          );

          if (orderData.isNotEmpty) {
            _orderLatLng = LatLng(orderData['latitude'], orderData['longitude']);
            print('Order LatLng: $_orderLatLng');
          } else {
            print('Belirtilen orderId ile eşleşen sipariş bulunamadı veya sipariş bilgisi boş.');
          }
        });
        Timer.periodic(Duration(seconds: 20), (timer) {
          _checkProximity();
        }); // Proximity kontrolünü burada yapın
      });
    }).catchError((error) {
      print("Sipariş adresi yüklenirken hata oluştu: $error");
    });
  }

  void _checkProximity() {
    if (_courierLatLng != null && _orderLatLng != null) {
      double distance = Geolocator.distanceBetween(
        _courierLatLng!.latitude,
        _courierLatLng!.longitude,
        _orderLatLng!.latitude,
        _orderLatLng!.longitude,
      );

      setState(() {
        _isDeliveryButtonVisible = distance <= 10.0; // 10 metre içinde ise buton görünsün
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Kurye Takibi"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          StreamBuilder<Position>(
            stream: orderViewModel.streamCourierLocation(widget.courierId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Hata: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return Center(child: Text("Konum verisi bulunamadı"));
              }

              final position = snapshot.data!;
              _courierLatLng = LatLng(position.latitude, position.longitude);

              if (_isMapCreated) {
                _moveCamera();
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _courierLatLng!,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.courierId),
                    position: _courierLatLng!,
                    //icon: customIcon,
                  ),
                  if (_orderLatLng != null)
                    Marker(
                      markerId: MarkerId(widget.orderId),
                      position: _orderLatLng!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    ),
                },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  setState(() {
                    _isMapCreated = true;
                  });
                  _moveCamera();
                },
              );
            },
          ),
          if (_isDeliveryButtonVisible)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpenBoxScreen(selectedOrderId: widget.orderId),
                    ),
                  );
                },
                child: Text("Siparişi Teslim Al"),
              ),
            ),
        ],
      ),
    );
  }
}
