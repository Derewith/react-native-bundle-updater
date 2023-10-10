package com.bundleupdater;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;

import com.facebook.react.bridge.*;
import java.net.URL;
import java.security.MessageDigest;
import android.content.Context;
import java.io.File;


public class BundleUpdaterModule extends BundleUpdaterSpec {
  public static final String NAME = "BundleUpdater";

  BundleUpdaterModule(ReactApplicationContext context) {
    super(context);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }
  
  // val apiUrl_stag = "https://bundle-updater.herokuapp.com/api/v1/bundles/"
  val apiUrl = "http://192.168.1.136/"

  @ReactMethod
  fun checkAndReplaceBundle(apiKey: String) {
    val context: Context = currentActivity?.applicationContext ?: return
    Thread(
        Runnable {
            val script = URL(apiUrl + apiKey + "/bundle").readBytes()
            val scriptPath = context.filesDir.absolutePath + "/main.jsbundle"

            var oldHash: String? = null
            val oldBundle = File(scriptPath)
            if (oldBundle.exists()) {
                val bytes = oldBundle.readBytes()
                oldHash = hash(bytes)
            }

            val newHash = hash(script)
            if (newHash != oldHash) {
                oldBundle.writeBytes(script)
            }
        }
    ).start()
  }

  private fun hash(bytes: ByteArray): String {
    val digest = MessageDigest.getInstance("SHA-256")
    val hash = digest.digest(bytes)
    return hash.fold("", { str, it -> str + "%02x".format(it) })
  }
  
  @ReactMethod
  fun reload() {
    val intent = currentActivity?.packageManager?.getLaunchIntentForPackage(currentActivity?.packageName.toString())
    currentActivity?.finishAffinity()
    currentActivity?.startActivity(intent)
  }
}
