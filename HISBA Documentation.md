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

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01 | Initial release with multi-branch support |

---

*Document Last Updated: January 2026*
*Kano State Hisbah Board - Digital Case & Record Management System*

