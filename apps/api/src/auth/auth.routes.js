
const express=require("express");
const router=express.Router();

const {login}=require("./auth.service");
const {generateToken}=require("./jwt.service");


router.post("/login",(req,res)=>{

const user=login(
req.body.email,
req.body.password
);


if(!user)
{
return res.status(401).json({
message:"Invalid credentials"
});
}


const token=generateToken(user);


res.json({
token,
user:{
email:user.email,
role:user.role
}
});


});


module.exports=router;

