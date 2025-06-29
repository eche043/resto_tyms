import 'const.dart';

Widget loadingIndicator({circleColor = appColor}) {
  return Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(circleColor),
    ),
  );
}
