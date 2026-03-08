# Payment Integration Plan

## Overview
Complete payment system integration for AFRO platform supporting local and international payments.

---

## Payment Gateways to Integrate

### International Payments
1. **Stripe** - Credit/Debit cards, Apple Pay, Google Pay
2. **PayPal** - PayPal accounts, cards
3. **Flutterwave** - African payment methods

### Local Payments (Ethiopia/Africa)
1. **Telebirr** - Ethiopian mobile money
2. **CBE Birr** - Commercial Bank of Ethiopia
3. **M-Pesa** - East African mobile money
4. **Chapa** - Ethiopian payment gateway
5. **Cash on Service** - Pay at barbershop

---

## Payment Flow

### Customer Booking Flow
1. Customer selects service and time
2. Views price breakdown
3. Selects payment method
4. For online payment:
   - Redirects to payment gateway
   - Completes payment
   - Returns to app with confirmation
5. For cash payment:
   - Books appointment
   - Pays at barbershop
6. Receives booking confirmation

### Provider Payment Flow
1. Provider receives booking notification
2. Confirms appointment
3. Completes service
4. For online payment:
   - Payment already received
   - Platform fee deducted
   - Balance added to provider wallet
5. For cash payment:
   - Customer pays provider directly
   - Provider reports payment
   - Platform fee deducted from next payout

---

## Database Schema

### Payments Table
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY,
  appointment_id UUID REFERENCES appointments(id),
  customer_id UUID REFERENCES users(id),
  provider_id UUID REFERENCES users(id),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'ETB',
  payment_method VARCHAR(50),
  payment_gateway VARCHAR(50),
  status VARCHAR(20),
  transaction_id VARCHAR(255),
  gateway_response JSONB,
  paid_at TIMESTAMP,
  refunded_at TIMESTAMP,
  refund_amount DECIMAL(10,2),
  refund_reason TEXT,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_payments_appointment ON payments(appointment_id);
CREATE INDEX idx_payments_customer ON payments(customer_id);
CREATE INDEX idx_payments_provider ON payments(provider_id);
CREATE INDEX idx_payments_status ON payments(status);
```

### Provider Wallets Table
```sql
CREATE TABLE provider_wallets (
  id UUID PRIMARY KEY,
  provider_id UUID REFERENCES users(id) UNIQUE,
  balance DECIMAL(10,2) DEFAULT 0,
  pending_balance DECIMAL(10,2) DEFAULT 0,
  total_earned DECIMAL(10,2) DEFAULT 0,
  total_withdrawn DECIMAL(10,2) DEFAULT 0,
  currency VARCHAR(3) DEFAULT 'ETB',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Transactions Table
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  wallet_id UUID REFERENCES provider_wallets(id),
  type VARCHAR(20), -- credit, debit, withdrawal, refund
  amount DECIMAL(10,2) NOT NULL,
  balance_after DECIMAL(10,2),
  description TEXT,
  reference_id UUID,
  reference_type VARCHAR(50),
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Withdrawals Table
```sql
CREATE TABLE withdrawals (
  id UUID PRIMARY KEY,
  provider_id UUID REFERENCES users(id),
  wallet_id UUID REFERENCES provider_wallets(id),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'ETB',
  method VARCHAR(50), -- bank_transfer, mobile_money
  account_details JSONB,
  status VARCHAR(20), -- pending, processing, completed, failed
  processed_at TIMESTAMP,
  processed_by UUID REFERENCES users(id),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## API Endpoints

### Customer Endpoints
```
POST   /api/v1/payments/initialize          - Initialize payment
POST   /api/v1/payments/verify               - Verify payment
GET    /api/v1/payments/methods              - Get available payment methods
GET    /api/v1/payments/history              - Get payment history
POST   /api/v1/payments/refund/:id           - Request refund
```

### Provider Endpoints
```
GET    /api/v1/providers/wallet              - Get wallet balance
GET    /api/v1/providers/transactions        - Get transaction history
POST   /api/v1/providers/withdraw            - Request withdrawal
GET    /api/v1/providers/withdrawals         - Get withdrawal history
GET    /api/v1/providers/earnings            - Get earnings analytics
```

### Admin Endpoints
```
GET    /api/v1/admin/payments                - List all payments
GET    /api/v1/admin/payments/:id            - Get payment details
POST   /api/v1/admin/payments/:id/refund     - Process refund
GET    /api/v1/admin/withdrawals             - List withdrawal requests
POST   /api/v1/admin/withdrawals/:id/approve - Approve withdrawal
POST   /api/v1/admin/withdrawals/:id/reject  - Reject withdrawal
GET    /api/v1/admin/financial-reports       - Get financial reports
```

---

## Payment Methods Configuration

### Stripe Integration
```typescript
// Supports: Credit/Debit cards, Apple Pay, Google Pay
// Currencies: USD, EUR, GBP, ETB (via conversion)
// Fees: 2.9% + $0.30 per transaction
```

### PayPal Integration
```typescript
// Supports: PayPal accounts, cards
// Currencies: USD, EUR, GBP
// Fees: 2.9% + $0.30 per transaction
```

### Flutterwave Integration
```typescript
// Supports: Cards, Mobile Money, Bank Transfer
// Currencies: ETB, KES, NGN, GHS, UGX, TZS
// Fees: 1.4% for cards, 1% for mobile money
```

### Chapa Integration (Ethiopia)
```typescript
// Supports: Telebirr, CBE Birr, Cards
// Currency: ETB
// Fees: 2.5% per transaction
```

### Telebirr Direct Integration
```typescript
// Supports: Telebirr mobile money
// Currency: ETB
// Fees: 1% per transaction
```

---

## Platform Fee Structure

### Commission Rates
- Standard: 15% of service price
- Premium providers: 10% of service price
- New providers (first 3 months): 5% of service price

### Fee Calculation
```
Service Price: 500 ETB
Platform Fee (15%): 75 ETB
Provider Receives: 425 ETB
```

---

## Security Measures

1. **PCI DSS Compliance**
   - Never store card details
   - Use tokenization
   - Secure API communication (HTTPS)

2. **Fraud Prevention**
   - Transaction monitoring
   - Velocity checks
   - IP geolocation
   - Device fingerprinting

3. **Data Protection**
   - Encrypt sensitive data
   - Secure webhook endpoints
   - Validate all callbacks

---

## Implementation Steps

### Phase 1: Backend (Week 1)
- [ ] Create payment entities and DTOs
- [ ] Implement payment service
- [ ] Add Stripe integration
- [ ] Add PayPal integration
- [ ] Create payment endpoints
- [ ] Add webhook handlers
- [ ] Implement wallet system
- [ ] Add transaction logging

### Phase 2: Customer App (Week 2)
- [ ] Create payment models
- [ ] Implement payment API service
- [ ] Add payment method selection UI
- [ ] Integrate Stripe SDK
- [ ] Integrate PayPal SDK
- [ ] Add payment confirmation screen
- [ ] Implement payment history
- [ ] Add refund request feature

### Phase 3: Provider App (Week 2)
- [ ] Create wallet UI
- [ ] Implement earnings dashboard
- [ ] Add transaction history
- [ ] Create withdrawal request form
- [ ] Add payout settings
- [ ] Implement earnings analytics

### Phase 4: Admin Panel (Week 3)
- [ ] Create payments management page
- [ ] Add financial reports
- [ ] Implement withdrawal approval
- [ ] Add refund processing
- [ ] Create revenue analytics
- [ ] Add payment gateway monitoring

### Phase 5: Testing & Deployment (Week 4)
- [ ] Test all payment flows
- [ ] Test refund process
- [ ] Test withdrawal process
- [ ] Security audit
- [ ] Load testing
- [ ] Deploy to production

---

## Testing Strategy

### Test Cases
1. Successful payment with each gateway
2. Failed payment handling
3. Payment timeout handling
4. Refund processing
5. Withdrawal processing
6. Commission calculation
7. Wallet balance updates
8. Transaction logging
9. Webhook verification
10. Security tests

---

## Monitoring & Analytics

### Metrics to Track
- Total transaction volume
- Success rate by gateway
- Average transaction value
- Failed payment reasons
- Refund rate
- Provider earnings
- Platform revenue
- Payment method distribution

---

## Compliance & Legal

### Requirements
- [ ] Terms of Service for payments
- [ ] Privacy Policy updates
- [ ] Refund Policy
- [ ] Provider payout terms
- [ ] Tax compliance (VAT/Sales Tax)
- [ ] Anti-money laundering (AML)
- [ ] Know Your Customer (KYC) for providers

---

## Cost Estimation

### Payment Gateway Fees
- Stripe: 2.9% + $0.30
- PayPal: 2.9% + $0.30
- Flutterwave: 1.4% (cards), 1% (mobile)
- Chapa: 2.5%
- Telebirr: 1%

### Monthly Costs (Estimated)
- Gateway fees: Variable based on volume
- Server costs: $50-100/month
- SSL certificates: $0 (Let's Encrypt)
- Monitoring tools: $20-50/month

---

## Next Steps

1. Review and approve this plan
2. Set up payment gateway accounts
3. Begin Phase 1 implementation
4. Set up test environments
5. Create test payment scenarios

---

**Status**: Ready for Implementation  
**Estimated Timeline**: 4 weeks  
**Priority**: High
