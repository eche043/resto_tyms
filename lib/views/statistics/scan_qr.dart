import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/views/orders/orders_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({Key? key}) : super(key: key);

  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  // Déclaration d'une liste de caméras
  //late List<CameraDescription> cameras;
  late CameraController _controller;
  bool _isCameraInitialized = false;
  MobileScannerController cameraController = MobileScannerController();
  TextEditingController qr_code_controller = TextEditingController();

  //late final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  //late QRViewController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestCameraPermission();
    _requestMicroPermission();
    initializeCamera();
  }

  void _requestCameraPermission() async {
    // Vérifier si l'autorisation pour la caméra a été accordée
    var cameraStatus = await Permission.camera.status;

    if (cameraStatus.isPermanentlyDenied) {
      // Si l'autorisation a été refusée de manière permanente, vous pouvez rediriger l'utilisateur vers les paramètres de l'application pour accorder les autorisations nécessaires
      openAppSettings();
    } else if (cameraStatus.isDenied) {
      // Si l'autorisation a été refusée, demandez-la
      cameraStatus = await Permission.camera.request();
    }
  }

  void _requestMicroPermission() async {
    print("innnnnnnnnnnnnnnnnnnnnnnnnn");
    // Vérifier si l'autorisation pour le microphone a été accordée
    var microphoneStatus = await Permission.microphone.status;
    print("mmmmmmmmm************");
    print(microphoneStatus);
    print("mmmmmmmmm************");
    if (microphoneStatus.isPermanentlyDenied) {
      // Si l'autorisation a été refusée de manière permanente, vous pouvez rediriger l'utilisateur vers les paramètres de l'application pour accorder les autorisations nécessaires
      openAppSettings();
    } else if (microphoneStatus.isDenied) {
      // Si l'autorisation a été refusée, demandez-la
      microphoneStatus = await Permission.microphone.request();
    }
  }

  void initializeCamera() async {
    // Récupérez la liste des caméras disponibles
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  void _foundBarcode(Barcode barcode, MobileScannerArguments? args) async {
    final String code = barcode.rawValue ?? "---";
    print('Barcode found! $code');
    setState(() {
      qr_code_controller.text = code;
    });
  }

  void submitQrCode(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;
    var response = await qrCodeScanner(code);
    print(response);
    if (response['error'] == '0') {
      Fluttertoast.showToast(msg: 'Commande terminée');
      Get.offAll(() => OrdersScreen());
    } else if (response['error'] == '1') {
      Fluttertoast.showToast(
          msg: 'Pas de commande lié à ce Qr', backgroundColor: red);
      //Get.offAll(() => HomeScreen(userId: userId));
    } else {
      Fluttertoast.showToast(msg: response['error'], backgroundColor: red);
      //Get.offAll(() => HomeScreen(userId: userId));
    }
  }

  @override
  void dispose() {
    // Libérez les ressources du contrôleur de caméra
    _controller.dispose();
    //controller.dispose();
    super.dispose();
  }

  /*  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Ici, vous pouvez utiliser scanData pour obtenir la valeur du QR code scanné
      print('QR Code Scanned: ${scanData.code}');
    });
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(
            leadingImageAsset: drawer,
            title: 'Commande Qr',
            notificationImageAsset: notificationIcon,
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 80.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Please scan the QR code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please scan the QR code or write your delivery code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: fontGrey.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 100),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: MobileScanner(
                      allowDuplicates: true,
                      controller: cameraController,
                      onDetect: _foundBarcode,
                    ),
                    /* child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ), */
                    /* child: _isCameraInitialized
                        ? CameraPreview(_controller)
                        : CircularProgressIndicator(), */
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: qr_code_controller,
                      decoration: InputDecoration(
                        hintText: 'Write delivery code here',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle submit button press
                              submitQrCode(qr_code_controller.text);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(appColor),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Image.asset(
                    clickIcon,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
