'use client';

import React from 'react';
import { Button } from '@harmony/ui';

export interface DocCtaProps {
  href: string;
  label: string;
  variant?: 'default' | 'outline' | 'ghost';
}

/**
 * React island used within Starlight pages to demonstrate ui consumption.
 * Each island owns its own state; avoid sharing React context across islands.
 */
export default function DocCta({ href, label, variant = 'default' }: DocCtaProps): React.ReactElement {
  return (
    <Button asChild size="md" variant={variant} className="w-full justify-center sm:w-auto">
      <a href={href} className="no-underline">
        {label}
      </a>
    </Button>
  );
}


