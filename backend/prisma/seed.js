const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // ==================== ROLES ====================
  console.log('\n📌 Creating roles...');
  
  const rolesData = [
    {
      nama: 'Admin',
      gajiPokokBulanan: 8000000,
      deskripsi: 'Administrator sistem dengan akses penuh'
    },
    {
      nama: 'Cashier',
      gajiPokokBulanan: 4500000,
      deskripsi: 'Kasir restoran, handle transaksi dan pembayaran'
    },
    {
      nama: 'Employee',
      gajiPokokBulanan: 3600000,
      deskripsi: 'Karyawan biasa, staff operasional restoran'
    },
    {
      nama: 'Chef',
      gajiPokokBulanan: 5500000,
      deskripsi: 'Koki profesional, handle dapur dan menu'
    },
    {
      nama: 'Waiter',
      gajiPokokBulanan: 3200000,
      deskripsi: 'Pelayan restoran, melayani customer'
    }
  ];

  const roles = {};
  for (const roleData of rolesData) {
    const role = await prisma.role.upsert({
      where: { nama: roleData.nama },
      update: {
        gajiPokokBulanan: roleData.gajiPokokBulanan,
        deskripsi: roleData.deskripsi
      },
      create: roleData
    });
    roles[roleData.nama] = role;
    console.log(`   ✅ ${roleData.nama} (ID: ${role.id})`);
  }

  // ==================== USERS ====================
  console.log('\n📌 Creating users with diverse roles...');
  
  const usersData = [
    {
      nama: 'Ahmad Rizki',
      email: 'admin@restoran.com',
      password: 'admin123',
      role: 'Admin'
    },
    {
      nama: 'Siti Nurhaliza',
      email: 'siti.cashier@restoran.com',
      password: 'siti123',
      role: 'Cashier'
    },
    {
      nama: 'Budi Santoso',
      email: 'budi.chef@restoran.com',
      password: 'budi123',
      role: 'Chef'
    },
    {
      nama: 'Dewi Lestari',
      email: 'dewi.waiter@restoran.com',
      password: 'dewi123',
      role: 'Waiter'
    },
    {
      nama: 'Eko Prasetyo',
      email: 'eko.employee@restoran.com',
      password: 'eko123',
      role: 'Employee'
    },
    {
      nama: 'Fitri Handayani',
      email: 'fitri.waiter@restoran.com',
      password: 'fitri123',
      role: 'Waiter'
    },
    {
      nama: 'Gilang Ramadhan',
      email: 'gilang.cashier@restoran.com',
      password: 'gilang123',
      role: 'Cashier'
    },
    {
      nama: 'Hana Safitri',
      email: 'hana.chef@restoran.com',
      password: 'hana123',
      role: 'Chef'
    }
  ];

  const users = [];
  for (const userData of usersData) {
    const hashedPassword = await bcrypt.hash(userData.password, 10);
    const user = await prisma.user.upsert({
      where: { email: userData.email },
      update: {
        nama: userData.nama,
        password: hashedPassword,
        roleId: roles[userData.role].id
      },
      create: {
        nama: userData.nama,
        email: userData.email,
        password: hashedPassword,
        roleId: roles[userData.role].id
      }
    });
    users.push(user);
    console.log(`   ✅ ${userData.nama} (${userData.role}) - ${userData.email}`);
  }

  // ==================== ABSENSI HISTORY ====================
  console.log('\n  Creating attendance history (last 30 days)...');
  
  const today = new Date();
  const thirtyDaysAgo = new Date(today);
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  let totalAbsensi = 0;
  
  // Skip Admin (index 0), create attendance for employees only
  for (let i = 1; i < users.length; i++) {
    const user = users[i];
    const userRole = usersData[i].role;
    
    // Variasi kehadiran berdasarkan role
    let attendanceRate = 0.9; // 90% default
    if (userRole === 'Chef') attendanceRate = 0.95; // Chef rajin
    if (userRole === 'Waiter') attendanceRate = 0.85; // Waiter agak sering absen
    if (userRole === 'Employee') attendanceRate = 0.80; // Employee paling sering absen
    
    for (let day = 0; day < 30; day++) {
      const date = new Date(thirtyDaysAgo);
      date.setDate(date.getDate() + day);
      
      // Skip weekend (0 = Sunday, 6 = Saturday)
      const dayOfWeek = date.getDay();
      if (dayOfWeek === 0 || dayOfWeek === 6) continue;
      
      // Random attendance based on rate
      if (Math.random() > attendanceRate) continue;
      
      // Shift distribution (Cashier lebih sering shift siang, Chef lebih bervariasi)
      const shift = userRole === 'Cashier' 
        ? (Math.random() > 0.3 ? 'Siang' : 'Sore')
        : (Math.random() > 0.5 ? 'Siang' : 'Sore');
      
      // Jam shift
      const jamMulai = shift === 'Siang' ? 9 : 15;
      const jamSelesai = jamMulai + 6;
      
      // Clock in time dengan variasi (kadang telat)
      const menitTelat = Math.random() > 0.7 ? Math.floor(Math.random() * 30) : 0; // 30% chance telat
      
      const jamMulaiShift = new Date(date);
      jamMulaiShift.setHours(jamMulai, 0, 0, 0);
      
      const jamSelesaiShift = new Date(date);
      jamSelesaiShift.setHours(jamSelesai, 0, 0, 0);
      
      const jamMasuk = new Date(date);
      jamMasuk.setHours(jamMulai, menitTelat, 0, 0);
      
      // Clock out time (6 jam kerja + variasi overtime)
      const overtime = Math.random() > 0.8 ? Math.floor(Math.random() * 2) : 0; // 20% chance overtime
      const jamKeluar = new Date(jamMasuk);
      jamKeluar.setHours(jamKeluar.getHours() + 6 + overtime);
      
      // Hitung jam kerja actual
      const jamKerja = (jamKeluar - jamMasuk) / (1000 * 60 * 60); // convert ms to hours
      
      // Hitung potongan gaji (toleransi 10 menit)
      const toleransi = 10;
      const menitTerlambatReal = menitTelat > toleransi ? menitTelat - toleransi : 0;
      const gajiPerJam = roles[userRole].gajiPokokBulanan / 20 / 6; // Gaji per jam dari gaji pokok bulanan
      const potonganGaji = (menitTerlambatReal / 60) * gajiPerJam;
      
      // Hitung total gaji harian
      const totalGaji = (jamKerja * gajiPerJam) - potonganGaji;
      
      const tanggal = new Date(date);
      tanggal.setHours(0, 0, 0, 0);
      
      // Try to create absensi with all fields
      // Will work for both old schema (with jamMulaiShift) and new schema (without)
      try {
        await prisma.absensi.create({
          data: {
            userId: user.id,
            tanggal: tanggal,
            shift: shift,
            jamMulaiShift: jamMulaiShift,
            jamSelesaiShift: jamSelesaiShift,
            jamMasuk: jamMasuk,
            jamKeluar: jamKeluar,
            jamKerja: jamKerja,
            menitTerlambat: menitTelat,
            potonganGaji: Math.round(potonganGaji),
            totalGaji: Math.round(totalGaji),
            status: 'Hadir'
          }
        });
      } catch (error) {
        // If jamMulaiShift/jamSelesaiShift doesn't exist, try without them
        if (error.message.includes('Unknown argument jamMulaiShift') || 
            error.message.includes('Unknown argument jamSelesaiShift')) {
          await prisma.absensi.create({
            data: {
              userId: user.id,
              tanggal: tanggal,
              shift: shift,
              jamMasuk: jamMasuk,
              jamKeluar: jamKeluar,
              jamKerja: jamKerja,
              menitTerlambat: menitTelat,
              potonganGaji: Math.round(potonganGaji),
              totalGaji: Math.round(totalGaji),
              status: 'Hadir'
            }
          });
        } else {
          throw error;
        }
      }
      
      totalAbsensi++;
    }
  }
  
  console.log(`   ✅ Created ${totalAbsensi} attendance records`);

  // ==================== LAPORAN PEMASUKAN ====================
  console.log('\n📌 Creating income reports (last 30 days)...');
  
  // Get cashier users
  const cashiers = users.filter((_, i) => ['Cashier'].includes(usersData[i].role));
  
  let totalLaporan = 0;
  
  for (let day = 0; day < 30; day++) {
    const date = new Date(thirtyDaysAgo);
    date.setDate(date.getDate() + day);
    
    // Skip weekend
    const dayOfWeek = date.getDay();
    if (dayOfWeek === 0 || dayOfWeek === 6) continue;
    
    // 2 shifts per day
    for (const shift of ['Siang', 'Sore']) {
      const cashier = cashiers[Math.floor(Math.random() * cashiers.length)];
      
      // Random income (Siang lebih ramai, Sore lebih sepi)
      const baseIncome = shift === 'Siang' ? 2000000 : 1500000;
      const variance = baseIncome * 0.3;
      const income = baseIncome + (Math.random() * variance) - (variance / 2);
      
      const tanggalLaporan = new Date(date);
      tanggalLaporan.setHours(shift === 'Siang' ? 14 : 20, 0, 0, 0);
      
      await prisma.laporanPemasukan.create({
        data: {
          userId: cashier.id,
          jumlahPemasukan: Math.round(income),
          tanggalLaporan: tanggalLaporan,
          shift: shift
        }
      });
      
      totalLaporan++;
    }
  }
  
  console.log(`   ✅ Created ${totalLaporan} income reports`);

  // ==================== SUMMARY ====================
  console.log('\n\n═══════════════════════════════════════════════════');
  console.log('✨ SEED COMPLETED SUCCESSFULLY! ✨');
  console.log('═══════════════════════════════════════════════════\n');
  
  console.log('  USERS CREATED:');
  console.log('─────────────────────────────────────────────────');
  for (let i = 0; i < users.length; i++) {
    const userData = usersData[i];
    console.log(`${i + 1}. ${userData.nama.padEnd(20)} | ${userData.role.padEnd(10)} | ${userData.email}`);
    console.log(`   Password: ${userData.password}`);
  }
  
  console.log('\n📊 STATISTICS:');
  console.log('─────────────────────────────────────────────────');
  console.log(`   Roles:              ${Object.keys(roles).length}`);
  console.log(`   Users:              ${users.length}`);
  console.log(`   Attendance Records: ${totalAbsensi}`);
  console.log(`   Income Reports:     ${totalLaporan}`);
  
  const totalIncome = await prisma.laporanPemasukan.aggregate({
    _sum: { jumlahPemasukan: true }
  });
  
  console.log(`   Total Income (30d): Rp ${totalIncome._sum.jumlahPemasukan?.toLocaleString('id-ID') || 0}`);
  
  console.log('\n💡 LOGIN CREDENTIALS:');
  console.log('─────────────────────────────────────────────────');
  console.log('   Admin:   admin@restoran.com / admin123');
  console.log('   Cashier: siti.cashier@restoran.com / siti123');
  console.log('   Chef:    budi.chef@restoran.com / budi123');
  console.log('   Waiter:  dewi.waiter@restoran.com / dewi123');
  console.log('═══════════════════════════════════════════════════\n');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });