const express = require("express");

const router = express.Router();


router.use(
    "/health",
    require("./health.routes")
);


router.use(
    "/platform",
    require("./platform")
);


router.use(
    "/company",
    require("./company.routes")
);


router.use(
    "/investor",
    require("./investor.routes")
);


router.use(
    "/dashboard",
    require("./dashboard.routes")
);


router.use(
    "/billing",
    require("./billing")
);


router.use(
    "/database",
    require("./database.routes")
);


module.exports = router;
