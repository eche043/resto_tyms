import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/const/colors.dart';

class CustomRadioTile2 extends StatelessWidget {
  final String title;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  final Color activeColor;
  final String montant;

  const CustomRadioTile2(
      {super.key,
      required this.title,
      required this.value,
      required this.groupValue,
      required this.onChanged,
      required this.activeColor,
      required this.montant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(5, 10),
          ),
        ],
      ),
      child: RadioListTile(
        activeColor: activeColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: blackColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            Text("$montant FCFA")
          ],
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }
}
