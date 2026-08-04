
const API_URL =
process.env.NEXT_PUBLIC_API_URL ||
"http://localhost:4000/api";


export async function getPlatformMetrics(){

const response =
await fetch(
`${API_URL}/platform/metrics`,
{
cache:"no-store"
}
);


if(!response.ok){

throw new Error(
"Unable to retrieve platform metrics"
);

}


return response.json();

}

