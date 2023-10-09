package com.bundleupdater;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Promise;

abstract class BundleUpdaterSpec extends ReactContextBaseJavaModule {
  BundleUpdaterSpec(ReactApplicationContext context) {
    super(context);
  }

  // public abstract void multiply(double a, double b, Promise promise);
}
