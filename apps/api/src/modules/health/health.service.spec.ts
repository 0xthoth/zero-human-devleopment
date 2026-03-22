import { Test, TestingModule } from '@nestjs/testing';
import { HealthService } from './health.service';

describe('HealthService', () => {
  let service: HealthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [HealthService],
    }).compile();

    service = module.get<HealthService>(HealthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getHealth', () => {
    it('should return health status with all required fields', () => {
      const health = service.getHealth();

      expect(health).toHaveProperty('status');
      expect(health).toHaveProperty('uptime');
      expect(health).toHaveProperty('timestamp');
      expect(health).toHaveProperty('version');
    });

    it('should return status "ok"', () => {
      const health = service.getHealth();

      expect(health.status).toBe('ok');
    });

    it('should return uptime as a number', () => {
      const health = service.getHealth();

      expect(typeof health.uptime).toBe('number');
      expect(health.uptime).toBeGreaterThanOrEqual(0);
    });

    it('should return timestamp as ISO string', () => {
      const health = service.getHealth();

      expect(health.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/,
      );
      expect(() => new Date(health.timestamp)).not.toThrow();
    });

    it('should return version as string', () => {
      const health = service.getHealth();

      expect(typeof health.version).toBe('string');
      expect(health.version).toBeTruthy();
    });

    it('should increment uptime on subsequent calls', async () => {
      const health1 = service.getHealth();

      // Wait a bit
      await new Promise((resolve) => setTimeout(resolve, 1100));

      const health2 = service.getHealth();

      expect(health2.uptime).toBeGreaterThan(health1.uptime);
    });
  });
});
