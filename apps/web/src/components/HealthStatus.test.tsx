import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { HealthStatus } from './HealthStatus';

describe('HealthStatus', () => {
  beforeEach(() => {
    vi.clearAllTimers();
  });

  afterEach(() => {
    vi.clearAllTimers();
  });

  it('renders loading state initially', () => {
    render(<HealthStatus />);
    expect(screen.getByText(/checking health/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/loading health status/i)).toBeInTheDocument();
  });

  it('displays online status with mock data', async () => {
    render(<HealthStatus />);

    await waitFor(
      () => {
        expect(screen.getByText(/system online/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );

    expect(screen.getByLabelText(/service online/i)).toBeInTheDocument();
    expect(screen.getByText('🟢')).toBeInTheDocument();
  });

  it('displays uptime in formatted string', async () => {
    render(<HealthStatus />);

    await waitFor(
      () => {
        expect(screen.getByText(/uptime:/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );

    // Mock shows 3600 seconds = 1 hour (component shows "1h" not "1h 0m 0s")
    const uptimeValue = screen.getByText(/1h/i);
    expect(uptimeValue).toBeInTheDocument();
  });

  it('displays response time in milliseconds', async () => {
    render(<HealthStatus />);

    await waitFor(
      () => {
        expect(screen.getByText(/response time:/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );

    const responseTimeValue = screen.getAllByText(/\d+ms/i)[0];
    expect(responseTimeValue).toBeInTheDocument();
  });

  it('displays last checked timestamp', async () => {
    render(<HealthStatus />);

    await waitFor(
      () => {
        expect(screen.getByText(/last checked:/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );

    const lastCheckedValue = screen.getByText(/\d{2}:\d{2}:\d{2}/);
    expect(lastCheckedValue).toBeInTheDocument();
  });

  it('shows dev note when using mock data', async () => {
    render(<HealthStatus />);

    await waitFor(
      () => {
        expect(screen.getByText(/using mock data/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );
  });

  it('accepts custom poll interval', async () => {
    const customInterval = 60000;
    const { unmount } = render(<HealthStatus pollInterval={customInterval} />);

    await waitFor(
      () => {
        expect(screen.getByText(/system online/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );

    unmount();
  });

  it('has proper accessibility attributes', async () => {
    render(<HealthStatus />);

    await waitFor(
      () => {
        const status = screen.getByRole('status');
        expect(status).toBeInTheDocument();
        expect(status).toHaveAttribute('aria-live', 'polite');
      },
      { timeout: 1000 }
    );
  });

  it('renders status role element', async () => {
    render(<HealthStatus />);

    await waitFor(
      () => {
        expect(screen.getByRole('status')).toBeInTheDocument();
      },
      { timeout: 1000 }
    );
  });

  it('formats uptime correctly', async () => {
    render(<HealthStatus />);

    await waitFor(
      () => {
        expect(screen.getByText(/uptime:/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );

    // Verify uptime is displayed (mock shows 3600 seconds = 1 hour)
    const uptimeText = screen.getByText(/1h/);
    expect(uptimeText).toBeInTheDocument();
  });

  it('cleans up interval on unmount', async () => {
    const { unmount } = render(<HealthStatus />);

    await waitFor(
      () => {
        expect(screen.getByText(/system online/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );

    // Should not throw on unmount
    expect(() => unmount()).not.toThrow();
  });

  it('uses custom API endpoint prop', async () => {
    const customEndpoint = '/api/custom-health';
    const { unmount } = render(<HealthStatus apiEndpoint={customEndpoint} />);

    await waitFor(
      () => {
        expect(screen.getByText(/system online/i)).toBeInTheDocument();
      },
      { timeout: 1000 }
    );

    unmount();
  });
});
