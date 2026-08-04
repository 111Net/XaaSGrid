
import { getPlatformMetrics } from "../lib/api";


export default async function Home(){


const metrics =
await getPlatformMetrics();



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
Users: {metrics.users}
</p>


<p>
Companies: {metrics.companies}
</p>


<p>
Customers: {metrics.customers}
</p>


<p>
Audit Events: {metrics.auditEvents}
</p>


<p>
Availability: {metrics.availability}
</p>


</section>


</main>

);


}

