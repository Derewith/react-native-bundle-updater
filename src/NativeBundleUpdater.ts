import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  checkAndReplaceBundle: (apiKey: string) => Promise<boolean>; // TODO - remove apiKey
  reload: () => Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('BundleUpdater');
