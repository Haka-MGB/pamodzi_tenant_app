const mongoose = require('mongoose');
require('dotenv').config();

const User = require('../models/User');
const Property = require('../models/Property');
const Lease = require('../models/Lease');
const Payment = require('../models/Payment');
const MaintenanceIssue = require('../models/MaintenanceIssue');
const Notification = require('../models/Notification');

// Connect to database
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

async function seedDatabase() {
  try {
    // Clear existing data
    console.log('🗑️  Clearing existing data...');
    await User.deleteMany({});
    await Property.deleteMany({});
    await Lease.deleteMany({});
    await Payment.deleteMany({});
    await MaintenanceIssue.deleteMany({});
    await Notification.deleteMany({});

    // Create Landlord
    console.log('👤 Creating landlord...');
    const landlord = await User.create({
      email: 'landlord@pamodzi.zm',
      password: 'landlord2026',
      firstName: 'Joseph',
      lastName: 'Mwansa',
      phone: '+260977555123',
      role: 'landlord'
    });

    // Create Tenant (matches demo credentials)
    console.log('👤 Creating tenant...');
    const tenant = await User.create({
      email: 'chanda.m@pamodzi.com',
      password: 'rent2026',
      firstName: 'Mary',
      lastName: 'Chanda',
      phone: '+260977123456',
      nrc: '123456/78/9',
      role: 'tenant'
    });

    // Create Property
    console.log('🏠 Creating property...');
    const property = await Property.create({
      name: 'Woodlands Apartment 204',
      address: {
        street: 'Los Angeles Boulevard',
        city: 'Lusaka',
        province: 'Lusaka Province',
        zipCode: '10101'
      },
      type: 'apartment',
      bedrooms: 2,
      bathrooms: 1,
      size: {
        value: 75,
        unit: 'sqm'
      },
      rent: {
        amount: 2200,
        currency: 'ZMW',
        dueDay: 1
      },
      landlord: landlord._id,
      amenities: [
        'Water included',
        'Security',
        'Parking',
        'Wi-Fi ready'
      ],
      isAvailable: false // Currently rented
    });

    // Create Lease
    console.log('📄 Creating lease...');
    const startDate = new Date('2025-01-01');
    const endDate = new Date('2026-12-31');
    
    const lease = await Lease.create({
      tenant: tenant._id,
      property: property._id,
      landlord: landlord._id,
      startDate,
      endDate,
      rentAmount: 2200,
      securityDeposit: 2200,
      paymentFrequency: 'monthly',
      status: 'active',
      terms: `
RESIDENTIAL LEASE AGREEMENT

This Lease Agreement is entered into on January 1, 2025, between:

LANDLORD: Joseph Mwansa
TENANT: Mary Chanda
PROPERTY: Woodlands Apartment 204, Los Angeles Boulevard, Lusaka

1. TERM: The lease term is from January 1, 2025 to December 31, 2026 (24 months).

2. RENT: Monthly rent is K2,200.00 ZMW, due on the 1st of each month.

3. LATE FEES: Late payment after the 5th of the month incurs a K100 late fee, plus K20 per day thereafter.

4. SECURITY DEPOSIT: A security deposit of K2,200.00 has been paid and will be returned within 30 days of lease termination, subject to property condition.

5. UTILITIES: Water is included. Electricity is the responsibility of the tenant.

6. MAINTENANCE: Tenant must report all maintenance issues promptly. Landlord will address issues within reasonable time.

7. TERMINATION: Either party may terminate with 60 days written notice.

8. GOVERNING LAW: This agreement is governed by the laws of Zambia.
      `.trim()
    });

    // Create Payment History
    console.log('💰 Creating payment history...');
    const payments = [];
    const months = ['January', 'February', 'March', 'April', 'May'];
    
    for (let i = 0; i < months.length; i++) {
      const paymentDate = new Date(2026, i, 2); // 2nd of each month
      
      const payment = await Payment.create({
        tenant: tenant._id,
        lease: lease._id,
        property: property._id,
        amount: 2200,
        currency: 'ZMW',
        paymentMethod: i % 2 === 0 ? 'airtel_money' : 'mtn_momo',
        paymentFor: {
          month: months[i],
          year: 2026
        },
        status: 'completed',
        phoneNumber: '+260977123456',
        verifiedAt: paymentDate,
        createdAt: paymentDate,
        updatedAt: paymentDate
      });
      payments.push(payment);
    }

    // Create Maintenance Issues
    console.log('🔧 Creating maintenance issues...');
    
    await MaintenanceIssue.create({
      tenant: tenant._id,
      property: property._id,
      category: 'Plumbing',
      title: 'Leaking kitchen faucet',
      description: 'The kitchen faucet has been dripping constantly for the past week. Water is being wasted.',
      priority: 'High',
      status: 'In Progress',
      assignedTo: landlord._id,
      assignedAt: new Date('2026-07-10'),
      createdAt: new Date('2026-07-08')
    });

    await MaintenanceIssue.create({
      tenant: tenant._id,
      property: property._id,
      category: 'Electrical',
      title: 'Bedroom outlet not working',
      description: 'The power outlet near the bed stopped working yesterday.',
      priority: 'Medium',
      status: 'Open',
      createdAt: new Date('2026-07-12')
    });

    await MaintenanceIssue.create({
      tenant: tenant._id,
      property: property._id,
      category: 'HVAC',
      title: 'Air conditioning making noise',
      description: 'Strange rattling sound from AC unit',
      priority: 'Low',
      status: 'Resolved',
      assignedTo: landlord._id,
      resolvedAt: new Date('2026-07-01'),
      resolutionNotes: 'Filter cleaned and fan belt tightened',
      createdAt: new Date('2026-06-25')
    });

    // Create Notifications
    console.log('🔔 Creating notifications...');
    
    await Notification.create({
      recipient: tenant._id,
      type: 'payment',
      title: 'Payment Successful',
      message: 'Your rent payment of K2,200 for May 2026 has been received.',
      relatedEntity: {
        entityType: 'Payment',
        entityId: payments[4]._id
      },
      isRead: false,
      createdAt: new Date('2026-05-02')
    });

    await Notification.create({
      recipient: tenant._id,
      type: 'maintenance',
      title: 'Maintenance Update',
      message: 'Your plumbing issue is now being addressed. Expected completion in 2 days.',
      isRead: false,
      priority: 'normal',
      createdAt: new Date('2026-07-10')
    });

    await Notification.create({
      recipient: tenant._id,
      type: 'lease',
      title: 'Lease Renewal Reminder',
      message: 'Your lease is expiring in 6 months. Contact landlord to discuss renewal.',
      isRead: false,
      priority: 'normal',
      createdAt: new Date('2026-06-15')
    });

    await Notification.create({
      recipient: tenant._id,
      type: 'general',
      title: 'Water Supply Interruption',
      message: 'Scheduled water maintenance on July 20. Supply will be off from 9 AM to 2 PM.',
      isRead: true,
      readAt: new Date('2026-07-08'),
      createdAt: new Date('2026-07-05')
    });

    console.log('✅ Database seeded successfully!');
    console.log('\n📊 Summary:');
    console.log(`   👤 Users: 2 (1 landlord, 1 tenant)`);
    console.log(`   🏠 Properties: 1`);
    console.log(`   📄 Leases: 1`);
    console.log(`   💰 Payments: ${payments.length}`);
    console.log(`   🔧 Maintenance Issues: 3`);
    console.log(`   🔔 Notifications: 4`);
    console.log('\n🔑 Login Credentials:');
    console.log('   Tenant:');
    console.log('   Email: chanda.m@pamodzi.com');
    console.log('   Password: rent2026');
    console.log('\n   Landlord:');
    console.log('   Email: landlord@pamodzi.zm');
    console.log('   Password: landlord2026');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase();
