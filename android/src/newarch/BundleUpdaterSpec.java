package com.bundleupdater;

import com.facebook.react.bridge.ReactApplicationContext;

abstract class BundleUpdaterSpec extends NativeBundleUpdaterSpec {
  BundleUpdaterSpec(ReactApplicationContext context) {
    super(context);
  }
}
