import 'package:country_code_picker/country_code_picker.dart';

import '../const/const.dart';

Widget customTextField({
  label,
  hint,
  controller,
  isDesc = false,
  bool obscureText = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      style: const TextStyle(color: fontGrey),
      maxLines: isDesc ? 4 : 1,
      obscureText: obscureText,
      cursorColor: blackColor,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fontGrey),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: fontGrey.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    ),
  );
}
/* Widget customTextField({
  label,
  hint,
  controller,
  isDesc = false,
  bool obscureText = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    style: const TextStyle(color: fontGrey),
    maxLines: isDesc ? 4 : 1,
    obscureText: obscureText,
    cursorColor: blackColor,
    controller: controller,
    decoration: InputDecoration(
      isDense: true,
      labelText: label,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkGrey.withOpacity(0.5)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: fontGrey),
      ),
      hintText: hint,
      hintStyle: const TextStyle(
        color: fontGrey,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      suffixIcon: suffixIcon,
    ),
    validator: validator,
  );
} */

Widget phoneContainer({
  label,
  hint,
  controller,
  isDesc = false,
  bool obscureText = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
  required Null Function(dynamic value) onChange,
}) {
  return Container(
    decoration: BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      style: const TextStyle(color: fontGrey),
      keyboardType: TextInputType.number,
      maxLines: isDesc ? 4 : 1,
      obscureText: obscureText,
      cursorColor: blackColor,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        prefixIcon: CountryCodePicker(
          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
          initialSelection: '+225',
          favorite: ['+225', 'CI'],

          textStyle: TextStyle(color: appColor),
          showFlag: true,
          showDropDownButton: true,
          onChanged: (value) {
            onChange(value);
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fontGrey),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: fontGrey.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    ),
  );
}
