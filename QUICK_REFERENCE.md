# Quick Reference Guide - Stock Assignment & Invoice Sharing

## Feature 1: Assign Stock to Delivery Boys

### How It Works
1. Admin navigates to Admin Dashboard
2. Clicks **"Assign Stock"** button in Quick Actions section
3. Selects a delivery boy from dropdown
4. Enters:
   - Half Liter Bottles count
   - One Liter Bottles count
   - Collected Bottles count
5. Clicks **"Assign Stock"**
6. Stock entry is created for today's date

### API Endpoint
```
POST /api/admin/stock-entries
Headers: Authorization: Bearer {token}
Body: {
  "delivery_boy_id": 1,
  "half_ltr_bottles": 10,
  "one_ltr_bottles": 5,
  "collected_bottles": 8,
  "entry_date": "2025-01-24"
}
```

---

## Feature 2: Generate & Share Invoice

### How It Works
1. Admin navigates to Admin Dashboard
2. Clicks **"Share Invoice"** button in Quick Actions section
3. **InvoiceShareDialog** opens with options:
   - Select Customer (dropdown, required)
   - Optional Date Range:
     - Checkbox to enable date range
     - Calendar pickers for From Date and To Date
4. Clicks **"Generate & Share"**
5. Invoice preview shows:
   - Customer details (name, phone, address)
   - Delivery history (date, quantity, rate, collected)
   - Summary (total milk, total collected, pending amount)
6. Can click **"Share"** button to share invoice (extends to WhatsApp/Email in future)

### API Endpoint
```
GET /api/admin/invoice?customer_id=1&start_date=2025-01-01&end_date=2025-01-31
Headers: Authorization: Bearer {token}

Response:
{
  "customer_name": "John Doe",
  "customer_phone": "1234567890",
  "customer_address": "123 Main St",
  "period_start": "2025-01-01",
  "period_end": "2025-01-31",
  "entries": [...],
  "total_milk": 50.0,
  "total_collected": 2500.0,
  "total_pending": "1500.00",
  "generated_date": "2025-01-24"
}
```

---

## File Structure

```
delivery_app/lib/
├── presentation/screens/admin/
│   ├── admin_dashboard.dart (UPDATED - added Quick Actions)
│   ├── assign_stock_screen.dart (NEW)
│   └── invoice_share_dialog.dart (NEW)
├── data/repositories/
│   └── admin_repository.dart (UPDATED - added generateInvoice)
├── core/constants/
│   └── api_constants.dart (UPDATED - added adminInvoice)

backend/src/
├── routes/
│   └── admin.routes.js (UPDATED - added /invoice route)
└── controllers/
    └── admin.controller.js (UPDATED - added generateInvoice method)
```

---

## User Actions Flow

### Admin Dashboard
```
┌─────────────────────────────────┐
│    Admin Dashboard              │
│                                 │
│  [Stats: 4 cards]               │
│                                 │
│  Management:                    │
│  • Delivery Boy Management      │
│  • Customer Management          │
│  • Area Management              │
│  • Stock Management             │
│  • Reason Management            │
│                                 │
│  Quick Actions:                 │
│  [Assign Stock] [Share Invoice] │ ← NEW
└─────────────────────────────────┘
        │                    │
        ▼                    ▼
   ┌─────────────┐    ┌──────────────┐
   │AssignStock  │    │InvoiceDialog │
   │Screen       │    │              │
   └─────────────┘    └──────────────┘
```

---

## Data Models

### Stock Entry
```dart
{
  'id': 1,
  'delivery_boy_id': 1,
  'delivery_boy_name': 'Ahmed Khan',
  'half_ltr_bottles': 10,
  'one_ltr_bottles': 5,
  'collected_bottles': 8,
  'entry_date': '2025-01-24',
  'created_at': '2025-01-24T10:30:00'
}
```

### Invoice Response
```dart
{
  'customer_name': 'John Doe',
  'customer_phone': '1234567890',
  'customer_address': '123 Main St',
  'period_start': '2025-01-01',
  'period_end': '2025-01-31',
  'entries': [
    {
      'date': '2025-01-01',
      'milk_quantity': 2.5,
      'rate': 50,
      'collected': 100,
      'payment_method': 'cash',
      'is_delivered': true
    }
  ],
  'total_milk': 50.0,
  'total_collected': 2500.0,
  'total_pending': '1500.00',
  'generated_date': '2025-01-24'
}
```

---

## Error Handling

### Assign Stock Screen
- ✅ Validates delivery boy selection
- ✅ Validates all bottle counts are numbers
- ✅ Shows success/error snackbars
- ✅ Clears form after successful submission

### Invoice Dialog
- ✅ Requires customer selection
- ✅ Requires both dates if date range is selected
- ✅ Handles API errors with error message display
- ✅ Shows loading state while generating invoice
- ✅ Displays "No entries" message if no data found

---

## Colors & Icons

### Assign Stock Button
- Color: `AppColors.warning` (Yellow/Orange)
- Icon: `Icons.inventory_2`
- Position: Quick Actions (left button)

### Share Invoice Button
- Color: `AppColors.info` (Blue)
- Icon: `Icons.receipt`
- Position: Quick Actions (right button)

---

## Testing Scenarios

### Scenario 1: Assign Stock
1. Go to Admin Dashboard
2. Click "Assign Stock"
3. Select any delivery boy
4. Enter: half=10, one=5, collected=8
5. Click "Assign Stock"
6. ✅ Should see success message and navigate back

### Scenario 2: Generate Invoice Without Date Range
1. Go to Admin Dashboard
2. Click "Share Invoice"
3. Select any customer
4. Leave date range unchecked
5. Click "Generate & Share"
6. ✅ Should show invoice with all-time data

### Scenario 3: Generate Invoice With Date Range
1. Go to Admin Dashboard
2. Click "Share Invoice"
3. Select any customer
4. Check "Use Date Range"
5. Select From Date: 2025-01-01
6. Select To Date: 2025-01-31
7. Click "Generate & Share"
8. ✅ Should show invoice for that date range only

### Scenario 4: Error Cases
- ✅ No customer selected → Error message
- ✅ Date range enabled but date missing → Error message
- ✅ API failure → Shows error details
- ✅ No entries in date range → Shows "No entries" message

---

## Next Steps (Future Enhancements)

1. **PDF Export**: Add pdf generation library and export button
2. **Email Integration**: Send invoice via email
3. **WhatsApp Integration**: Share via WhatsApp using url_launcher
4. **Batch Operations**: Generate multiple invoices at once
5. **Invoice History**: Store and retrieve saved invoices
6. **Custom Invoice Templates**: Allow admins to customize invoice format
