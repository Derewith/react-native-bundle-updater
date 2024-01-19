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
npx react-native-bundle-updater [apiKey] [branch] [version] [-m "Bundle notes" (optional)]
```

Example:

```sh
npx react-native-bundle-updater **YourApiKey** master 1.0.0 -m "New awesome bundle"
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
