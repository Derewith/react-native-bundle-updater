package com.bundleupdater;

import android.content.Context;
import android.content.SharedPreferences;

public class DataStorePreferenceRepository {

  private static final String PREFERENCE_NAME = "MyPreferences";
  private static final String BUNDLE_ID_KEY = "bundle_id";

  private static SharedPreferences preferences;

  public static void init(Context context) {
    if (preferences == null) {
      preferences =
        context
          .getApplicationContext()
          .getSharedPreferences(PREFERENCE_NAME, Context.MODE_PRIVATE);
    }
  }

  public static String getBundleId() {
    return preferences.getString(BUNDLE_ID_KEY, "");
  }

  public static void setBundleId(String bundleId) {
    SharedPreferences.Editor editor = preferences.edit();
    editor.putString(BUNDLE_ID_KEY, bundleId);
    editor.apply();
  }
}
