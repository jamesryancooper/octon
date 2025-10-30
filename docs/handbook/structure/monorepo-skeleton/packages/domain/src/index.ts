export function hello(name: string) {
  return `hello, ${name}`;
}

// Example hexagonal port
export interface DbPort {
  getGreetingTemplate(): Promise<string>;
}
