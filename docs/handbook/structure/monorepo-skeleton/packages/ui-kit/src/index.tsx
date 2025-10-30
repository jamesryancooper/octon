import * as React from 'react';

export const Button: React.FC<React.PropsWithChildren> = ({ children }) => {
  return <button style={{ padding: '8px 12px', borderRadius: 8 }}>{children}</button>;
};

export default Button;
