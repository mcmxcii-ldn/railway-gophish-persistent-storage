# Gophish Railway - Persistent Storage

One-click deploy [Gophish](https://getgophish.com) phishing simulation platform to Railway with persistent data storage.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/railway-gophish-persistent-storage?referralCode=T0Htsi&utm_medium=integration&utm_source=template&utm_campaign=generic)


## Features

- ✅ **Persistent Storage** - Campaign data, users, and templates survive redeployments
- ✅ **Automatic Configuration** - Railway domain configured automatically for CSRF protection
- ✅ **Latest Gophish** - Always uses the latest official Gophish Docker image
- ✅ **Secure by Default** - Random admin password generated on first start
- ✅ **No Hardcoded Values** - Works on any Railway domain

## Quick Deploy

### 1. Deploy to Railway

Click the **"Deploy on Railway"** button above and wait for initial deployment to complete.

✅ Volume is automatically configured at `/opt/gophish/data`

### 2. Configure Networking

**Setup TWO ports:**

1. **Public Domain for Campaigns** (Port 80):
   - Settings > Networking > Generate Domain
   - **Enter port: `80`**
   - Click Generate
   - You get: `https://your-app.up.railway.app`
   - ✅ Use this URL in your phishing campaigns

2. **TCP Proxy for Admin** (Port 3333):
   - Settings > Networking > Add TCP Proxy
   - Click the `:3333` box that appears
   - You get: `lion.proxy.rlwy.net:12345`
   - ✅ Use this to access admin interface at `http://lion.proxy.rlwy.net:12345`

**Important:**
- Campaign URLs: Use `https://your-app.up.railway.app/` (HTTPS, port 80)
- Admin login: Use `http://lion.proxy.rlwy.net:12345` (HTTP, TCP proxy)

### 3. First Redeploy

After generating the domain, trigger a redeploy:

1. Go to **Settings** > Service settings area
2. Find the redeploy option or trigger by editing a variable
3. Wait for deployment to complete

### 4. Second Redeploy (Required!)

**Important:** Railway sometimes needs a second redeploy to fully apply the domain configuration:

1. Go to **Deployments** tab
2. **Right-click** on the latest deployment
3. Click **Redeploy**
4. Wait for deployment to complete

### 5. Get Admin Password

Check deployment logs for your admin credentials:
```
=================================
FIRST START - NEW DATABASE
Admin credentials will appear in next logs
Username: admin
=================================
Please login with the username admin and the password [RANDOM_PASSWORD]
```

⚠️ **Important Notes:**
- Password appears in logs **after the second redeploy**
- If you see "EXISTING DATABASE" instead, delete volume and redeploy
- **Save this password immediately!** It only appears once

### 6. Login and Secure Your Account

1. Open **admin interface** at your TCP proxy address (e.g., `http://lion.proxy.rlwy.net:12345`)
2. Login with `admin` and the password from logs
3. Go to **Settings** > **Account Settings**
4. **Change your password immediately**

### 7. Data is Now Persistent

After successful login and password change:
- All subsequent redeployments will preserve your data
- Logs will show: `EXISTING DATABASE DETECTED`
- Use your changed password (not the one from logs)

---

## Environment Variables

**Automatically set by Railway:**
- `RAILWAY_PUBLIC_DOMAIN` - Your service domain (set when you generate domain)

**Optional variables you can set:**
- `CONTACT_EMAIL` - Contact email shown in Gophish config (default: empty)

---

## SMTP Configuration

To send phishing simulation emails, configure an SMTP profile:

1. Login to Gophish
2. Go to **Sending Profiles** > **New Profile**
3. Example for Gmail/Google Workspace:
```
   From: security@yourdomain.com
   Host: smtp.gmail.com:465
   Username: security@yourdomain.com
   Password: [App Password from Google]
```
4. Click **Send Test Email** to verify
5. Save profile

**Best practices:**
- Use dedicated emails like `security@` or `training@` (avoid `phishing@`)
- Generate App Password (not regular password) for Gmail/Workspace
- Whitelist Railway IP in email provider settings
- Test thoroughly before running campaigns

---

## Data Persistence

### What's Stored

The volume at `/opt/gophish/data` persists:
- User accounts and passwords
- Campaigns and results
- Email templates and landing pages
- SMTP profiles and target lists

### Subsequent Deployments

After initial setup (steps 1-7), all redeployments will show:
```
EXISTING DATABASE DETECTED
Use your saved admin credentials
```

All data remains intact across deployments.

### Password Recovery

If you lose your admin password:

1. Go to **Settings** > **Volumes**
2. Delete the existing volume
3. Click **Add Volume** with mount path `/opt/gophish/data`
4. Follow steps 3-6 again (two redeployments + get new password)

⚠️ **Warning:** This deletes all campaign data!

---

## Troubleshooting

### "Forbidden - referer invalid" Error After First Login Attempt

This is normal! Railway needs the second redeploy to fully configure CSRF protection.

**Solution:**
1. Go to **Deployments** tab
2. Right-click latest deployment > **Redeploy**
3. Get the **new password** from logs (it may have changed)
4. Login with new password at TCP proxy address

### Verify Domain Configuration

Check deployment logs for:
```
DEBUG: Railway Environment
RAILWAY_PUBLIC_DOMAIN=your-service.up.railway.app
=================================
Configuring trusted origin: your-service.up.railway.app
```

**If missing:**
1. Settings > Variables > Add `RAILWAY_PUBLIC_DOMAIN`
2. Value: `your-domain.up.railway.app` (NO https://)
3. Redeploy twice (as in steps 3-4)

### No Password in Logs

If you see `EXISTING DATABASE DETECTED` but don't have the password:
- Volume already has old database
- Delete volume in Settings > Volumes
- Redeploy twice to get fresh password

### SMTP Emails Not Sending

1. Verify App Password (not regular password)
2. Check outbound connections allowed on ports 465/587
3. Use "Send Test Email" in Sending Profile
4. Check email provider security settings

### Campaign Links Not Working

1. Ensure Railway domain (port 80) is accessible
2. Phishing server runs on port 80 (Railway handles HTTPS)
3. Verify campaign template URLs use your Railway domain from Step 2.1

---

## Why Two Redeployments?

Railway sometimes caches environment variables. The second redeploy ensures:
- `RAILWAY_PUBLIC_DOMAIN` is properly set
- CSRF `trusted_origins` configuration is applied
- Fresh database is created with correct settings

This is a **one-time setup requirement**. After initial configuration, single redeployments work normally.

---

## Ports

- **80** - Phishing server (generate Railway domain on this port for campaigns)
- **3333** - Admin interface (accessible via TCP proxy)

---

## Security Best Practices

1. **Change default password** immediately after first login
2. **Use strong passwords** for admin account
3. **Whitelist Railway IPs** in email provider
4. **Monitor campaigns** regularly for abuse
5. **Inform employees** before running phishing simulations
6. **Document consent** for phishing training programs

---

## Architecture

This deployment:
- Uses official `gophish/gophish:latest` Docker image
- Runs as root user (required for binding ports 80/3333)
- Configures `trusted_origins` dynamically from `RAILWAY_PUBLIC_DOMAIN`
- Stores SQLite database in persistent Railway volume
- Handles CSRF protection automatically
- Separates admin interface (TCP proxy) from phishing campaigns (public domain)

---

## Support

- [Gophish Documentation](https://getgophish.com/documentation)
- [Railway Documentation](https://docs.railway.app)
- [GitHub Issues](https://github.com/mcmxcii-ldn/railway-gophish-persistent-storage/issues)

## License

This repository contains deployment configuration only. Gophish itself is licensed under [MIT License](https://github.com/gophish/gophish/blob/master/LICENSE).

## Contributing

Pull requests welcome! Please test thoroughly on Railway before submitting.

---

**Made with ☕ for secure phishing training deployments**
