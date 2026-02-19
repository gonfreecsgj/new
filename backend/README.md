# Cogona Net Backend

Backend server for Cogona Net - MikroTik Voucher Management System

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Setup Environment Variables
```bash
cp .env.example .env
# Edit .env with your settings
```

### 3. Start MongoDB
Make sure MongoDB is running on your system

### 4. Run Server
```bash
# Development
npm run dev

# Production
npm start
```

## 📁 Project Structure

```
backend/
├── config/           # Configuration files
├── models/           # Database models
│   ├── Manager.js
│   ├── Voucher.js
│   ├── Reseller.js
│   └── Recharge.js
├── routes/           # API routes
│   ├── auth.js
│   ├── admin.js
│   ├── managers.js
│   ├── vouchers.js
│   ├── resellers.js
│   └── recharges.js
├── middleware/       # Express middleware
│   ├── auth.js
│   └── errorHandler.js
├── utils/            # Utility functions
│   ├── tokens.js
│   ├── logger.js
│   └── cronJobs.js
├── server.js         # Entry point
└── package.json
```

## 🔐 API Endpoints

### Authentication
- `POST /api/auth/login` - Manager login
- `POST /api/auth/register` - Manager registration
- `POST /api/auth/refresh` - Refresh token

### Admin (Requires admin token)
- `GET /api/admin/dashboard` - Dashboard stats
- `GET /api/admin/managers` - List all managers
- `GET /api/admin/managers/:id` - Get manager details
- `POST /api/admin/managers/:id/activate` - Activate subscription
- `POST /api/admin/managers/:id/suspend` - Suspend manager
- `DELETE /api/admin/managers/:id` - Delete manager
- `POST /api/admin/generate-token` - Generate activation token
- `GET /api/admin/revenue` - Revenue statistics
- `GET /api/admin/notifications` - Get notifications

### Managers
- `GET /api/managers/profile` - Get profile
- `PUT /api/managers/profile` - Update profile
- `PUT /api/managers/router` - Update router config
- `GET /api/managers/stats` - Get statistics

### Vouchers
- `GET /api/vouchers` - List vouchers
- `POST /api/vouchers` - Create vouchers
- `GET /api/vouchers/:id` - Get voucher details
- `PUT /api/vouchers/:id` - Update voucher
- `DELETE /api/vouchers/:id` - Delete voucher

### Resellers
- `GET /api/resellers` - List resellers
- `POST /api/resellers` - Create reseller
- `PUT /api/resellers/:id` - Update reseller
- `DELETE /api/resellers/:id` - Delete reseller

### Recharges
- `GET /api/recharges` - List recharges
- `POST /api/recharges` - Create recharge
- `GET /api/recharges/stats` - Recharge statistics

## 🛡️ Security

- JWT authentication
- Rate limiting (100 requests per 15 minutes)
- Helmet security headers
- CORS protection
- Input validation

## 📊 Database Models

### Manager
- Google OAuth info
- Device lock
- Subscription status
- Router configuration
- Statistics

### Voucher
- Code and password
- Profile settings
- Shelf assignment
- Usage tracking
- Recharge history

### Reseller
- Basic info
- Balance and commission
- Sales statistics
- Login PIN

### Recharge
- Voucher reference
- Reseller reference
- Financial details
- Payment method

## 📝 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Server port | 5000 |
| MONGODB_URI | MongoDB connection string | mongodb://localhost:27017/cogona_net |
| JWT_SECRET | JWT signing secret | - |
| ADMIN_EMAIL | Admin email | alshamytlal702@gmail.com |
| ALLOWED_ORIGINS | CORS allowed origins | * |

## 📞 Support

- WhatsApp: +967 734 394 867
- Email: alshamytlal702@gmail.com
