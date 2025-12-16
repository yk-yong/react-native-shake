import {
  shakeEventEmitter,
  startShakeDetection,
  stopShakeDetection,
} from '@yk-yong/react-native-shake';
import { useEffect } from 'react';
import { Alert, StyleSheet, View } from 'react-native';

export default function App() {
  useEffect(() => {
    startShakeDetection();

    shakeEventEmitter.addListener('ShakeEvent', () => {
      Alert.alert('Shake detection started.', 'Device was shaken!');
      console.log('Device shaken!');
    });

    return () => {
      stopShakeDetection();
    };
  }, []);

  return <View style={styles.container} />;
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
});
