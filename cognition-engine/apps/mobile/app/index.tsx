/**
 * Root index - redirects based on auth state.
 * The actual redirect logic is in _layout.tsx.
 */

import { Loading } from '@/components';

export default function Index() {
  // This screen shows briefly while auth state is being determined
  // The _layout.tsx will redirect to the appropriate screen
  return <Loading fullScreen message="Loading..." />;
}
