# HISBA - Digital Case & Record Management System
## Kano State Hisbah Board

---

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Multi-Branch Support](#multi-branch-support)
4. [User Roles & Access Control](#user-roles--access-control)
5. [Core Features](#core-features)
6. [Technology Stack](#technology-stack)
7. [Deployment Guide](#deployment-guide)
8. [Security Considerations](#security-considerations)

---

## Overview

HISBA is a comprehensive Digital Case & Record Management System designed specifically for the Kano State Hisbah Board. The system enables efficient case registration, tracking, staff management, and organizational oversight across all 44 branches of the Hisbah Board.

### Key Capabilities

- **Centralized Case Management**: Register, track, and manage cases with full audit trails
- **Multi-Branch Architecture**: Support for 44 branches with data isolation and cross-branch visibility for administrators
- **Role-Based Access Control**: Granular permissions ensuring users only access relevant data
- **Organizational Hierarchy**: Divisions → Departments → Units → Sections structure
- **Real-time Collaboration**: Live updates and notifications across the organization
- **Comprehensive Reporting**: Branch-level and organization-wide analytics

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CENTRALIZED PRIVATE SERVER                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                     Load Balancer / Reverse Proxy          │  │
│  │                        (Nginx / Caddy)                     │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                   │
│  ┌───────────────────────────┴───────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌─────────────────┐    ┌─────────────────────────────┐  │  │
│  │  │   Frontend      │    │      Backend Services        │  │  │
│  │  │   (React SPA)   │    │  ┌───────────────────────┐  │  │  │
│  │  │                 │    │  │   PostgreSQL Database │  │  │  │
│  │  │  • Vite Build   │◄──►│  │   (Supabase/Self-    │  │  │  │
│  │  │  • Static Files │    │  │    hosted Postgres)   │  │  │  │
│  │  │                 │    │  └───────────────────────┘  │  │  │
│  │  └─────────────────┘    │                             │  │  │
│  │                         │  ┌───────────────────────┐  │  │  │
│  │                         │  │   Edge Functions      │  │  │  │
│  │                         │  │   (Deno Runtime)      │  │  │  │
│  │                         │  └───────────────────────┘  │  │  │
│  │                         │                             │  │  │
│  │                         │  ┌───────────────────────┐  │  │  │
│  │                         │  │   Auth Service        │  │  │  │
│  │                         │  │   (GoTrue / Supabase) │  │  │  │
│  │                         │  └───────────────────────┘  │  │  │
│  │                         │                             │  │  │
│  │                         │  ┌───────────────────────┐  │  │  │
│  │                         │  │   File Storage        │  │  │  │
│  │                         │  │   (S3-compatible)     │  │  │  │
│  │                         │  └───────────────────────┘  │  │  │
│  │                         └─────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │Branch 1 │          │Branch 2 │   ...    │Branch 44│
   │ Users   │          │ Users   │          │ Users   │
   └─────────┘          └─────────┘          └─────────┘
```

### Data Flow

1. **All 44 branches** connect to the **single centralized server**
2. **Row-Level Security (RLS)** ensures data isolation between branches
3. **Super Admins** have cross-branch visibility and management capabilities
4. **Branch Admins** manage their specific branch with full local access
5. **Real-time subscriptions** enable instant updates across all connected clients

---

## Multi-Branch Support

### Branch Structure

The system supports the 44 branches of the Kano State Hisbah Board. Each branch operates as an isolated environment while remaining connected to the central system.

```
Hisbah Board (Central)
├── Branch: Kano Metropolitan
├── Branch: Fagge
├── Branch: Dala
├── Branch: Gwale
├── Branch: Kumbotso
├── Branch: Ungogo
├── Branch: Tarauni
├── Branch: Nassarawa
└── ... (44 total branches)
```

### Branch Data Isolation

| Entity | Branch Scoping |
|--------|----------------|
| Cases | Automatically assigned to registering officer's branch |
| Staff | Linked to specific branch |
| Defendants | Associated with case (inherits branch) |
| Departments | Can be branch-specific or organization-wide |
| Users | Assigned to single branch (except Super Admins) |

### Case Numbering Convention

Cases are numbered with branch identification:
```
HC-XXXX-YYYY-NNNN
│   │    │    │
│   │    │    └── Sequential number
│   │    └─────── Year
│   └──────────── First 4 letters of branch name
└──────────────── Hisbah Case prefix
```

Example: `HC-KANO-2026-0001` (First case in Kano Metropolitan, 2026)

---

## User Roles & Access Control

### Role Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                       SUPER ADMIN                           │
│  • Full system access across all 44 branches                │
│  • Manage branches, users, and organization structure       │
│  • Cross-branch case transfers and reporting                │
│  • System configuration and settings                        │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────┴─────────────────────────────┐
│                      BRANCH ADMIN                          │
│  • Full access within assigned branch                      │
│  • Manage local staff and cases                            │
│  • Branch-level reporting and analytics                    │
│  • Cannot access other branches                            │
└────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────┴─────────────────────────────┐
│                       COMMANDER                            │
│  • Department-level oversight                              │
│  • Case assignment and workflow management                 │
│  • Staff supervision within department                     │
└────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────┴─────────────────────────────┐
│                        OFFICER                             │
│  • Case registration and management                        │
│  • Defendant processing                                    │
│  • Day-to-day operational tasks                            │
└────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────┴─────────────────────────────┐
│                         CLERK                              │
│  • Read-only access to cases                               │
│  • Data entry and record keeping                           │
│  • Administrative support tasks                            │
└────────────────────────────────────────────────────────────┘
```

### Access Matrix

| Feature | Super Admin | Branch Admin | Commander | Officer | Clerk |
|---------|-------------|--------------|-----------|---------|-------|
| View All Branches | ✅ | ❌ | ❌ | ❌ | ❌ |
| Manage Branches | ✅ | ❌ | ❌ | ❌ | ❌ |
| Create Users | ✅ | ✅ | ❌ | ❌ | ❌ |
| Reset Passwords | ✅ | ✅ | ❌ | ❌ | ❌ |
| Transfer Cases | ✅ | ❌ | ❌ | ❌ | ❌ |
| Register Cases | ✅ | ✅ | ✅ | ✅ | ❌ |
| Close Cases | ✅ | ✅ | ✅ | ❌ | ❌ |
| View Reports | ✅ | ✅ | ✅ | ❌ | ❌ |
| Manage Staff | ✅ | ✅ | ✅ | ❌ | ❌ |

---

## Core Features

### 1. Case Management

- **Registration**: Quick case entry with auto-generated case numbers
- **Workflow**: Pending → Active → Under Review → Closed
- **Participants**: Multiple officers can be assigned to cases
- **Defendants**: Link individuals to cases with full profile tracking
- **Steps/Timeline**: Track case progression with dated entries
- **Attachments**: Support for photos, documents, and evidence

### 2. Staff Management

- **Profiles**: Complete officer profiles with badge numbers
- **Hierarchy Assignment**: Link staff to Division/Department/Unit/Section
- **Branch Assignment**: Automatic scoping to assigned branch
- **Role Management**: Assign and modify user roles

### 3. Organization Structure

```
Division (Top Level)
└── Department
    └── Unit
        └── Section (Bottom Level)
```

- Flexible hierarchy supporting various organizational structures
- Each level can have multiple children
- Staff can be assigned at any level

### 4. Reporting & Analytics

- **Dashboard**: Real-time statistics and KPIs
- **Case Reports**: Filtered by date, status, branch
- **Staff Reports**: Performance and caseload metrics
- **Export**: Data export capabilities for external analysis

### 5. Notifications

- In-app notification system
- Case assignment alerts
- Workflow status changes
- System announcements

---

## Technology Stack

### Current Stack (Production)

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | React 18 | UI Framework |
| | TypeScript | Type Safety |
| | Vite | Build Tool & Dev Server |
| | Tailwind CSS | Styling |
| | shadcn/ui | Component Library |
| | React Router | Client-side Routing |
| | TanStack Query | Server State Management |
| | React Hook Form | Form Handling |
| | Zod | Schema Validation |
| **Backend** | Supabase | Backend-as-a-Service |
| | PostgreSQL | Database |
| | Deno (Edge Functions) | Serverless Functions |
| | GoTrue | Authentication |
| | Row-Level Security | Data Access Control |
| **Infrastructure** | Self-hosted or Cloud Provider | Hosting & Deployment |

### Self-Hosting Stack (Recommended)

For private server deployment:

| Component | Recommended Technology |
|-----------|----------------------|
| **Reverse Proxy** | Nginx or Caddy |
| **SSL/TLS** | Let's Encrypt (Certbot) |
| **Database** | PostgreSQL 15+ |
| **Auth** | Supabase Self-hosted or Keycloak |
| **Functions** | Deno Deploy or Docker containers |
| **Storage** | MinIO (S3-compatible) |
| **Monitoring** | Prometheus + Grafana |
| **Backups** | pg_dump + automated scripts |

### Future Considerations

| Feature | Technology Options |
|---------|-------------------|
| Mobile App | React Native / Flutter |
| Offline Support | PWA with Service Workers |
| Biometrics | Fingerprint.js / WebAuthn |
| Document OCR | Tesseract.js / Google Vision |
| SMS Notifications | Twilio / Africa's Talking |

---

## Deployment Guide

### Option 2: Self-Hosted Private Server

#### Prerequisites

- Ubuntu 22.04 LTS or similar
- 4GB RAM minimum (8GB recommended)
- 50GB storage (SSD recommended)
- Domain name with DNS access
- SSL certificate

#### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y nginx postgresql-15 certbot python3-certbot-nginx

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Deno (for edge functions)
curl -fsSL https://deno.land/install.sh | sh
```

#### Step 2: Database Setup

```bash
# Create database and user
sudo -u postgres psql
CREATE DATABASE hisba_db;
CREATE USER hisba_user WITH ENCRYPTED PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE hisba_db TO hisba_user;
\q

# Apply migrations
psql -U hisba_user -d hisba_db -f supabase/migrations/*.sql
```

#### Step 3: Build Frontend

```bash
# Clone repository
git clone <repository-url>
cd hisba-system

# Install dependencies
npm install

# Build for production (with subfolder)
npm run build

# Output will be in ./dist folder
```

#### Step 4: Nginx Configuration

Create `/etc/nginx/sites-available/hisba`:

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Subfolder deployment
    location /hisba-demo {
        alias /var/www/hisba/dist;
        try_files $uri $uri/ /hisba-demo/index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # API proxy (if self-hosting Supabase)
    location /api {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/hisba /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### Step 5: SSL Certificate

```bash
sudo certbot --nginx -d yourdomain.com
```

#### Step 6: Environment Configuration

Create `.env.production`:

```env
VITE_SUPABASE_URL=https://yourdomain.com/api
VITE_SUPABASE_PUBLISHABLE_KEY=your_anon_key
VITE_SUPABASE_PROJECT_ID=hisba
```

### Subfolder Configuration

The application is configured to run at `/hisba-demo`. This is set in `vite.config.ts`:

```typescript
export default defineConfig({
  base: '/hisba-demo/',
  // ... other config
})
```

Access the application at: `https://yourdomain.com/hisba-demo`

---

## Security Considerations

### Authentication

- **Password Policy**: Minimum 6 characters (recommend increasing to 12+)
- **Session Management**: Automatic token refresh
- **Password Reset**: Admin-controlled via secure edge functions

### Data Protection

- **Row-Level Security (RLS)**: All tables protected with branch-scoped policies
- **Role Verification**: Server-side role checks in edge functions
- **Input Validation**: Client and server-side validation
- **SQL Injection Prevention**: Parameterized queries via Supabase client

### Recommendations for Production

1. **Enable 2FA** for all admin accounts
2. **Regular backups** (daily automated + weekly offsite)
3. **Audit logging** for sensitive operations
4. **VPN access** for administrative functions
5. **Regular security updates** for all dependencies
6. **Penetration testing** before public deployment

### Compliance Notes

- Store minimum necessary personal data
- Implement data retention policies
- Provide data export capabilities for individuals
- Document all data processing activities

---

## Support & Maintenance

### Regular Maintenance Tasks

| Task | Frequency |
|------|-----------|
| Database backups | Daily |
| Security updates | Weekly |
| Log rotation | Weekly |
| Performance monitoring | Continuous |
| Dependency updates | Monthly |

### Monitoring Checklist

- [ ] Database connection pool usage
- [ ] API response times
- [ ] Error rates and types
- [ ] Storage utilization
- [ ] User session counts
- [ ] Failed login attempts

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01 | Initial release with multi-branch support |

---

*Document Last Updated: January 2026*
*Kano State Hisbah Board - Digital Case & Record Management System*
