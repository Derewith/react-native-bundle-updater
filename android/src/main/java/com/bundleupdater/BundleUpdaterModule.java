package com.bundleupdater;

import android.app.Activity;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.jakewharton.processphoenix.ProcessPhoenix;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

@ReactModule(name = "BundleUpdaterModule")
public class BundleUpdaterModule extends ReactContextBaseJavaModule {

  // private static BundleUpdaterModule instance;

  public static final String NAME = "BundleUpdater";
  private final String _apiUrl = "http://192.168.1.136:3003";
  private boolean isRecreating = false;

  public BundleUpdaterModule(ReactApplicationContext context) {
    super(context);
    DataStorePreferenceRepository.init(context);
    // instance = this;
  }

  // public static BundleUpdaterModule getInstance(
  //   ReactApplicationContext context
  // ) {
  //   if (instance == null) {
  //     instance = new BundleUpdaterModule(context);
  //   }
  //   return instance;
  // }

  // public static BundleUpdaterModule getInstance() {
  //   return instance;
  // }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  /** INIT CORE SDK */
  public void checkAndReplaceBundle(String apiKey) {
    new Thread(() -> {
      try {
        URL url = new URL(_apiUrl + apiKey + "/bundle");
        byte[] script = new byte[0];

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
          script = url.openStream().readAllBytes();
        }

        String scriptPath =
          getReactApplicationContext().getFilesDir().getAbsolutePath() +
          "/main.jsbundle";

        File oldBundle = new File(scriptPath);
        String oldHash = null;
        if (oldBundle.exists()) {
          byte[] bytes = new byte[0];
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            bytes = Files.readAllBytes(Paths.get(scriptPath));
          }
          oldHash = hash(bytes);
        }

        String newHash = hash(script);
        if (!newHash.equals(oldHash)) {
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Files.write(Paths.get(scriptPath), script);
          }
        }
      } catch (IOException | NoSuchAlgorithmException e) {
        e.printStackTrace();
      }
    })
      .start();
  }

  private void showBottomSheet() {
    var context = getReactApplicationContext();
    //.runOnUiQueueThread();
    BundleUpdaterBottomSheetViewController bottomSheet = new BundleUpdaterBottomSheetViewController(
      context
    );
    bottomSheet.show();
  }

  @ReactMethod
  public void initialization(String apiKey, Promise promise) {
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
      String savedBundle = DataStorePreferenceRepository.getBundleId();
      String urlString = _apiUrl + "/project/" + apiKey + "/initialize";
      JsonObject body = new JsonObject();

      Log.d("SDK", urlString);
      // TODO add log things
      // body.addProperty("metaData", getMetaData());
      body.addProperty("bundleId", savedBundle);

      try {
        String jsonBody = new Gson().toJson(body);
        RequestBody requestBody = RequestBody.create(
          MediaType.parse("application/json"),
          jsonBody
        );
        Request request = new Request.Builder()
          .url(urlString)
          .post(requestBody)
          .build();

        OkHttpClient client = new OkHttpClient();
        client
          .newCall(request)
          .enqueue(
            new Callback() {
              @Override
              public void onFailure(Call call, IOException e) {
                Log.e("SDK", "Initialization error: " + e.getMessage());
                promise.reject("INITIALIZATION_ERROR", e.getMessage());
              }

              @Override
              public void onResponse(Call call, Response response)
                throws IOException {
                if (response.isSuccessful()) {
                  String responseData = response.body().string();
                  Log.d("SDK", "Initialization response: " + responseData);
                  JsonObject responseJson = new Gson()
                    .fromJson(responseData, JsonObject.class);
                  JsonElement updateRequiredValue = responseJson.get(
                    "update_required"
                  );
                  if (updateRequiredValue != null) {
                    if (updateRequiredValue.isJsonPrimitive()) {
                      promise.resolve("Update not required");
                    } else {
                      DataStorePreferenceRepository.setBundleId(
                        responseJson.get("bundleId").getAsString()
                      );

                      // showBottomSheet(updateRequiredValue);
                      Log.e("SDK", "WE SHOULD SHOW THE BOTTOM SHEET ");
                      showBottomSheet();
                      promise.resolve("Update required");
                    }
                  }
                } else {
                  Log.e("SDK", "Initialization error: " + response.message());
                  promise.reject("INITIALIZATION_ERROR", response.message());
                }
              }
            }
          );
      } catch (Exception e) {
        Log.e("SDK", "JSON serialization error: " + e.getMessage());
        promise.reject("JSON_SERIALIZATION_ERROR", e.getMessage());
      }
    } else {
      promise.reject("Error", "Android version not supported");
    }
  }

  // public CompletableFuture<String> initialization(String apiKey) {
  //   CompletableFuture<String> future = null;
  //   if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
  //     future = new CompletableFuture<>();
  //     try {
  //       // Your initialization logic here
  //       String result = "Initialization success";
  //       future.complete(result);
  //     } catch (Exception e) {
  //       future.completeExceptionally(e);
  //     }
  //   }
  //   return future;
  // }

  private String hash(byte[] bytes) throws NoSuchAlgorithmException {
    MessageDigest digest = MessageDigest.getInstance("SHA-256");
    byte[] hash = digest.digest(bytes);
    StringBuilder hexString = new StringBuilder();
    for (byte b : hash) {
      hexString.append(String.format("%02x", b));
    }
    return hexString.toString();
  }

  /** END CORE SDK */

  /** INIT RELOAD */
  private LifecycleEventListener mLifecycleEventListener = null;

  private void loadBundleLegacy() {
    final Activity currentActivity = getCurrentActivity();
    if (currentActivity == null) {
      return;
    }

    currentActivity.runOnUiThread(
      new Runnable() {
        @Override
        public void run() {
          isRecreating = true;
          currentActivity.recreate();
        }
      }
    );
  }

  private void loadBundle() {
    if (isRecreating) {
      // The activity is being recreated, don't perform operations on it
      return;
    }
    clearLifecycleEventListener();
    try {
      final ReactInstanceManager instanceManager = resolveInstanceManager();
      if (instanceManager == null) {
        return;
      }

      new Handler(Looper.getMainLooper())
        .post(
          new Runnable() {
            @Override
            public void run() {
              try {
                instanceManager.recreateReactContextInBackground();
              } catch (Throwable t) {
                loadBundleLegacy();
              }
            }
          }
        );
    } catch (Throwable t) {
      loadBundleLegacy();
    }
  }

  private static InstanceHolder mReactInstanceHolder;

  static ReactInstanceManager getReactInstanceManager() {
    return null;
  }

  private ReactInstanceManager resolveInstanceManager()
    throws NoSuchFieldException, IllegalAccessException {
    return null;
  }

  private void clearLifecycleEventListener() {}

  @ReactMethod
  public void Restart() {
    ProcessPhoenix.triggerRebirth(getReactApplicationContext());
  }

  @ReactMethod
  public void restart() {
    ProcessPhoenix.triggerRebirth(getReactApplicationContext());
  }
  /** END RELOAD */

}
