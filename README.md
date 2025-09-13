# Acquisitions API

A modern Node.js REST API built with Express.js, Drizzle ORM, and PostgreSQL via Neon Database. This application provides user authentication and management functionality with Docker support for both development and production environments.

## 🏗️ Architecture

- **Framework**: Express.js with TypeScript-like import aliases
- **Database**: PostgreSQL via Neon Database (Cloud) with Neon Local for development
- **ORM**: Drizzle ORM with automatic migrations
- **Authentication**: JWT with secure HTTP-only cookies + bcrypt password hashing
- **Validation**: Zod schemas for request validation
- **Logging**: Winston with structured JSON logging
- **Security**: Helmet, CORS, rate limiting ready

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Node.js 20+ (for local development)
- Neon Database account ([Sign up here](https://console.neon.tech))

## 🔧 Development Setup (with Neon Local)

### 1. Clone and Setup

```bash
git clone https://github.com/Nikhil-10404/acquisitions.git
cd acquisitions
```

### 2. Configure Neon API Keys

Get your Neon credentials from [Neon Console](https://console.neon.tech):

1. **API Key**: Go to Account Settings → API Keys → Create new key
2. **Project ID**: Go to your project → Settings → General
3. **Parent Branch ID**: Go to Branches tab → copy your main branch ID

### 3. Setup Development Environment

Copy the development environment template:

```bash
cp .env.development .env.development.local
```

Edit `.env.development.local` with your actual Neon credentials:

```bash
# Development Environment Configuration
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# Neon Local Database Configuration (for development)
DATABASE_URL=postgres://neon:npg@neon-local:5432/neondb?sslmode=require

# Neon API Configuration (required for Neon Local)
NEON_API_KEY=your_actual_neon_api_key_here
NEON_PROJECT_ID=your_actual_neon_project_id_here

# Use PARENT_BRANCH_ID for ephemeral branches (recommended for development)
PARENT_BRANCH_ID=br-your-actual-main-branch-id-here

# JWT Configuration
JWT_SECRET=development-secret-key-change-in-production
```

### 4. Start Development Environment

```bash
# Start with Neon Local proxy + your app
docker-compose --env-file .env.development.local -f docker-compose.dev.yml up --build

# Or with database admin tool
docker-compose --env-file .env.development.local -f docker-compose.dev.yml --profile tools up --build
```

This will start:
- **Neon Local proxy** on port 5432 (creates ephemeral database branches)
- **Your application** on port 3000
- **Adminer** (database admin) on port 8080 (if using --profile tools)

### 5. Run Database Migrations

```bash
# In a new terminal, run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Or if you prefer to run locally
npm run db:migrate
```

### 6. Test the API

```bash
# Health check
curl http://localhost:3000/health

# Sign up a new user
curl -X POST http://localhost:3000/api/auth/sign-up \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com", 
    "password": "password123"
  }'

# Sign in
curl -X POST http://localhost:3000/api/auth/sign-in \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

## 🌐 Production Deployment

### 1. Setup Production Environment

Create your production environment file:

```bash
cp .env.production .env.production.local
```

Edit `.env.production.local` with your production Neon database:

```bash
# Production Environment Configuration
NODE_ENV=production
PORT=3000
LOG_LEVEL=info

# Neon Cloud Database Configuration (for production)
DATABASE_URL=postgresql://neondb_owner:your_password@your-endpoint.neon.tech/neondb?sslmode=require

# JWT Configuration - USE A STRONG RANDOM SECRET!
JWT_SECRET=your-super-secure-jwt-secret-generated-randomly

# Application Configuration
APP_NAME=Acquisitions API
APP_VERSION=1.0.0
```

### 2. Deploy to Production

```bash
# Build and start production environment
docker-compose --env-file .env.production.local -f docker-compose.prod.yml up --build -d

# Run migrations in production
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate

# Check logs
docker-compose -f docker-compose.prod.yml logs -f app
```

### 3. Optional: Deploy with Nginx Reverse Proxy

```bash
# Start with nginx reverse proxy
docker-compose --env-file .env.production.local -f docker-compose.prod.yml --profile nginx up -d
```

## 📊 Database Management

### Development (Neon Local)

```bash
# Generate new migration after schema changes
npm run db:generate

# Apply migrations
npm run db:migrate

# Open Drizzle Studio (database browser)
npm run db:studio

# Or use Adminer web interface
# Visit http://localhost:8080 (when running with --profile tools)
# Server: neon-local, Username: neon, Password: npg, Database: neondb
```

### Production (Neon Cloud)

```bash
# Generate migrations (same commands)
npm run db:generate
npm run db:migrate

# Or run inside container
docker-compose -f docker-compose.prod.yml exec app npm run db:generate
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

## 🛠️ Development Workflow

### Hot Reload Development

For development with hot reload:

```bash
# Option 1: Docker with volume mounting (files sync automatically)
docker-compose --env-file .env.development.local -f docker-compose.dev.yml up

# Option 2: Run locally while using Neon Local for database
docker-compose --env-file .env.development.local -f docker-compose.dev.yml up neon-local
npm run dev
```

### Code Quality

```bash
# Lint code
npm run lint
npm run lint:fix

# Format code  
npm run format
npm run format:check
```

## 🌍 Environment Switching

The application automatically configures itself based on `NODE_ENV`:

### Development Mode (`NODE_ENV=development`)
- Connects to Neon Local proxy at `neon-local:5432`
- Uses HTTP for Neon serverless driver
- Debug logging enabled
- Creates ephemeral database branches

### Production Mode (`NODE_ENV=production`)
- Connects directly to Neon Cloud
- Uses HTTPS for Neon serverless driver
- Info-level logging
- Optimized for performance and security

## 🔒 Security Considerations

### Development
- Uses default JWT secret (acceptable for development)
- Ephemeral database branches (data is deleted when containers stop)
- Debug logging (may expose sensitive information)

### Production
- **Required**: Strong, randomly generated JWT secret
- **Required**: Secure DATABASE_URL connection string
- **Recommended**: Enable HTTPS/TLS termination
- **Recommended**: Set up monitoring and alerting

## 📋 API Endpoints

### Authentication
- `POST /api/auth/sign-up` - Register new user
- `POST /api/auth/sign-in` - Sign in user  
- `POST /api/auth/sign-out` - Sign out user

### System
- `GET /health` - Health check endpoint
- `GET /api` - API status

## 🚨 Troubleshooting

### Common Issues

**"User with this email already exists"**
```bash
# Check if user exists in database
docker-compose -f docker-compose.dev.yml exec neon-local psql -U neon -d neondb -c "SELECT * FROM users;"
```

**Database connection issues**
```bash
# Check if Neon Local is running
docker-compose -f docker-compose.dev.yml ps neon-local

# Check Neon Local logs
docker-compose -f docker-compose.dev.yml logs neon-local

# Verify environment variables
docker-compose -f docker-compose.dev.yml exec app env | grep -E "(DATABASE_URL|NEON_)"
```

**Migration issues**
```bash
# Reset migrations (development only!)
rm -rf drizzle/
npm run db:generate
npm run db:migrate
```

### Docker Issues

```bash
# Clean rebuild
docker-compose -f docker-compose.dev.yml down --volumes
docker-compose -f docker-compose.dev.yml up --build

# View all logs
docker-compose -f docker-compose.dev.yml logs -f

# Exec into container
docker-compose -f docker-compose.dev.yml exec app sh
```

## 📚 Additional Resources

- [Neon Database Documentation](https://neon.com/docs)
- [Neon Local Documentation](https://neon.com/docs/local/neon-local)  
- [Drizzle ORM Documentation](https://orm.drizzle.team)
- [Express.js Documentation](https://expressjs.com)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and linting (`npm run lint`, `npm run format`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.