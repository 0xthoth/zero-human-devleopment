import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';

describe('Health API (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  describe('GET /api/health', () => {
    it('should return 200 OK', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200);
    });

    it('should return health data with correct shape', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('status');
          expect(res.body).toHaveProperty('uptime');
          expect(res.body).toHaveProperty('timestamp');
          expect(res.body).toHaveProperty('version');
        });
    });

    it('should return status "ok"', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200)
        .expect((res) => {
          expect(res.body.status).toBe('ok');
        });
    });

    it('should return uptime as number', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200)
        .expect((res) => {
          expect(typeof res.body.uptime).toBe('number');
          expect(res.body.uptime).toBeGreaterThanOrEqual(0);
        });
    });

    it('should return timestamp as ISO string', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200)
        .expect((res) => {
          expect(res.body.timestamp).toMatch(
            /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/,
          );
          const date = new Date(res.body.timestamp);
          expect(date.toString()).not.toBe('Invalid Date');
        });
    });

    it('should return version as string', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200)
        .expect((res) => {
          expect(typeof res.body.version).toBe('string');
          expect(res.body.version).toBeTruthy();
        });
    });

    it('should return Content-Type application/json', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200)
        .expect('Content-Type', /json/);
    });

    it('should have uptime increase on subsequent calls', async () => {
      const res1 = await request(app.getHttpServer())
        .get('/api/health')
        .expect(200);

      await new Promise((resolve) => setTimeout(resolve, 1100));

      const res2 = await request(app.getHttpServer())
        .get('/api/health')
        .expect(200);

      expect(res2.body.uptime).toBeGreaterThan(res1.body.uptime);
    });

    it('should return different timestamps on subsequent calls', async () => {
      const res1 = await request(app.getHttpServer())
        .get('/api/health')
        .expect(200);

      await new Promise((resolve) => setTimeout(resolve, 100));

      const res2 = await request(app.getHttpServer())
        .get('/api/health')
        .expect(200);

      expect(res2.body.timestamp).not.toBe(res1.body.timestamp);
    });
  });
});
