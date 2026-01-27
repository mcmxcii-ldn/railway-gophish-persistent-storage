# Gophish Railway - Persistent Storage

One-click deploy [Gophish](https://getgophish.com) phishing simulation platform to Railway with persistent data storage.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/YOUR_TEMPLATE_ID)

## Features

- ✅ **Persistent Storage** - Campaign data, users, and templates survive redeployments
- ✅ **Automatic Configuration** - Railway domain configured automatically for CSRF protection
- ✅ **Latest Gophish** - Always uses the latest official Gophish Docker image
- ✅ **Secure by Default** - Random admin password generated on first start
- ✅ **No Hardcoded Values** - Works on any Railway domain

## Quick Deploy

### 1. Deploy to Railway

Click the "Deploy on Railway" button above or:
1. Fork this repository
2. Create new project in Railway from your fork
3. Wait for initial build to complete

### 2. Add Persistent Volume

**Important:** Add volume before first use to enable data persistence.

1. Go to your Railway service
2. Click **Settings** > **Volumes**
3. Click **Add Volume**
4. Set mount path: `/opt/gophish/data`
5. Click **Add**

### 3. Generate Public Domain

1. Go to **Settings** > **Networking**
2. Click **Generate Domain**
3. Enter port: `3333`
4. Click **Generate**

### 4. Redeploy

After adding the volume, trigger a redeploy:
1. Go to **Deployments** tab
2. Click **Redeploy** on latest deployment

### 5. Get Admin Credentials

Check the deployment logs for your admin password:
```
=================================
FIRST START - NEW DATABASE
Admin credentials will appear in next logs
Username: admin
=================================
Please login with the username admin and the password [RANDOM_PASSWORD]
```

⚠️ **Save this password immediately!** It only appears on first deployment.

### 6. Login and Change Password

1. Open your Railway domain (e.g., `https://your-service.up.railway.app`)
2. Login with `admin` and the password from logs
3. Go to **Settings** > **Account Settings**
4. Change your password to something secure

## Environment Variables

Railway automatically provides:
- `RAILWAY_PUBLIC_DOMAIN` - Used for CSRF protection (automatically configured)

Optional variables you can set:
- `CONTACT_EMAIL` - Contact email shown in Gophish config (default: empty)

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

**Best practices for SMTP:**
- Use a dedicated email like `security@` or `training@` (avoid `phishing@`)
- Generate an App Password (not your regular password)
- Whitelist your Railway IP in email provider settings
- Test thoroughly before running campaigns

## Data Persistence

### What's Stored

The volume at `/opt/gophish/data` persists:
- User accounts and passwords
- Campaigns and results
- Email templates
- Landing pages
- SMTP profiles
- Target lists

### Subsequent Deployments

After the initial setup, redeployments will show:
```
=================================
EXISTING DATABASE DETECTED
Use your saved admin credentials
=================================
```

Your data remains intact across deployments.

### Password Recovery

If you lose your admin password:
1. Delete the volume in Railway Settings
2. Create a new volume at `/opt/gophish/data`
3. Redeploy to generate a fresh database
4. Get new password from logs

⚠️ **Warning:** This deletes all campaign data!

## Ports

- **3333** - Admin interface (generate Railway domain on this port)
- **80** - Phishing server (used in campaigns for landing pages)

## Troubleshooting

### "Forbidden - referer invalid" Error

This means CSRF protection is blocking the login. Check:
1. Logs show `Configured trusted_origins: [your-domain]`
2. Domain matches exactly (no https:// prefix)
3. Clear browser cache and retry

### Can't See Password in Logs

Volume already has an existing database from a previous deployment. Either:
- Use your saved password from first deployment
- Delete volume and redeploy for fresh start

### SMTP Emails Not Sending

1. Verify App Password (not regular password)
2. Check firewall allows outbound connections on ports 465/587
3. Test with "Send Test Email" in Sending Profile
4. Check email provider's security settings

### Campaign Links Not Working

1. Ensure Railway domain is accessible
2. Phishing server runs on port 80 (Railway handles HTTPS)
3. Check campaign template URLs use your Railway domain

## Security Best Practices

1. **Change default password** immediately after first login
2. **Use strong passwords** for admin account
3. **Whitelist Railway IPs** in your email provider
4. **Monitor campaigns** regularly for abuse
5. **Inform employees** before running phishing simulations
6. **Document consent** for phishing training programs

## Architecture

This deployment:
- Uses official `gophish/gophish:latest` Docker image
- Runs as root user (required for ports 80/3333)
- Configures trusted_origins dynamically from Railway domain
- Stores SQLite database in persistent volume
- Handles CSRF protection automatically

## Support

- [Gophish Documentation](https://docs.getgophish.com)
- [Railway Documentation](https://docs.railway.app)
- [GitHub Issues](https://github.com/YOUR_USERNAME/gophish-railway-persistent/issues)

## License

This repository contains deployment configuration only. Gophish itself is licensed under [MIT License](https://github.com/gophish/gophish/blob/master/LICENSE).

## Contributing

Pull requests welcome! Please test thoroughly on Railway before submitting.

---

Made with ☕ for secure phishing training deployments
