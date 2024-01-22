# react-native-bundle-updater

Handle your app updates

## Installation

```sh
bun install react-native-bundle-updater
```

## Usage

```js
import something from 'react-native-bundle-updater';
```

```sh
npx react-native bundle --entry-file index.js --platform ios --dev false --bundle-output ios/main.jsbundle --assets-dest ios --minify true

npx react-native bundle --entry-file index.js --platform android --dev false --bundle-output android/main.jsbundle --assets-dest android --minify true

bun upload ./example/ios/main.jsbundle 9980a7943e0db5892b50f6972b02b4c2a2b3
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

See LICENSE file.

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
