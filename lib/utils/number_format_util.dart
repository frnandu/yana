import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberFormatUtil {
  static String format(int num) {
    String numStr = num.toString();
    if (num > 1000000) {
      numStr = (num / 1000000).toStringAsFixed(1) + "m";
    } else if (num > 1000) {
      numStr = (num / 1000).toStringAsFixed(1) + "k";
    }

    return numStr;
  }

  static RichText formatBitcoinAmount(double amount, TextStyle empty, TextStyle filled) {
    // Convert the amount to a string with desired formatting
    String formattedAmount = amount.toStringAsFixed(8); // 8 decimal places

    String beforeFirstZero="";
    String afterFirstZero="";

    int i=0;
    bool afterDecimal = false;
    bool afterFirstNonZero = false;
    int decimalPosition = 0;
    while (i < formattedAmount.length) {
      if (formattedAmount[i] == '.') {
        afterDecimal = true;
        if (afterFirstNonZero) {
          afterFirstZero += ".";
        } else {
          beforeFirstZero += ".";
        }
        i++;
        continue;
      }
      if (formattedAmount[i]!='0') {
        afterFirstNonZero = true;
      }
      String additionalSpace = "";
      if (decimalPosition == 2 || decimalPosition == 5) {
        additionalSpace = " ";
      }

      if (afterFirstNonZero) {
        afterFirstZero += additionalSpace + formattedAmount[i];
      } else {
        beforeFirstZero += additionalSpace + formattedAmount[i];
      }
      i++;
      if (afterDecimal) {
        decimalPosition++;
      }
    }


    // Find the index of the first non-zero digit
    // int firstNonZeroIndex = formattedAmount.indexOf(RegExp(r'[1-9]'));
    //
    // // Split the string into parts before and after the first non-zero digit
    // String beforeFirstZero = firstNonZeroIndex!=-1 ? formattedAmount.substring(0, firstNonZeroIndex): formattedAmount;
    // String afterFirstZero = firstNonZeroIndex!=-1 ? formattedAmount.substring(firstNonZeroIndex) : "";
    //
    // afterFirstZero = afterFirstZero.replaceAllMapped(
    //     RegExp(r'(\d)(?=(?:\d{3})+(?!\d))'), (match) => '${match[1]} ');
    //
    // // If there are no digits after the decimal point, add a space
    // if (afterFirstZero.length==3) {
    //   afterFirstZero = ' $afterFirstZero';
    // }
    // String integers = beforeFirstZero.substring(0, beforeFirstZero.indexOf("."));
    // String decimals = beforeFirstZero.substring(beforeFirstZero.indexOf("."), beforeFirstZero.length);
    // if (decimals.length>3) {
    //   beforeFirstZero = integers + decimals.substring(0,3) + " " + decimals.substring(3,decimals.length);
    // }
    //
    // // Add spaces every 3 characters before the decimal point, excluding leading zeros
    // beforeFirstZero = beforeFirstZero.replaceAllMapped(
    //     RegExp(r'(\d)(?=(?:\d{3})+(?!\d))'), (match) => '${match[1]} ');


    // Create a list of TextSpans with different colors
    List<TextSpan> textSpans = [

      TextSpan(
        text: beforeFirstZero,
        style: empty,
      ),
      TextSpan(
        text: afterFirstZero,
        style: filled,
      ),
    ];
    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
}
