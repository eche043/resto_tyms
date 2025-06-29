import '../const/const.dart';

Widget normalText({text, color = white, size = 8.0}) {
  return "$text".text.color(color).size(size).make();
}

Widget boldText({text, color = white, size = 14.0}) {
  return "$text"
      .text
      .fontWeight(FontWeight.w500)
      .color(color)
      .fontFamily('Poppins')
      .size(size)
      .make();
}
