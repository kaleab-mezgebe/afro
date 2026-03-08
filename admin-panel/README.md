# AFRO Admin Panel

Web-based admin panel for managing customers, providers, appointments, and system analytics.

## Features

### User Management
- ✅ View all users (customers, providers, admins)
- ✅ Assign/remove roles
- ✅ Suspend/activate accounts
- ✅ View user details and activity

### Provider Management
- ✅ Approve/reject provider registrations
- ✅ Verify provider documents
- ✅ Manage provider shops
- ✅ View provider analytics
- ✅ Handle provider disputes

### Customer Management
- ✅ View customer profiles
- ✅ View booking history
- ✅ Handle customer complaints
- ✅ Manage customer reviews

### Appointment Management
- ✅ View all appointments
- ✅ Monitor appointment status
- ✅ Handle disputes
- ✅ Generate reports

### Analytics & Reports
- ✅ System-wide statistics
- ✅ Revenue analytics
- ✅ User growth metrics
- ✅ Appointment trends
- ✅ Provider performance

### Content Moderation
- ✅ Review flagged content
- ✅ Moderate reviews
- ✅ Manage reported users
- ✅ Audit logs

## Tech Stack

- **Framework**: Next.js 14 (React)
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **Charts**: Recharts
- **HTTP Client**: Axios
- **Authentication**: Firebase Admin
- **Backend**: NestJS API (http://localhost:3001)

## Quick Start

### 1. Install Dependencies

```bash
cd admin-panel
npm install
```

### 2. Configure Environment

Create `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_auth_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
```

### 3. Start Development Server

```bash
npm run dev
```

Admin panel runs on: http://localhost:3002

### 4. Login

Use admin credentials:
- Email: admin@afro.com
- Password: (set in Firebase)

## Project Structure

```
admin-panel/
├── src/
│   ├── app/                    # Next.js app directory
│   │   ├── dashboard/          # Dashboard pages
│   │   ├── users/              # User management
│   │   ├── providers/          # Provider management
│   │   ├── customers/          # Customer management
│   │   ├── appointments/       # Appointment management
│   │   ├── analytics/          # Analytics & reports
│   │   ├── settings/           # System settings
│   │   └── layout.tsx          # Root layout
│   ├── components/             # Reusable components
│   │   ├── layout/             # Layout components
│   │   ├── ui/                 # UI components
│   │   └── charts/             # Chart components
│   ├── lib/                    # Utilities
│   │   ├── api.ts              # API client
│   │   ├── auth.ts             # Auth utilities
│   │   └── utils.ts            # Helper functions
│   └── store/                  # State management
│       ├── authStore.ts        # Auth state
│       └── uiStore.ts          # UI state
├── public/                     # Static assets
└── package.json
```

## Features in Detail

### Dashboard
- System overview
- Key metrics (users, appointments, revenue)
- Recent activity
- Quick actions

### User Management
- List all users with filters
- Search by name, email, role
- View user details
- Assign/remove roles
- Suspend/activate accounts
- View activity logs

### Provider Management
- Pending approvals
- Approved providers
- Rejected providers
- Provider verification
- Shop management
- Performance metrics

### Customer Management
- Customer list
- Profile details
- Booking history
- Review history
- Complaint management

### Appointment Management
- All appointments
- Filter by status, date, provider
- Appointment details
- Dispute resolution
- Cancellation management

### Analytics
- User growth charts
- Revenue trends
- Appointment statistics
- Provider performance
- Customer satisfaction
- Geographic distribution

### Settings
- System configuration
- Email templates
- Notification settings
- Payment settings
- Security settings

## API Integration

All API calls go through the backend at `http://localhost:3001/api/v1`

### Admin Endpoints

```typescript
// Users
GET    /admin/users              // List all users
GET    /admin/users/:id          // Get user details
POST   /admin/users/:id/suspend  // Suspend user
POST   /admin/users/:id/activate // Activate user
POST   /auth/assign-role         // Assign role
POST   /auth/remove-role         // Remove role

// Providers
GET    /admin/providers          // List providers
GET    /admin/providers/:id      // Provider details
POST   /admin/providers/:id/approve   // Approve provider
POST   /admin/providers/:id/reject    // Reject provider

// Analytics
GET    /admin/analytics          // System analytics
GET    /admin/analytics/revenue  // Revenue analytics
GET    /admin/analytics/users    // User analytics

// Audit Logs
GET    /admin/audit-logs         // Activity logs
```

## Security

### Authentication
- Firebase Authentication required
- Admin role verification
- JWT token validation

### Authorization
- Role-based access control (RBAC)
- Admin-only routes
- Action permissions

### Data Protection
- Sensitive data masking
- Audit logging
- Secure API calls

## Development

### Adding New Pages

```typescript
// src/app/new-feature/page.tsx
export default function NewFeaturePage() {
  return (
    <div>
      <h1>New Feature</h1>
    </div>
  );
}
```

### Adding API Calls

```typescript
// src/lib/api.ts
export const api = {
  getUsers: () => axios.get('/admin/users'),
  suspendUser: (id: string) => axios.post(`/admin/users/${id}/suspend`),
};
```

### Adding Components

```typescript
// src/components/ui/Button.tsx
export function Button({ children, onClick }) {
  return (
    <button onClick={onClick} className="btn">
      {children}
    </button>
  );
}
```

## Deployment

### Build for Production

```bash
npm run build
npm start
```

### Deploy to Vercel

```bash
vercel deploy
```

### Deploy to Other Platforms

- **Netlify**: Connect GitHub repo
- **AWS**: Use Amplify or EC2
- **DigitalOcean**: Use App Platform
- **Self-hosted**: Use PM2 or Docker

## Environment Variables

```env
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1

# Firebase Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_auth_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_storage_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id

# Optional
NEXT_PUBLIC_ENVIRONMENT=development
```

## Troubleshooting

### API Connection Issues
- Check backend is running on port 3001
- Verify API URL in `.env.local`
- Check CORS settings in backend

### Authentication Issues
- Verify Firebase configuration
- Check admin role is assigned
- Clear browser cache and cookies

### Build Issues
- Delete `.next` folder
- Run `npm install` again
- Check Node.js version (18+)

## Support

For issues or questions:
- Check backend logs
- Review API documentation: http://localhost:3001/api/docs
- Check Firebase console for auth issues

---

**Status**: ✅ Ready for Development
**Port**: 3002
**Backend**: http://localhost:3001
**Docs**: http://localhost:3001/api/docs
