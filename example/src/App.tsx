/* eslint-disable */
import * as React from 'react';
import { StyleSheet, Button, Text, ImageBackground } from 'react-native';
// import { restart } from 'react-native-bundle-updater';
import { restart, initialization } from '../../src';

export default function App() {
  React.useEffect(() => {
    initialization('9980a7943e0db5892b50f6972b02b4c2a2b3')
      .then(() => console.log('Initialization successful'))
      .catch((error) => console.error('Initialization failed', error));
  }, []);
  const handleReload = async () => {
    try {
      await restart();
    } catch (error) {
      console.log('[handleReload]:', error);
    }
  };

  return (
    <ImageBackground
      style={styles.container}
      source={require('../example.png')}
      imageStyle={{
        resizeMode: 'contain',
        width: '100%',
        height: '100%',
        opacity: 1,
      }}
    >
      <Button title="Reload" onPress={handleReload} />
      <Text>W LA FIGA 2025</Text>
    </ImageBackground>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
