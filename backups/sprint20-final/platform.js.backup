const express = require("express");

const router = express.Router();


router.get("/status", (req, res) => {


    res.json({

        platform: "XaaSGrid",

        status: "operational",

        version: "1.0.0",

        environment:
            process.env.NODE_ENV || "development",

        timestamp: new Date()

    });


});


module.exports = router;
