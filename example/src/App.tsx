/* eslint-disable */ 
import * as React from 'react';
import { StyleSheet, Text, ImageBackground } from 'react-native';
import { checkAndReplaceBundle } from '../../src';

export default function App() {
  React.useEffect(() => {
    async function startApp() {
      await checkAndReplaceBundle('9980a7943e0db5892b50f6972b02b4c2a2b3');
      console.log('loaded app');
    }
    startApp();
  }, []);
  return (
    <ImageBackground
      style={styles.container}
      source={require('../example.png')}
      imageStyle={{
        resizeMode: 'contain',
        width: '100%',
        height: '100%',
        opacity: 0,
      }}
    >
      <Text>ciao alessio come stai?</Text>
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
