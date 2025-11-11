'use client';

import React from 'react';
import { Button } from '@harmony/ui';

export interface GetStartedButtonProps {
  href: string;
  label: string;
}

export default function GetStartedButton({ href, label }: GetStartedButtonProps): React.ReactElement {
  return (
    <Button asChild size="lg" variant="default">
      <a href={href} className="no-underline">
        {label}
      </a>
    </Button>
  );
}


