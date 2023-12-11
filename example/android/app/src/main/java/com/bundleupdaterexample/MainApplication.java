package com.bundleupdaterexample;

import android.app.Application;
import android.content.Context;
import android.os.Handler;
import android.util.Log;
import com.bundleupdater.BundleUpdaterModule;
import com.bundleupdater.BundleUpdaterPackage;
import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint;
import com.facebook.react.defaults.DefaultReactNativeHost;
import com.facebook.soloader.SoLoader;
import java.io.File;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

  private final ReactNativeHost mReactNativeHost = new DefaultReactNativeHost(
    this
  ) {
    @Override
    public boolean getUseDeveloperSupport() {
      return BuildConfig.DEBUG;
    }

    @Override
    protected List<ReactPackage> getPackages() {
      @SuppressWarnings("UnnecessaryLocalVariable")
      List<ReactPackage> packages = new PackageList(this).getPackages();
      // Packages that cannot be autolinked yet can be added manually here, for example:
      // packages.add(new BundleUpdaterPackage());
      return packages;
    }

    @Override
    protected String getJSMainModuleName() {
      Context context = getApplicationContext();
      File localBundle = new File(
        context.getFilesDir().getAbsolutePath() + "/main.jsbundle"
      );
      return localBundle.exists() ? "main.jsbundle" : "index";
    }

    @Override
    protected boolean isNewArchEnabled() {
      return BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
    }

    @Override
    protected Boolean isHermesEnabled() {
      return BuildConfig.IS_HERMES_ENABLED;
    }
  };

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }

  @Override
  public void onCreate() {
      super.onCreate();
      SoLoader.init(this, false);

      // Get the ReactInstanceManager
      mReactNativeHost.getReactInstanceManager().addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
        @Override
        public void onReactContextInitialized(ReactContext context) {
            // The React context is fully initialized at this point
            // You can now safely access your native modules
            BundleUpdaterModule bundleUpdaterModule = context.getNativeModule(BundleUpdaterModule.class);
            if (bundleUpdaterModule != null) {
                // The BundleUpdaterModule is available
                // Use a Handler to delay the execution of the code
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        // Access the BundleUpdater module
                            try {
                                String result = bundleUpdaterModule.initialization("9980a7943e0db5892b50f6972b02b4c2a2b3");
                                Log.d("[APP SDK]", "Initialization success: " + result);
                            } catch (Exception e) {
                                Log.e("[APP SDK]", "Initialization error: ", e);
                            }
                          }
                        }, 1000); // Delay of 1 seconds
            } else {
                Log.e("[APP SDK]", "BundleUpdaterModule is null");
                // The BundleUpdaterModule is not available
            }
        }
    });

      if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
          // If you opted-in for the New Architecture, we load the native
          // entry point for this app.
          DefaultNewArchitectureEntryPoint.load();
      }
      ReactNativeFlipper.initializeFlipper(
          this,
          getReactNativeHost().getReactInstanceManager()
      );
  }
}
