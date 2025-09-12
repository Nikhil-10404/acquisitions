# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Server Development
- `npm run dev` - Start development server with file watching (uses Node.js --watch)
- `npm start` - Standard start (runs `src/index.js`)

### Code Quality
- `npm run lint` - Run ESLint to check code style and errors
- `npm run lint:fix` - Auto-fix ESLint issues where possible
- `npm run format` - Format all files with Prettier
- `npm run format:check` - Check if files are properly formatted

### Database Operations
- `npm run db:generate` - Generate Drizzle migration files from schema changes
- `npm run db:migrate` - Apply pending migrations to the database
- `npm run db:studio` - Launch Drizzle Studio for database inspection

## Architecture Overview

### Technology Stack
- **Runtime**: Node.js with ES modules (`"type": "module"`)
- **Framework**: Express.js with security middleware (Helmet, CORS)
- **Database**: PostgreSQL via Neon serverless with Drizzle ORM
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: Zod schemas for request validation
- **Logging**: Winston with structured JSON logging
- **Development**: ESLint + Prettier for code quality

### Project Structure
The codebase follows a modular MVC-like architecture with import path aliases:

- **Entry Point**: `src/index.js` → `src/server.js` → `src/app.js`
- **Path Aliases**: Uses Node.js imports map (`#src/*`, `#config/*`, etc.)
- **Models**: Drizzle schema definitions in `src/models/`
- **Routes**: Express route definitions in `src/routes/`
- **Controllers**: Request handling logic in `src/controllers/`
- **Services**: Business logic layer in `src/services/`
- **Utils**: Shared utilities (JWT, cookies, formatting) in `src/utils/`
- **Validations**: Zod schemas in `src/validations/`
- **Config**: Database connection and logger setup in `src/config/`

### Database Architecture
- **ORM**: Drizzle ORM with PostgreSQL dialect
- **Connection**: Neon serverless PostgreSQL
- **Migrations**: Stored in `drizzle/` directory
- **Schema**: Currently has `users` table with role-based access
- **Configuration**: `drizzle.config.js` points to `src/models/*.js` for schema discovery

### Authentication Flow
- JWT-based authentication with secure HTTP-only cookies
- Password hashing with bcrypt
- Role-based user system (default: 'user')
- Routes: `/api/auth/sign-up`, `/api/auth/sign-in`, `/api/auth/sign-out`
- Validation using Zod schemas for consistent error handling

### Logging Strategy
- Winston logger with different transports:
  - Console output in development (colorized)
  - File logging: `logs/combined.log` and `logs/error.lg`
  - Structured JSON format for production
  - HTTP request logging via Morgan middleware

### Key Configuration Files
- **ESLint**: Uses flat config with strict rules (2-space indentation, single quotes, Unix line endings)
- **Environment**: Development setup with Neon PostgreSQL connection
- **Drizzle Config**: Schema auto-discovery from models directory

## Development Notes

### Environment Variables
- `DATABASE_URL`: PostgreSQL connection string (currently Neon)
- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment mode
- `LOG_LEVEL`: Logging verbosity (default: 'info')

### Code Style Conventions
- ES modules with import/export syntax
- 2-space indentation, single quotes, semicolons required
- Path aliases using Node.js imports map for cleaner imports
- Async/await for asynchronous operations
- Structured error handling with Winston logging

### Database Workflow
1. Modify schema in `src/models/`
2. Run `npm run db:generate` to create migration
3. Run `npm run db:migrate` to apply changes
4. Use `npm run db:studio` to inspect database state

### Testing Strategy
- ESLint config includes testing globals (describe, it, expect, etc.)
- No current test runner configured - consider adding Jest or Vitest