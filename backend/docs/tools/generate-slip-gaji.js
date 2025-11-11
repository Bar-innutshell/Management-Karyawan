/**
 * Script untuk generate slip gaji test
 * Generate slip gaji untuk semua karyawan bulan Oktober 2025
 * 
 * Usage dari backend folder:
 *   node docs/tools/generate-slip-gaji.js
 */

const path = require('path');
// Resolve to backend/node_modules/@prisma/client
const { PrismaClient } = require(path.resolve(__dirname, '../../node_modules/@prisma/client'));
const prisma = new PrismaClient();
async function generateSlipGaji() {
  console.log('🧾 Generating Slip Gaji for Oktober 2025...\n');

  // Bulan dan tahun yang akan di-generate
  const bulan = 10;
  const tahun = 2025;

  try {
    // Get all users except Admin
    const users = await prisma.user.findMany({
      where: {
        role: {
          nama: {
            not: 'Admin'
          }
        }
      },
      include: {
        role: true
      },
      orderBy: {
        nama: 'asc'
      }
    });

    console.log(`📊 Found ${users.length} employees (excluding Admin)\n`);
    console.log('━'.repeat(80));

    let totalSlipCreated = 0;
    let totalGajiBersihAll = 0;

    for (const user of users) {
      console.log(`\n👤 Processing: ${user.nama} (${user.role.nama})`);
      console.log('─'.repeat(80));

      // Check if slip already exists
      const existingSlip = await prisma.slipGaji.findFirst({
        where: {
          userId: user.id,
          bulan: bulan,
          tahun: tahun
        }
      });

      if (existingSlip) {
        console.log(`   ⚠️  Slip already exists for ${bulan}/${tahun} - Skipping`);
        continue;
      }

      // Get all attendance for this month
      const startDate = new Date(tahun, bulan - 1, 1);
      const endDate = new Date(tahun, bulan, 0, 23, 59, 59);

      const absensiList = await prisma.absensi.findMany({
        where: {
          userId: user.id,
          tanggal: {
            gte: startDate,
            lte: endDate
          }
        }
      });

      console.log(`   📅 Attendance records: ${absensiList.length}`);

      if (absensiList.length === 0) {
        console.log(`   ⚠️  No attendance data - Skipping`);
        continue;
      }

      // Calculate totals
      let totalGajiDariAbsensi = 0;
      let totalPotonganTelat = 0;
      let jumlahAlpha = 0;
      let jumlahHadir = 0;

      absensiList.forEach((absensi) => {
        if (absensi.status === 'Hadir') {
          totalGajiDariAbsensi += absensi.totalGaji;
          totalPotonganTelat += absensi.potonganGaji;
          jumlahHadir++;
        } else if (absensi.status === 'Alpha') {
          jumlahAlpha++;
        }
      });

      // Calculate daily salary
      const gajiHarian = user.gajiPerJam * 6;

      // Calculate alpha deduction
      const potonganAlpha = jumlahAlpha * gajiHarian;

      // Determine bonus based on attendance rate
      let bonusKehadiran = 0;
      const attendanceRate = jumlahHadir / (jumlahHadir + jumlahAlpha);
      
      if (attendanceRate >= 0.95) {
        bonusKehadiran = 300000; // Perfect attendance
      } else if (attendanceRate >= 0.90) {
        bonusKehadiran = 200000; // Good attendance
      } else if (attendanceRate >= 0.85) {
        bonusKehadiran = 100000; // Fair attendance
      }

      // Special bonus for Chef (best performers)
      let bonusLainnya = 0;
      if (user.role.nama === 'Chef' && attendanceRate >= 0.95) {
        bonusLainnya = 150000; // Chef of the month
      }

      // Calculate totals
      const totalGajiKotor = totalGajiDariAbsensi + bonusKehadiran + bonusLainnya;
      const totalPotongan = totalPotonganTelat + potonganAlpha;
      const totalGajiBersih = totalGajiKotor - totalPotongan;

      // Create slip gaji
      const slipGaji = await prisma.slipGaji.create({
        data: {
          userId: user.id,
          bulan: bulan,
          tahun: tahun,
          gajiBulanan: totalGajiDariAbsensi,
          bonusKehadiran: bonusKehadiran,
          bonusLainnya: bonusLainnya,
          potonganAlpha: potonganAlpha,
          potonganTelat: totalPotonganTelat,
          potonganLainnya: 0,
          totalGajiKotor: totalGajiKotor,
          totalPotongan: totalPotongan,
          totalGajiBersih: totalGajiBersih,
          keterangan: `Gaji ${getMonthName(bulan)} ${tahun} - ${getBonusReason(attendanceRate, user.role.nama)}`
        }
      });

      console.log(`   ✅ Slip created successfully!`);
      console.log(`      Days Present: ${jumlahHadir} | Alpha: ${jumlahAlpha}`);
      console.log(`      Attendance Rate: ${(attendanceRate * 100).toFixed(1)}%`);
      console.log(`      Base Salary: Rp ${totalGajiDariAbsensi.toLocaleString('id-ID')}`);
      console.log(`      Bonus: Rp ${(bonusKehadiran + bonusLainnya).toLocaleString('id-ID')}`);
      console.log(`      Deductions: Rp ${totalPotongan.toLocaleString('id-ID')}`);
      console.log(`      💰 NET SALARY: Rp ${totalGajiBersih.toLocaleString('id-ID')}`);

      totalSlipCreated++;
      totalGajiBersihAll += totalGajiBersih;
    }

    console.log('\n' + '━'.repeat(80));
    console.log('\n✨ SUMMARY');
    console.log('━'.repeat(80));
    console.log(`   Total Slips Created: ${totalSlipCreated}`);
    console.log(`   Total Payroll (Net): Rp ${totalGajiBersihAll.toLocaleString('id-ID')}`);
    console.log('━'.repeat(80));
    console.log('\n✅ Slip Gaji Generation Completed!\n');

    // Show how to view the slips
    console.log('💡 To view the slips:');
    console.log('   1. Start server: node index.js');
    console.log('   2. Login as Admin:');
    console.log('      POST /auth/login');
    console.log('      { "email": "admin@restoran.com", "password": "admin123" }');
    console.log('   3. View all slips:');
    console.log(`      GET /gaji/slip/all?bulan=${bulan}&tahun=${tahun}`);
    console.log('   4. Or use Prisma Studio:');
    console.log('      npx prisma studio\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  }
}

function getMonthName(month) {
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return months[month - 1];
}

function getBonusReason(rate, role) {
  if (rate >= 0.95) {
    if (role === 'Chef') {
      return 'Perfect Attendance + Chef of the Month';
    }
    return 'Perfect Attendance Bonus';
  } else if (rate >= 0.90) {
    return 'Good Attendance Bonus';
  } else if (rate >= 0.85) {
    return 'Fair Attendance Bonus';
  }
  return 'No bonus this month';
}

// Run the script
generateSlipGaji()
  .catch((e) => {
    console.error('❌ Script failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
