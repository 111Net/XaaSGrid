
const users=[
{
 id:1,
 email:"admin@xaasgrid.com",
 password:"admin123",
 role:"admin"
}
];


function login(email,password)
{

const user =
users.find(
u=>u.email===email &&
u.password===password
);

return user;

}


module.exports={login};

