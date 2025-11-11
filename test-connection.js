const sql = require('mssql');

const config = {
  server: 'localhost',
  port: 1433,
  user: 'prisma_user',
  password: 'Prisma!2025',
  database: 'db_restoran',
  options: {
    encrypt: true,
    trustServerCertificate: true,
    connectTimeout: 30000 // 30 detik timeout
  }
};

async function testConnection() {
  try {
    console.log('🔄 Mencoba koneksi ke SQL Server...');
    const pool = await sql.connect(config);
    console.log('✅ Koneksi BERHASIL!');
    
    const result = await pool.request().query('SELECT @@VERSION AS Version');
    console.log('SQL Server Version:', result.recordset[0].Version);
    
    await pool.close();
  } catch (err) {
    console.error('❌ Koneksi GAGAL!');
    console.error('Error:', err.message);
    console.error('\nDetail:', err);
  }
}

testConnection();