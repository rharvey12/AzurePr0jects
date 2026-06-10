# NBA Analytics Platform - Foundation

## Overview
Capstone integration project tying together all enterprise Azure patterns. Foundation for the full NBA Analytics Platform.

## What This Project Demonstrates

### Architecture Patterns
- Multi-resource group separation (platform/data/monitoring)
- Hub-Spoke VNet topology
- Centralized Log Analytics + Sentinel
- RBAC-based Key Vault
- VNet peering for hybrid connectivity

### Security Posture
- Private network access only
- Purge protection on Key Vault
- 90-day soft delete
- Service endpoints for data tier
- Default-deny network ACLs

### Integration With Other Projects
- Dynamic Groups → consume from this Key Vault
- App Service Slots → deploy to hub's shared services
- Container Apps → use data VNet for backend
- Storage Lifecycle → uses central Log Analytics
- PIM-Sentinel → uses central workspace

## Components Deployed
1. 3 Resource Groups (platform/data/monitoring)
2. Central Log Analytics Workspace (90-day retention)
3. Microsoft Sentinel onboarded
4. Key Vault with RBAC + purge protection
5. Hub VNet (10.0.0.0/16) with Bastion subnet
6. Data VNet (10.1.0.0/16) with service endpoints
7. VNet peering between hub and data

## NIST 800-53 Controls
- AC-3: Access Enforcement (RBAC)
- AU-2: Auditable Events (centralized logs)
- CM-2: Baseline Configuration (IaC)
- SC-7: Boundary Protection (VNet segmentation)
- SC-28: Encryption at Rest (Key Vault)
- SI-4: System Monitoring (Sentinel)

## How To Explain This In An Interview

"This is the foundation layer of an NBA analytics platform.
I separated concerns into three resource groups - platform 
for shared services, data for storage tier, monitoring for 
observability. The hub-spoke topology gives me central 
control while isolating sensitive data. Key Vault with 
RBAC and purge protection ensures secrets management 
follows NIST AC-3 and SC-28. All logs flow to a central 
workspace where Sentinel monitors for security events."

## Cost
Foundation alone: ~$15-20/month
- Log Analytics: ~$5/mo (with light usage)
- Key Vault: ~$0.03 per 10K operations
- VNets/Peering: ~$5/mo for data transfer
- Sentinel: pay-as-you-go (analytics tier)
