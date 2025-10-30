import type { DbPort } from '@coe/domain';

export class InMemoryDb implements DbPort {
  async getGreetingTemplate(): Promise<string> {
    return "hello, %s";
  }
}
