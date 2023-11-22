package com.bundleupdater;

import android.graphics.Color;

public class UIColorHelper {

  public static int colorFromHexString(String hexString) {
    String cleanString = hexString.replace("#", "");
    if (cleanString.length() == 3) {
      cleanString =
        cleanString.substring(0, 1) +
        cleanString.substring(0, 1) +
        cleanString.substring(1, 2) +
        cleanString.substring(1, 2) +
        cleanString.substring(2, 3) +
        cleanString.substring(2, 3);
    }
    if (cleanString.length() == 6) {
      cleanString = cleanString + "ff";
    }

    int baseValue = (int) Long.parseLong(cleanString, 16);

    int alpha = Color.alpha(baseValue);
    int red = Color.red(baseValue);
    int green = Color.green(baseValue);
    int blue = Color.blue(baseValue);

    return Color.argb(alpha, red, green, blue);
  }

  public static int colorWithHexString(String hexString) {
    String colorString = hexString.replace("#", "").toUpperCase();
    int alpha, red, blue, green;

    switch (colorString.length()) {
      case 3: // #RGB
        alpha = 255;
        red = colorComponentFrom(colorString, 0, 1);
        green = colorComponentFrom(colorString, 1, 1);
        blue = colorComponentFrom(colorString, 2, 1);
        break;
      case 4: // #ARGB
        alpha = colorComponentFrom(colorString, 0, 1);
        red = colorComponentFrom(colorString, 1, 1);
        green = colorComponentFrom(colorString, 2, 1);
        blue = colorComponentFrom(colorString, 3, 1);
        break;
      case 6: // #RRGGBB
        alpha = 255;
        red = colorComponentFrom(colorString, 0, 2);
        green = colorComponentFrom(colorString, 2, 2);
        blue = colorComponentFrom(colorString, 4, 2);
        break;
      case 8: // #AARRGGBB
        alpha = colorComponentFrom(colorString, 0, 2);
        red = colorComponentFrom(colorString, 2, 2);
        green = colorComponentFrom(colorString, 4, 2);
        blue = colorComponentFrom(colorString, 6, 2);
        break;
      default:
        throw new IllegalArgumentException(
          "Invalid color value " +
          hexString +
          ". It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB"
        );
    }
    return Color.argb(alpha, red, green, blue);
  }

  private static int colorComponentFrom(String string, int start, int length) {
    String substring = string.substring(start, start + length);
    String fullHex = length == 2 ? substring : substring + substring;
    return Integer.parseInt(fullHex, 16);
  }
}
