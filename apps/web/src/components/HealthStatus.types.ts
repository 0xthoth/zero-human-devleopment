export interface HealthData {
  status: 'online' | 'offline';
  uptime: number;
  responseTime: number;
  timestamp: string;
}

export interface HealthStatusProps {
  apiEndpoint?: string;
  pollInterval?: number;
}
