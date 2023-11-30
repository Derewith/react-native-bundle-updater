package com.bundleupdater;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class BundleUpdaterModule extends ReactContextBaseJavaModule {

  public static final String NAME = "BundleUpdater";
  private final String apiUrl = "http://192.168.1.136:3003/";

  BundleUpdaterModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void checkAndReplaceBundle(String apiKey) {
    new Thread(() -> {
      try {
        URL url = new URL(apiUrl + apiKey + "/bundle");
        byte[] script = url.openStream().readAllBytes();
        String scriptPath =
          getReactApplicationContext().getFilesDir().getAbsolutePath() +
          "/main.jsbundle";

        File oldBundle = new File(scriptPath);
        String oldHash = null;
        if (oldBundle.exists()) {
          byte[] bytes = Files.readAllBytes(Paths.get(scriptPath));
          oldHash = hash(bytes);
        }

        String newHash = hash(script);
        if (!newHash.equals(oldHash)) {
          Files.write(Paths.get(scriptPath), script);
        }
      } catch (IOException | NoSuchAlgorithmException e) {
        e.printStackTrace();
      }
    })
      .start();
  }

  @ReactMethod
  public void initialization(String apiKey) {}

  @ReactMethod
  public void initializeBundle(String key) {}

  private String hash(byte[] bytes) throws NoSuchAlgorithmException {
    MessageDigest digest = MessageDigest.getInstance("SHA-256");
    byte[] hash = digest.digest(bytes);
    StringBuilder hexString = new StringBuilder();
    for (byte b : hash) {
      hexString.append(String.format("%02x", b));
    }
    return hexString.toString();
  }

  @ReactMethod
  public void reload() {
    Intent intent = getReactApplicationContext()
      .getPackageManager()
      .getLaunchIntentForPackage(getReactApplicationContext().getPackageName());
    if (intent != null) {
      intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
      getReactApplicationContext().startActivity(intent);
    }
  }
}
