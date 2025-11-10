const express = require('express')
const cors = require('cors')
const dotenv = require('dotenv')
const authRoutes = require('./routes/authRoute')
const roleRoutes = require('./routes/roleRoute')
const pemasukkanRoute = require('./routes/pemasukkanRoute')
dotenv.config()

const app = express()
app.use(cors())
app.use(express.json())

const sql = require('mssql')

const sqlConfig = {
  server: process.env.db_host || 'localhost',
  port: 1433,
  user: process.env.db_user,
  password: process.env.db_password,
  database: process.env.db_name,
  options: {
    encrypt: true,
    trustServerCertificate: process.env.db_trust_server_certificate === 'true'

  }
}

let pool
async function getPool() {
  if (!pool || !pool.connected) {
    pool = await sql.connect(sqlConfig)
  }
  return pool
}

app.get('/db/ping', async (req, res) => {
  try {
    const p = await getPool()
    const r = await p.request().query(
      "SELECT DB_NAME() AS db, @@SERVERNAME AS server, SERVERPROPERTY('InstanceName') AS instance"
    )
    res.json({ ok: true, ...r.recordset[0] })
  } catch (e) {
    console.error('DB Ping Error:', e)
    res.status(500).json({ ok: false, error: e.message || String(e) })
  }
})

app.use('/auth', authRoutes)
app.use('/roles', roleRoutes)
app.use('/pemasukkan', pemasukkanRoute)

const PORT = process.env.PORT || 3000
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API running at http://localhost:${PORT}`)
})

