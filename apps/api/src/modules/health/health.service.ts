import { Injectable } from '@nestjs/common';

export interface HealthResponse {
  status: string;
  uptime: number;
  timestamp: string;
  version: string;
}

@Injectable()
export class HealthService {
  private readonly startTime: number;
  private readonly version: string;

  constructor() {
    this.startTime = Date.now();
    // Get version from package.json or use default
    this.version = process.env.npm_package_version || '0.0.1';
  }

  getHealth(): HealthResponse {
    return {
      status: 'ok',
      uptime: Math.floor((Date.now() - this.startTime) / 1000),
      timestamp: new Date().toISOString(),
      version: this.version,
    };
  }
}
