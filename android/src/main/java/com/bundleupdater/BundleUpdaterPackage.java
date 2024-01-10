package com.bundleupdater;

import androidx.annotation.Nullable;
import com.facebook.react.ReactPackage;
import com.facebook.react.TurboReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.model.ReactModuleInfo;
import com.facebook.react.module.model.ReactModuleInfoProvider;
import com.facebook.react.uimanager.ViewManager;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BundleUpdaterPackage extends TurboReactPackage {

  @Nullable
  @Override
  public NativeModule getModule(
    String name,
    ReactApplicationContext reactContext
  ) {
    if (name.equals(BundleUpdaterModule.NAME)) {
      return new BundleUpdaterModule(reactContext);
    } else {
      return null;
    }
  }

  @Override
  public ReactModuleInfoProvider getReactModuleInfoProvider() {
    return () -> {
      final Map<String, ReactModuleInfo> moduleInfos = new HashMap<>();
      boolean isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
      moduleInfos.put(
        BundleUpdaterModule.NAME,
        new ReactModuleInfo(
          BundleUpdaterModule.NAME,
          BundleUpdaterModule.NAME,
          false, // canOverrideExistingModule
          false, // needsEagerInit
          true, // hasConstants
          false, // isCxxModule
          isTurboModule // isTurboModule
        )
      );
      return moduleInfos;
    };
  }
}
// public class BundleUpdaterPackage implements ReactPackage {
//   @Override
//   public List<NativeModule> createNativeModules(
//     ReactApplicationContext reactContext
//   ) {
//     List<NativeModule> modules = new ArrayList<>();
//     modules.add(BundleUpdaterModule.getInstance(reactContext));
//     return modules;
//   }
//   @Override
//   public List<ViewManager> createViewManagers(
//     ReactApplicationContext reactContext
//   ) {
//     return Collections.emptyList();
//   }
// }
