import type { Meta, StoryObj } from '@storybook/react';

import Button, { type ButtonProps } from './button.js';

const meta: Meta<ButtonProps> = {
  title: 'Components/Button',
  component: Button,
  args: { children: 'Click me' }
};

export default meta;
type Story = StoryObj<ButtonProps>;

export const Default: Story = {};

export const Outline: Story = {
  args: {
    variant: 'outline'
  }
};

export const Ghost: Story = {
  args: {
    variant: 'ghost'
  }
};

export const Destructive: Story = {
  args: {
    variant: 'destructive'
  }
};


