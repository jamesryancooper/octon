import { render, screen } from '@testing-library/react';

import Button from './button.js';

describe('Button component', () => {
  it('renders provided children text', () => {
    render(<Button>Submit</Button>);
    expect(screen.getByRole('button', { name: 'Submit' })).toBeInTheDocument();
  });

  it('applies variant and size classes', () => {
    render(
      <Button variant="outline" size="sm">
        Filter
      </Button>
    );

    const button = screen.getByRole('button', { name: 'Filter' });
    expect(button.className).toContain('border');
    expect(button.className).toContain('h-8');
  });
});

