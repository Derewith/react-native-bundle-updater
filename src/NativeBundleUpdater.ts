import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  checkAndReplaceBundle: (apiKey: string) => Promise<boolean>; // TODO - remove apiKey
  initialization: (apiKey: string) => Promise<void>;
  restart: () => Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('BundleUpdater');
