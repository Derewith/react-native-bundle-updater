# react-native-bundle-updater

Handle your app updates

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
bun upload:dev folderOfJSBundle assetsGeneratedFolder  apiKey
```

Example:

```sh
bun upload:dev ./example/ios/main.jsbundle ./example/ios/assets  31ad196f026d0b07b7dffe9019f708955c13
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
