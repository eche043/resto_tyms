import 'package:odrive_restaurant/common/const/const.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        height: 10.63,
        width: 22,
        margin: const EdgeInsets.only(top: 4.69),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.value ? white : white,
            border: Border.all(color: blackColor)),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: widget.value ? 0 : 10,
              bottom: 0.02,
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                  color: widget.value ? appColor : red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
