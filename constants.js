module.exports = {
  REACT_NATIVE_BUNDLE_COMMAND:
    'npx react-native bundle --entry-file index.js --platform ios --dev false --bundle-output ios/main.jsbundle --assets-dest ios --minify true',
  BUNDLE_UPDATER_CLI_COMMAND:
    'node ./node_modules/react-native-bundle-updater/local-cli/cli.js',
};
