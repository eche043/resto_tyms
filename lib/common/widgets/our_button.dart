import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../const/const.dart';

Widget customButton({
  required BuildContext context,
  required String title,
  required Function() onPress,
  String? imagePath,
  double? width, // Add width parameter
  double? height, // Add height parameter
  Color? color, // Add color parameter
  bool? isLoading = false,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize:
          Size(width ?? MediaQuery.of(context).size.width * 0.7, height ?? 48),
      maximumSize:
          Size(width ?? MediaQuery.of(context).size.width * 0.7, height ?? 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      backgroundColor: color ?? appColor,
      padding: const EdgeInsets.all(12.0),
    ),
    onPressed: onPress,
    child: isLoading!
        ? const SpinKitCircle(color: Colors.white, size: 20.0)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath != null) ...[
                Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                ),
                10.widthBox
              ],
              normalText(text: title, size: 16.0),
            ],
          ),
  );
}

Widget customButton2({
  required BuildContext context,
  required String title,
  required Function() onPress,
  String? imagePath,
  double? width, // Add width parameter
  double? height, // Add height parameter
  Color? color, // Add color parameter
  bool? isLoading = false,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize:
          Size(width ?? MediaQuery.of(context).size.width * 0.7, height ?? 48),
      maximumSize:
          Size(width ?? MediaQuery.of(context).size.width * 0.7, height ?? 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      backgroundColor: color ?? appColor,
      padding: const EdgeInsets.all(12.0),
    ),
    onPressed: onPress,
    child: isLoading!
        ? const SpinKitCircle(color: Colors.white, size: 20.0)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath != null) ...[
                Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                ),
                10.widthBox
              ],
              normalText(text: title, size: 16.0, color: appColor),
            ],
          ),
  );
}
