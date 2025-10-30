import { describe, it, expect } from 'vitest';
import { hello } from '../index';

describe('domain', () => {
  it('says hello', () => {
    expect(hello('test')).toBe('hello, test');
  });
});
