// require("dotenv").config();
// const prisma = require("./config/prismaClient.js");
// const { createSchedule } = require("./controller/scheduleController.js");

// // Kita butuh dummy 'req' dan 'res' karena fungsi aslinya menerima parameter Express
// const dummyReq = {
  
// };
// const dummyRes = {
//   status: (code) => ({
//     json: (data) => console.log(`[${code}]`, data)
//   }),
//   json: (data) => console.log(data)
// };

// (async () => {
//   await createSchedule(dummyReq, dummyRes);
//   await prisma.$disconnect();
// })();


require("dotenv").config();
const prisma = require("./config/prismaClient.js");
const { createPemasukkan } = require("./controller/pemasukkanController.js");

// Dummy request & response agar bisa dipanggil di luar Express
const dummyReq = {
  body: {
    userId: 1,               // 🧩 ubah sesuai user ID yang valid di database kamu
    jumlahPemasukkan: 9000000, // 🧾 nominal pemasukan
    shift: "Malam",           // bisa "Pagi" atau "Sore"
  },
};

const dummyRes = {
  status: (code) => ({
    json: (data) => console.log(`[${code}]`, data),
  }),
  json: (data) => console.log(data),
};

(async () => {
  try {
    await createPemasukkan(dummyReq, dummyRes);
  } catch (err) {
    console.error("Terjadi kesalahan saat menjalankan controller:", err.message);
  } finally {
    await prisma.$disconnect();
  }
})();
