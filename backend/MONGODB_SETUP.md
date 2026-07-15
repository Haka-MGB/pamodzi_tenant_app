# MongoDB Setup Guide for Windows

## Option 1: Install MongoDB Community Edition (Local)

### Step 1: Download MongoDB
1. Go to: https://www.mongodb.com/try/download/community
2. Select:
   - Version: Latest (7.0 or higher)
   - Platform: Windows
   - Package: MSI
3. Click "Download"

### Step 2: Install MongoDB
1. Run the downloaded `.msi` file
2. Choose "Complete" installation
3. **IMPORTANT:** Check "Install MongoDB as a Service"
4. Leave default settings:
   - Service Name: MongoDB
   - Data Directory: C:\Program Files\MongoDB\Server\7.0\data
   - Log Directory: C:\Program Files\MongoDB\Server\7.0\log

### Step 3: Verify Installation
Open PowerShell or CMD and run:
```cmd
mongod --version
```

You should see version information.

### Step 4: Start MongoDB Service
MongoDB should start automatically as a service. If not:

**Option A - Using Services:**
1. Press `Win + R`
2. Type `services.msc` and press Enter
3. Find "MongoDB" in the list
4. Right-click → Start

**Option B - Using Command Prompt (as Administrator):**
```cmd
net start MongoDB
```

### Step 5: Verify MongoDB is Running
```cmd
mongosh
```

Or use the old client:
```cmd
mongo
```

You should see a connection message. Type `exit` to quit.

### Step 6: Update Your .env File
Your `.env` file should have:
```
MONGODB_URI=mongodb://localhost:27017/pamodzi_tenant_app
```

---

## Option 2: Use MongoDB Atlas (Cloud - Free Tier)

### Step 1: Create Account
1. Go to: https://www.mongodb.com/cloud/atlas/register
2. Sign up for free account

### Step 2: Create Cluster
1. Choose "M0 Free" tier
2. Select region closest to you
3. Click "Create Cluster"
4. Wait 3-5 minutes for cluster to deploy

### Step 3: Create Database User
1. Click "Database Access" in left sidebar
2. Click "Add New Database User"
3. Choose "Password" authentication
4. Username: `pamodzi_user`
5. Password: Create a strong password (save it!)
6. Set privileges to "Read and write to any database"
7. Click "Add User"

### Step 4: Whitelist Your IP
1. Click "Network Access" in left sidebar
2. Click "Add IP Address"
3. Click "Allow Access from Anywhere" (for development)
   - Or enter your specific IP
4. Click "Confirm"

### Step 5: Get Connection String
1. Click "Database" in left sidebar
2. Click "Connect" on your cluster
3. Choose "Connect your application"
4. Copy the connection string (looks like):
   ```
   mongodb+srv://pamodzi_user:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

### Step 6: Update Your .env File
Replace `<password>` with your actual password:
```
MONGODB_URI=mongodb+srv://pamodzi_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/pamodzi_tenant_app?retryWrites=true&w=majority
```

---

## Quick Test Commands

After MongoDB is running, test your connection:

### Start Backend Server
```cmd
cd C:\Users\hakam\Desktop\pamodzi_tenant_app\backend
npm run dev
```

You should see:
```
✅ MongoDB connected successfully
🚀 Server running on port 3000
```

### Seed Database with Test Data
```cmd
npm run seed
```

This will create:
- Test tenant (chanda.m@pamodzi.com / rent2026)
- Test landlord
- Sample property
- Payment history
- Maintenance issues
- Notifications

---

## Troubleshooting

### "MongoDB service won't start"
1. Check if port 27017 is in use:
   ```cmd
   netstat -ano | findstr :27017
   ```
2. If in use, stop the process or change MongoDB port

### "Can't connect to MongoDB Atlas"
1. Check your IP is whitelisted
2. Verify username and password
3. Check connection string format
4. Ensure password doesn't contain special characters that need URL encoding

### "Authentication failed"
Make sure the password in connection string is URL encoded:
- `@` becomes `%40`
- `#` becomes `%23`
- etc.

---

## Recommendation for Your Setup

**For Development:** Use MongoDB Community Edition (Option 1)
- Faster (local)
- No internet required
- Full control
- Free

**For Production:** Use MongoDB Atlas (Option 2)
- Managed service
- Automatic backups
- Scaling
- Security

---

## Next Steps After MongoDB is Running

1. ✅ Verify backend connects: `npm run dev`
2. ✅ Seed database: `npm run seed`
3. ✅ Test API: Open http://localhost:3000/health in browser
4. ✅ Update Flutter app to point to backend
5. ✅ Test login from Flutter app

