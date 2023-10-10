import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { loadApp } from '../../src';

export default function App() {
  React.useEffect(() => {
    async function startApp() {
      await loadApp('9980a7943e0db5892b50f6972b02b4c2a2b3');
      console.log('loaded app');
    }
    startApp();
  }, []);
  return (
    <View style={styles.container}>
      <Text>Result KPACACA</Text>
    </View>
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
