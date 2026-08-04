
"use client";

import {useEffect,useState} from "react";


export default function Home(){

const [metrics,setMetrics]=useState<any>(null);


useEffect(()=>{

fetch("http://localhost:4000/api/platform/metrics")
.then(r=>r.json())
.then(setMetrics);

},[]);


return (

<main style={{padding:"40px"}}>

<h1>
XaaSGrid Platform
</h1>


<h2>
Everything-as-a-Service Infrastructure Platform
</h2>


<section>

<h3>
Platform Overview
</h3>


<p>
Users: {metrics?.users ?? "..."}
</p>


<p>
Companies: {metrics?.companies ?? "..."}
</p>


<p>
Customers: {metrics?.customers ?? "..."}
</p>


<p>
Monthly Revenue: {metrics?.monthlyRevenue ?? "..."}
</p>


<p>
Availability: {metrics?.availability ?? "..."}
</p>


</section>


</main>

);

}

