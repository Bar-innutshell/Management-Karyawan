const express = require("express");
const router = express.Router();

const scheduleController = require("../controller/scheduleController");

router.get("/", scheduleController.showSchedule);

router.post("/generate", scheduleController.createSchedule);

module.exports = router;
