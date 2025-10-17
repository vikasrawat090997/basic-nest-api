import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello Sir, this is your first NestJS API!';
  }
}
