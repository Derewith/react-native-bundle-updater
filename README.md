# react-native-bundle-updater

Handle your app updates

## Table of contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
  - [iOS](#ios)
- [Options](#options)
  - [Tracking [iOS]](#tracking-ios)
  - [Tracking [Android]](#tracking-android)
- [Contributing](#contributing)
- [License](#license)


## Installation

```sh
bun install react-native-bundle-updater
```

## Usage

Make some modifications to your App files on the react native side.
<!-- ```js
import something from 'react-native-bundle-updater';
``` -->
and then run:

```sh
npx react-native-bundle-updater [apiKey] [branch] [version] [-m "Bundle notes" (optional)]
```

Example:

```sh
npx react-native-bundle-updater **YourApiKey** master 1.0.0 -m "New awesome bundle"
```

## Configuration

### iOS

Add the following lines to your AppDelegate.m file

```objc
#import "AppDelegate.h"
#import "BundleUpdater.h" // <-- Add this line

....some code....

 self.initialProps = @{}; // <-- After this line

    BundleUpdater *bundleUpdater = [BundleUpdater sharedInstance];
    [bundleUpdater initialization:@"YOURKEY"
       withBranch: @"staging"
       resolve:^(NSString *result) {
        NSLog(@"[APP]Initialization success: %@", result);
       }
       reject:^(NSString *code, NSString *message, NSError *error) {
          NSLog(@"[APP]Initialization error: %@", error);
       }
    ];

.... some other code ....

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge { //  <-- Replace this method
  BundleUpdater *bundleUpdater = [BundleUpdater sharedInstance];
  return [bundleUpdater initializeBundle:bridge withKey:@"YOURKEY"];
}

```

## Options

### Tracking [iOS]

By default the tracking is disabled, you can enable it by adding the enableTracking boolean flag inside the AppDelegate.m file.
  
```objc
[BundleUpdater setEnableTracking:YES];
```

In order to inform the user about the tracking, you can add the following lines to your Info.plist file

```xml
<key>NSUserTrackingUsageDescription</key>
<string>**Your APP** requires your permission for tracking some basic information to enhance your experience </string>
```

### Tracking [Android]

// TODO

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
