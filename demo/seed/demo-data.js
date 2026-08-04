
const demoData = {

users:[
{
email:"admin.demo@xaasgrid.com",
role:"ADMIN"
},
{
email:"operator.demo@xaasgrid.com",
role:"OPERATOR"
}
],


companies:[
{
name:"Demo Enterprise Company"
},
{
name:"Demo Partner Company"
}
],


services:[

{
name:"Infrastructure-as-a-Service"
},

{
name:"Software-as-a-Service"
},

{
name:"Energy-as-a-Service"
},

{
name:"Security-as-a-Service"
}

]

};


console.log(JSON.stringify(demoData,null,2));

