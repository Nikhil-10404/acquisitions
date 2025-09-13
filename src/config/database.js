import 'dotenv/config';

import { neon, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';

// Configure Neon serverless driver based on environment
if (process.env.NODE_ENV === 'development' && process.env.USE_LOCAL_DB === 'true') {
  // For development with Neon Local (Docker)
  neonConfig.fetchEndpoint = 'http://neon-local:5432/sql';
  neonConfig.useSecureWebSocket = false;
  neonConfig.poolQueryViaFetch = true;
} else {
  // For production with Neon Cloud OR local dev without Docker
  // Use default configuration (HTTPS, secure WebSocket)
  neonConfig.useSecureWebSocket = true;
  neonConfig.poolQueryViaFetch = true;
}

const sql = neon(process.env.DATABASE_URL);

const db = drizzle(sql);

export { db, sql };
