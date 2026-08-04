
const express = require("express");
const router = express.Router();
const prisma = require("../database/prisma");


router.get("/metrics", async (req,res)=>{

try {

const users =
await prisma.user.count();

const companies =
await prisma.company.count();

const customers =
await prisma.customer.count();


res.json({

users,
companies,
customers,

monthlyRevenue:"₦0",

availability:"100%"

});


}

catch(error){

res.status(500).json({

error:error.message

});

}

});


module.exports = router;

