import {
  shakeEventEmitter,
  startShakeDetection,
  stopShakeDetection,
} from '@yk-yong/react-native-shake';
import { useEffect, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';

export default function App() {
  const [deviceShaken, setDeviceShaken] = useState(false);

  useEffect(() => {
    try {
      startShakeDetection();
      console.log('SHAKE DETECTION STARTED');
    } catch (error) {
      console.error('Error starting shake detection:', error);
    }

    const subscription = shakeEventEmitter.addListener('ShakeEvent', () => {
      setDeviceShaken(true);
      console.log('Device shaken!');
    });

    return () => {
      subscription.remove();
      stopShakeDetection();
    };
  }, []);

  return (
    <View style={styles.container}>
      {deviceShaken && <Text>Device was shaken!</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
});
