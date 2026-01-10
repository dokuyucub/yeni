type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: string;
  context?: Record<string, unknown>;
}

const isDev = process.env.EXPO_PUBLIC_ENV === 'development';

function formatLog(entry: LogEntry): string {
  const contextStr = entry.context ? ` ${JSON.stringify(entry.context)}` : '';
  return `[${entry.timestamp}] [${entry.level.toUpperCase()}] ${entry.message}${contextStr}`;
}

function createLogEntry(
  level: LogLevel,
  message: string,
  context?: Record<string, unknown>
): LogEntry {
  return {
    level,
    message,
    timestamp: new Date().toISOString(),
    context,
  };
}

export const logger = {
  debug(message: string, context?: Record<string, unknown>) {
    if (isDev) {
      const entry = createLogEntry('debug', message, context);
      // eslint-disable-next-line no-console
      console.log(formatLog(entry));
    }
  },

  info(message: string, context?: Record<string, unknown>) {
    const entry = createLogEntry('info', message, context);
    // eslint-disable-next-line no-console
    console.log(formatLog(entry));
  },

  warn(message: string, context?: Record<string, unknown>) {
    const entry = createLogEntry('warn', message, context);
    console.warn(formatLog(entry));
  },

  error(message: string, context?: Record<string, unknown>) {
    const entry = createLogEntry('error', message, context);
    console.error(formatLog(entry));
  },
};
