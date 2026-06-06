# VNet + Cost Management

## Overview
Production VNet with multi-tier subnets + automated cost controls.

## Components
- VNet (10.0.0.0/16) with 4 subnets
- AzureBastionSubnet (special name required!)
- Action group for alerts
- Monthly budget ($200) with 3 thresholds:
  - 50% Actual (early warning)
  - 80% Actual (urgent)
  - 100% Forecasted (predictive)

## NIST 800-53 Controls
- CM-2: Baseline Configuration (tagged resources)
- SA-9: External System Services (cost tracking)
- PM-3: Security Resources (budget tracking)
