# PIM + Sentinel Security Architecture

## Overview
Production-grade automated privileged access monitoring with NIST 800-53 alignment.

## Architecture
- **Log Analytics Workspace**: Centralized security data lake (90-day retention)
- **Microsoft Sentinel**: SIEM with KQL-based detection rules
- **Entra ID Diagnostic Settings**: PIM events streamed to Sentinel
- **Action Group**: Automated incident notifications

## NIST 800-53 Controls Implemented
- **AC-2**: Account Management automation
- **AC-6**: Least Privilege via JIT access
- **AC-6(7)**: Privileged Access Review (automated)
- **AU-2**: Auditable Events (PIM activations logged)
- **AU-6**: Audit Review (KQL detection rules)
- **AU-12**: Audit Generation (continuous)
- **SI-4**: Information System Monitoring (Sentinel)
- **SI-4(18)**: Privileged Activity Analysis

## Detection Capabilities
1. After-hours PIM activations
2. Multiple activations in short windows
3. PIM activation + immediate privileged action
4. Failed PIM activation attempts (attack indicator)
5. PIM activations from risky users

## Deployment
```bash
terraform init
terraform plan -var="subscription_id=$SUBSCRIPTION_ID"
terraform apply -var="subscription_id=$SUBSCRIPTION_ID"
```

## Requirements
- Entra ID P2 license (for PIM)
- Azure subscription with Owner access
- Sentinel pricing tier acceptance
