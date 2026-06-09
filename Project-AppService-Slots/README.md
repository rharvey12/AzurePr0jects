# App Service with Deployment Slots

## Blue/Green Deployment Pattern
Zero-downtime production deployments using App Service slots.

## Architecture
- Production slot (live traffic)
- Staging slot (test new versions)
- Swap operation = instant promotion
- Rollback = instant swap back

## Components
- App Service Plan (Standard S1) - supports slots
- Linux Web App (Production)
- Deployment Slot (Staging)
- Application Insights for APM
- Log Analytics for centralized logs
- Full diagnostic settings

## Security
- HTTPS only enforced
- TLS 1.2 minimum
- FTP disabled
- System-assigned managed identity
- Application Insights monitoring

## NIST 800-53 Controls
- SI-7: Software Integrity (slot swap validation)
- CM-3: Change Control (staging before prod)
- AU-2: Auditable Events (diagnostic logs)

## Deployment Workflow
1. Deploy new version to staging
2. Test in staging (test traffic, smoke tests)
3. Verify monitoring + Application Insights
4. SWAP staging → production (instant!)
5. If issues: SWAP again to rollback

## Cost
- App Service Plan S1: ~$70/month
- Production + Staging = SAME plan (no extra cost!)
- Application Insights: pay-as-you-go (~$5/mo)
