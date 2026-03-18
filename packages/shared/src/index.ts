/**
 * Shared utilities and types for the monorepo
 * Usage: import { formatDate, ApiResponse } from '@myorg/shared'
 */

// Example: Shared utility function
export function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

// Example: Shared type
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
}

// Example: Shared constant
export const APP_NAME = 'OpenClaw Template';
export const APP_VERSION = '1.0.0';

// Example: Shared validation
export function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
