import 'package:flutter/material.dart';

class CharacterLimitWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CharacterLimitWidget({
    Key? key,
    required this.text,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String limitedText = text.length <= 20 ? text : text.substring(0, 20);

    return Text(
      limitedText,
      style: style, // Utiliser le style passé en paramètre
    );
  }
}
