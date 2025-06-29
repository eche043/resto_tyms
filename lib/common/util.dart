import 'package:flutter/material.dart';
import 'package:odrive_restaurant/common/const/colors.dart';

int toInt(String str) {
  int ret = 0;
  try {
    ret = int.parse(str);
  } catch (_) {}
  return ret;
}

double toDouble(String str) {
  double ret = 0;
  try {
    ret = double.parse(str);
  } catch (_) {}
  return ret;
}

getStatus(int status) {
  switch (status) {
    case 1:
      return {"title": "Received", "color": golden};
    case 2:
      return {"title": "Preparing", "color": darkGrey};
    case 3:
      return {"title": "Ready", "color": Colors.blue};
    case 4:
      return {"title": "On the way", "color": darkBlue};
    case 5:
      return {"title": "Delivered", "color": appColor};
    case 6:
      return {"title": "Cancelled", "color": Colors.red};
  }
}
