import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Utility helper for merging class names when composing Tailwind styles.
 */
export function cn(...inputs: Array<string | null | undefined | false>): string {
  return twMerge(clsx(inputs));
}


