import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';

describe('HealthController', () => {
  let controller: HealthController;
  let service: HealthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [HealthService],
    }).compile();

    controller = module.get<HealthController>(HealthController);
    service = module.get<HealthService>(HealthService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('GET /api/health', () => {
    it('should return health status from service', () => {
      const mockHealth = {
        status: 'ok',
        uptime: 123,
        timestamp: '2026-03-22T15:30:00.000Z',
        version: '0.0.1',
      };

      const getHealthSpy = jest
        .spyOn(service, 'getHealth')
        .mockReturnValue(mockHealth);

      const result = controller.getHealth();

      expect(result).toEqual(mockHealth);
      expect(getHealthSpy).toHaveBeenCalled();
    });

    it('should return proper structure', () => {
      const result = controller.getHealth();

      expect(result).toHaveProperty('status');
      expect(result).toHaveProperty('uptime');
      expect(result).toHaveProperty('timestamp');
      expect(result).toHaveProperty('version');
      expect(typeof result.status).toBe('string');
      expect(typeof result.uptime).toBe('number');
      expect(typeof result.timestamp).toBe('string');
      expect(typeof result.version).toBe('string');
    });
  });
});
