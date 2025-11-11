const prisma = require('../config/prismaClient');

/**
 * GET TOTAL PEMASUKKAN (Admin only)
 * Menghitung total pemasukkan dari semua laporan
 */
exports.getTotalPemasukkan = async (req, res) => {
  try {
    const { startDate, endDate, shift } = req.query;
    
    // Build filter condition
    const whereCondition = {};
    
    if (startDate || endDate) {
      whereCondition.tanggalLaporan = {};
      if (startDate) {
        whereCondition.tanggalLaporan.gte = new Date(startDate);
      }
      if (endDate) {
        whereCondition.tanggalLaporan.lte = new Date(endDate);
      }
    }
    
    if (shift) {
      whereCondition.shift = shift;
    }

    // Get total sum
    const totalPemasukkan = await prisma.laporanPemasukan.aggregate({
      where: whereCondition,
      _sum: {
        jumlahPemasukan: true,
      },
      _count: {
        id: true,
      },
    });

    res.json({
      message: 'Total pemasukkan berhasil dihitung',
      data: {
        totalPemasukkan: totalPemasukkan._sum.jumlahPemasukan || 0,
        jumlahTransaksi: totalPemasukkan._count.id || 0,
        filter: {
          startDate: startDate || 'all',
          endDate: endDate || 'all',
          shift: shift || 'all',
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};

/**
 * GET LAPORAN HARIAN (Admin only)
 * Menampilkan laporan pemasukkan per hari dalam bentuk tabel
 */
exports.getLaporanHarian = async (req, res) => {
  try {
    const { startDate, endDate, shift } = req.query;
    
    // Build filter condition
    const whereCondition = {};
    
    if (startDate || endDate) {
      whereCondition.tanggalLaporan = {};
      if (startDate) {
        whereCondition.tanggalLaporan.gte = new Date(startDate);
      }
      if (endDate) {
        whereCondition.tanggalLaporan.lte = new Date(endDate);
      }
    }
    
    if (shift) {
      whereCondition.shift = shift;
    }

    // Get all records with grouping
    const laporanPemasukkan = await prisma.laporanPemasukan.findMany({
      where: whereCondition,
      select: {
        id: true,
        jumlahPemasukan: true,
        tanggalLaporan: true,
        shift: true,
        user: {
          select: {
            id: true,
            nama: true,
            email: true,
          },
        },
      },
      orderBy: {
        tanggalLaporan: 'desc',
      },
    });

    // Group by date for daily summary
    const dailySummary = laporanPemasukkan.reduce((acc, item) => {
      const date = new Date(item.tanggalLaporan).toISOString().split('T')[0];
      
      if (!acc[date]) {
        acc[date] = {
          tanggal: date,
          totalPemasukkan: 0,
          jumlahTransaksi: 0,
          byShift: {},
          details: [],
        };
      }
      
      acc[date].totalPemasukkan += item.jumlahPemasukan;
      acc[date].jumlahTransaksi += 1;
      acc[date].details.push(item);
      
      // Group by shift
      if (!acc[date].byShift[item.shift]) {
        acc[date].byShift[item.shift] = {
          shift: item.shift,
          total: 0,
          count: 0,
        };
      }
      acc[date].byShift[item.shift].total += item.jumlahPemasukan;
      acc[date].byShift[item.shift].count += 1;
      
      return acc;
    }, {});

    // Convert to array and sort by date desc
    const dailyReport = Object.values(dailySummary).sort((a, b) => 
      new Date(b.tanggal) - new Date(a.tanggal)
    );

    res.json({
      message: 'Laporan harian berhasil diambil',
      data: {
        summary: dailyReport,
        totalKeseluruhan: dailyReport.reduce((sum, day) => sum + day.totalPemasukkan, 0),
        totalTransaksi: dailyReport.reduce((sum, day) => sum + day.jumlahTransaksi, 0),
      },
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};

/**
 * GET LAPORAN DETAIL (Admin only)
 * Menampilkan detail semua pemasukkan dalam bentuk tabel
 */
exports.getLaporanDetail = async (req, res) => {
  try {
    const { page = 1, limit = 50, startDate, endDate, shift, userId } = req.query;
    
    // Build filter condition
    const whereCondition = {};
    
    if (startDate || endDate) {
      whereCondition.tanggalLaporan = {};
      if (startDate) {
        whereCondition.tanggalLaporan.gte = new Date(startDate);
      }
      if (endDate) {
        whereCondition.tanggalLaporan.lte = new Date(endDate);
      }
    }
    
    if (shift) {
      whereCondition.shift = shift;
    }
    
    if (userId) {
      whereCondition.userId = parseInt(userId);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [laporanPemasukkan, totalCount] = await Promise.all([
      prisma.laporanPemasukan.findMany({
        where: whereCondition,
        select: {
          id: true,
          jumlahPemasukan: true,
          tanggalLaporan: true,
          shift: true,
          user: {
            select: {
              id: true,
              nama: true,
              email: true,
              role: {
                select: {
                  nama: true,
                },
              },
            },
          },
        },
        orderBy: {
          tanggalLaporan: 'desc',
        },
        skip: skip,
        take: parseInt(limit),
      }),
      prisma.laporanPemasukan.count({ where: whereCondition }),
    ]);

    res.json({
      message: 'Laporan detail berhasil diambil',
      data: laporanPemasukkan,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(totalCount / parseInt(limit)),
        totalRecords: totalCount,
        limit: parseInt(limit),
      },
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};
