# Container Apps + ACR Integration

## Modern Serverless Containers
Production-grade serverless containers with private registry, managed identity, and scale-to-zero.

## Architecture
- ACR Premium (signed images, geo-replication ready)
- Container Apps Environment
- Container App with scale-to-zero
- Managed identity for ACR access (NO passwords!)
- Auto-scale based on HTTP traffic
- Full diagnostic logging

## Key Features
- Scale to zero when idle ($0 cost!)
- Scale up to 10 replicas under load
- HTTP-based auto-scaling
- Managed identity for image pulls
- Content trust for signed images
- Private network access (production)

## NIST 800-53 Controls
- SI-7: Software Integrity (signed images)
- AC-3: Access Enforcement (managed identity)
- SC-7: Boundary Protection (private network)
- AU-2: Auditable Events (Log Analytics)

## Cost Profile
Container Apps Pricing:
- Pay per vCPU-second
- Pay per GB-second memory
- FREE: 180K vCPU-sec/month
- Scale to zero = $0 idle cost

vs AKS:
- Always-running cluster: $100-300/mo minimum
- This pattern: $0 when idle, scales as needed
