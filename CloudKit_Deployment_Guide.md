# CloudKit Production Deployment Guide for Taal Trek

## Current Issue
Your CloudKit schema needs to be deployed to production. This is a **one-time setup** required for any new CloudKit container.

## Quick Fix Steps

### 1. Open CloudKit Console
- Go to: [https://icloud.developer.apple.com/dashboard](https://icloud.developer.apple.com/dashboard)
- Sign in with your Apple Developer account

### 2. Select Your Container
- Choose your team/organization
- Select container: **iCloud.Dutch.FlashCard**

### 3. Switch to Development Environment
- In the top dropdown, make sure **Development** is selected
- You should see your record types: FlashCard and Deck

### 4. Deploy Schema to Production
- Click the **"Deploy Schema Changes"** button (usually in the top right)
- Review the changes that will be deployed:
  - FlashCard record type with all fields
  - Deck record type with all fields
  - Indexes for both record types
- Click **"Deploy"** to confirm

### 5. Verify Production Deployment
- Switch to **Production** environment
- Verify that FlashCard and Deck record types are present
- Check that all fields match your development schema

### 6. Re-enable CloudKit Sync
- Open your Taal Trek app
- Go to Settings
- Enable "iCloud Sync"
- The app should now sync successfully

## What This Fixes

- **Schema not found errors**: Production environment will have the required record types
- **"Cannot create new type" errors**: Production schema will match your app's expectations
- **Sync failures**: Your app can now read/write to CloudKit production database

## After Deployment

Your CloudKit sync should work properly. You can:
- ✅ Add new flash cards that sync across devices
- ✅ Study sessions sync progress
- ✅ Deck organization syncs
- ✅ Offline changes sync when back online

## Troubleshooting

If you still have issues after deployment:

1. **Check iCloud Settings**
   - Make sure you're signed into iCloud
   - Verify iCloud Drive is enabled

2. **Test CloudKit Status**
   - In Taal Trek Settings, tap "Test CloudKit Quota"
   - Check the console logs for any errors

3. **Reset and Retry**
   - If sync still fails, try:
   - Disable CloudKit sync
   - Wait 30 seconds
   - Re-enable CloudKit sync

## Technical Details

- **Container**: iCloud.Dutch.FlashCard
- **Record Types**: FlashCard, Deck
- **Database**: Private (user's personal data only)
- **Environments**: Development → Production deployment

## Future Schema Changes

- Development changes are automatic
- Production changes require deployment
- You can add new fields anytime
- Cannot delete fields from production (by design)

---

**Need Help?** Check the console logs when testing CloudKit - they'll show specific error messages to help debug any remaining issues. 