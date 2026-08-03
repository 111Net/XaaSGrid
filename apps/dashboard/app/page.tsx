"use client";

import { useEffect, useState } from "react";


export default function Home() {

const [status,setStatus] = useState("Checking API...");


useEffect(()=>{

const api =
process.env.NEXT_PUBLIC_API_URL;


fetch(`${api}/api/health`)
.then(res=>res.json())
.then(data=>{

setStatus(
`${data.service}: ${data.status}`
);

})
.catch(()=>{

setStatus("API unavailable");

});


},[]);


return (

<div className="min-h-screen bg-slate-100 p-10">

<div className="max-w-5xl mx-auto">

<h1 className="text-4xl font-bold">
XaaSGrid Platform
</h1>


<p className="mt-3 text-gray-600">
Everything-as-a-Service Infrastructure Platform
</p>


<div className="mt-10 bg-white rounded-xl shadow p-8">

<h2 className="text-xl font-semibold">
Platform Health
</h2>


<p className="mt-4">
{status}
</p>


</div>


<div className="grid grid-cols-3 gap-6 mt-8">

<div className="bg-white p-6 rounded-xl shadow">
<h3 className="font-bold">
Operations
</h3>
<p>Monitoring foundation</p>
</div>


<div className="bg-white p-6 rounded-xl shadow">
<h3 className="font-bold">
Analytics
</h3>
<p>Business intelligence</p>
</div>


<div className="bg-white p-6 rounded-xl shadow">
<h3 className="font-bold">
Security
</h3>
<p>Security framework</p>
</div>


</div>

</div>

</div>

);

}
