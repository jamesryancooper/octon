import { listFlags } from '@harmony/config';

export function getFlagSnapshot(): Readonly<Record<string, boolean>> {
  return listFlags();
}


