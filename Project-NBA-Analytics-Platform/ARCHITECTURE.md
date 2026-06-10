# NBA Analytics Platform Architecture

## Vision
Production-grade NBA analytics platform demonstrating enterprise Azure patterns. Foundation for AI Security Architect career path.

## Architecture Layers

### 1. Identity & Access
- Dynamic Groups (HR-driven auto-membership)
- PIM (Just-in-time admin elevation)
- Sentinel (Privileged activity monitoring)

### 2. Network (Hub-Spoke)
- Hub VNet: Shared services (Bastion, monitoring)
- Web Spoke: Public-facing app
- Data Spoke: Private storage/databases
- Analytics Spoke: Container workloads

### 3. Data Strategy
- Hot tier: Current season (daily access)
- Cool tier: Last season (monthly)
- Archive tier: Historical 2000-2024 (yearly)
- Cosmos DB: Real-time player/team data
- Key Vault: Secrets management

### 4. Application Layer
- App Service: Web frontend + staging slots
- Container Apps: Microservices (scale to zero)
- ACR Premium: Signed images

### 5. Integration
- Service Bus: Event-driven async
- Function Apps: Data ingestion
- Logic Apps: Workflow automation

### 6. Monitoring
- Application Insights: APM
- Log Analytics: Centralized logs
- Sentinel: Security monitoring

## NIST 800-53 Mapping

| Control | Implementation |
|---------|---------------|
| AC-2 | Dynamic groups |
| AC-3 | Group-based RBAC |
| AC-6 | PIM least privilege |
| AU-2 | Diagnostic logging |
| AU-11 | 7-year retention |
| CM-2 | IaC baseline |
| SC-7 | Network segmentation |
| SC-28 | Encryption at rest |
| SI-4 | Sentinel monitoring |
| SI-7 | Signed images |

## Cost Profile

| Component | Strategy | Monthly Cost |
|-----------|----------|--------------|
| App Service S1 | Slots free | $70 |
| Container Apps | Scale to zero | $0-50 |
| Storage Lifecycle | Auto-tier | $20 |
| Cosmos DB Serverless | Pay per request | $25 |
| Function App | Consumption | $5 |
| **Total** | Production estimate | **~$170** |

## Career Application
Demonstrates:
- Modern enterprise architecture
- NIST-aligned security
- Cost-conscious engineering
- DevSecOps integration
- $250-400K Architect role-ready
