import * as React from 'react';
import { Slot } from '@radix-ui/react-slot';
import { cva, type VariantProps } from 'class-variance-authority';

import { cn } from '../lib/cn.js';

const buttonStyles = cva(
  'inline-flex items-center justify-center gap-2 font-medium transition-colors ' +
    'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 ' +
    'disabled:opacity-50 disabled:pointer-events-none',
  {
    variants: {
      variant: {
        default: 'bg-black text-white hover:bg-black/90',
        outline: 'border border-black/10 text-black hover:bg-black/5',
        ghost: 'text-black hover:bg-black/5',
        destructive: 'bg-red-600 text-white hover:bg-red-600/90'
      },
      size: {
        sm: 'h-8 rounded-[var(--radius-sm)] px-3 text-sm',
        md: 'h-9 rounded-[var(--radius-md)] px-4 text-sm',
        lg: 'h-10 rounded-[var(--radius-lg)] px-5 text-base'
      }
    },
    defaultVariants: {
      variant: 'default',
      size: 'md'
    }
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonStyles> {
  /**
   * When true, renders the button as a Radix Slot so parents can choose the
   * underlying element (e.g., `Link`).
   */
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button';
    return (
      <Comp ref={ref} className={cn(buttonStyles({ variant, size }), className)} {...props} />
    );
  }
);

Button.displayName = 'Button';

export default Button;


