import 'package:odrive_restaurant/common/const/const.dart';

class BgContainer extends StatelessWidget {
  const BgContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
          image:
              DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover)),
    );
  }
}
