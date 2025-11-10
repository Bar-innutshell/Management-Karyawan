const prisma = require('../config/prismaClient');


function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}


exports.showSchedule = async (req, res) => {
  try {
    const schedules = await prisma.jadwal.findMany({
      include: {
        user: {
          select: {
            id: true,
            nama: true,
            email: true,
          },
        },
      },
      orderBy: {
        waktuMulai: 'asc', 
      },
    });

    res.json({
      message: 'Daftar jadwal berhasil diambil',
      data: schedules,
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};


exports.createSchedule = async (req, res) => {
  try {
    
    const usersToSchedule = await prisma.user.findMany({
      where: {
        roleId: 3,
      },
      select: {
        id: true,
      },
    });

    const kasirToSchedule = await prisma.user.findMany({
      where: {
        roleId: 2,
      },
      select: {
        id: true,
      },
    });

    if (usersToSchedule.length === 0) {
      return res
        .status(404)
        .json({ message: 'Anda tidak memiliki karyawan' });
    }

    if (kasirToSchedule.length === 0) {
      return res
        .status(404)
        .json({ message: 'Segera rekrut kasir' });
    }

    const shuffledUsers = shuffleArray(usersToSchedule);
    const pagiCount = Math.floor(shuffledUsers.length / 2);
    const usersPagi = shuffledUsers.slice(0, pagiCount);
    const usersSore = shuffledUsers.slice(pagiCount); 

    const shuffledkasir = shuffleArray(kasirToSchedule);
    const kasirhitung = Math.floor(shuffledkasir.length / 2);
    const kasirPagi = shuffledkasir.slice(0, kasirhitung);
    const kasirSore = shuffledkasir.slice(kasirhitung); 

    const today = new Date();
    // Pagi: 08:00 - 16:00 hari ini
    const pagiMulai = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 8, 0, 0);
    const pagiSelesai = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 16, 0, 0);
    // Sore: 16:00 hari ini - 00:00 besok
    const soreMulai = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 16, 0, 0);
    const soreSelesai = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1, 0, 0, 0);

    
    const dataPagi = usersPagi.map(user => ({
      userId: user.id,
      waktuMulai: pagiMulai,
      waktuSelesai: pagiSelesai,
    }));

    const dataSore = usersSore.map(user => ({
      userId: user.id,
      waktuMulai: soreMulai,
      waktuSelesai: soreSelesai,
    }));

    const datakasirPagi = kasirPagi.map(user => ({
      userId: user.id,
      waktuMulai: pagiMulai,
      waktuSelesai: pagiSelesai,
    }));

    const datakasirSore = kasirSore.map(user => ({
      userId: user.id,
      waktuMulai: soreMulai,
      waktuSelesai: soreSelesai,
    }));

    
    const allNewData = [...dataPagi, ...dataSore, ...datakasirPagi, ...datakasirSore];

    
    const [deleteResult, createResult] = await prisma.$transaction([
      prisma.jadwal.deleteMany({}), 
      
      prisma.jadwal.createMany({
        data: allNewData,
      }),
    ]);

    res.status(201).json({
      message: 'Jadwal baru berhasil digenerate!',
      details: {
        jadwalLamaDihapus: deleteResult.count,
        jadwalBaruDibuat: createResult.count,
        totalUser: usersToSchedule.length,
        grupPagi: usersPagi.length,
        grupSore: usersSore.length,
        groupkasirpagi: kasirPagi.length,
        groupkasirsore: kasirSore.length,
      }
    });

  } catch (error) {
    res
      .status(500)
      .json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};