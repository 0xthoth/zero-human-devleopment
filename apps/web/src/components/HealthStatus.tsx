import { useCallback, useEffect, useState } from 'react';
import type { HealthData, HealthStatusProps } from './HealthStatus.types';
import './HealthStatus.css';

// TODO: Replace mock with real API when backend #7 is ready
const MOCK_API_RESPONSE: HealthData = {
  status: 'online',
  uptime: 3600,
  responseTime: 42,
  timestamp: new Date().toISOString(),
};

const MOCK_API_ENABLED = true; // Set to false when backend is ready

export function HealthStatus({
  apiEndpoint = '/api/health',
  pollInterval = 30000,
}: HealthStatusProps) {
  const [healthData, setHealthData] = useState<HealthData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastChecked, setLastChecked] = useState<Date | null>(null);

  const fetchHealth = useCallback(async () => {
    try {
      const startTime = performance.now();

      // Mock mode for development (backend not ready)
      if (MOCK_API_ENABLED) {
        await new Promise((resolve) => setTimeout(resolve, 100)); // Simulate network delay
        const endTime = performance.now();
        const mockData: HealthData = {
          ...MOCK_API_RESPONSE,
          responseTime: Math.round(endTime - startTime),
          timestamp: new Date().toISOString(),
        };
        setHealthData(mockData);
        setError(null);
        setLastChecked(new Date());
        return;
      }

      // Real API call (when backend is ready)
      const response = await fetch(apiEndpoint);
      const endTime = performance.now();

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data: HealthData = await response.json();
      setHealthData({
        ...data,
        responseTime: Math.round(endTime - startTime),
      });
      setError(null);
      setLastChecked(new Date());
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
      setHealthData({
        status: 'offline',
        uptime: 0,
        responseTime: 0,
        timestamp: new Date().toISOString(),
      });
      setLastChecked(new Date());
    } finally {
      setIsLoading(false);
    }
  }, [apiEndpoint]);

  useEffect(() => {
    fetchHealth();

    const intervalId = setInterval(fetchHealth, pollInterval);

    return () => clearInterval(intervalId);
  }, [fetchHealth, pollInterval]);

  const formatUptime = (seconds: number): string => {
    if (seconds === 0) return '0s';

    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    const parts: string[] = [];
    if (hours > 0) parts.push(`${hours}h`);
    if (minutes > 0) parts.push(`${minutes}m`);
    if (secs > 0 || parts.length === 0) parts.push(`${secs}s`);

    return parts.join(' ');
  };

  const formatTimestamp = (date: Date): string => {
    return date.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    });
  };

  if (isLoading) {
    return (
      <div className="health-status health-status--loading" role="status">
        <span className="health-status__spinner" aria-label="Loading health status" />
        <span>Checking health...</span>
      </div>
    );
  }

  const isOnline = healthData?.status === 'online' && !error;

  return (
    <div
      className={`health-status health-status--${isOnline ? 'online' : 'offline'}`}
      role="status"
      aria-live="polite"
    >
      <div className="health-status__header">
        <span
          className={`health-status__indicator health-status__indicator--${isOnline ? 'online' : 'offline'}`}
          aria-label={isOnline ? 'Service online' : 'Service offline'}
        >
          {isOnline ? '🟢' : '🔴'}
        </span>
        <h2 className="health-status__title">
          {isOnline ? 'System Online' : 'System Offline'}
        </h2>
      </div>

      {error && (
        <div className="health-status__error" role="alert">
          Error: {error}
        </div>
      )}

      <div className="health-status__metrics">
        <div className="health-status__metric">
          <span className="health-status__metric-label">Uptime:</span>
          <span className="health-status__metric-value">
            {healthData ? formatUptime(healthData.uptime) : 'N/A'}
          </span>
        </div>

        <div className="health-status__metric">
          <span className="health-status__metric-label">Response Time:</span>
          <span className="health-status__metric-value">
            {healthData ? `${healthData.responseTime}ms` : 'N/A'}
          </span>
        </div>

        <div className="health-status__metric">
          <span className="health-status__metric-label">Last Checked:</span>
          <span className="health-status__metric-value">
            {lastChecked ? formatTimestamp(lastChecked) : 'N/A'}
          </span>
        </div>
      </div>

      {MOCK_API_ENABLED && (
        <div className="health-status__dev-note" role="note">
          ⚠️ Using mock data (backend not ready)
        </div>
      )}
    </div>
  );
}
