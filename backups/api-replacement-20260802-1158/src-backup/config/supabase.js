const { createClient } = require("@supabase/supabase-js");
const ws = require("ws");

let supabase = null;

if (
    process.env.SUPABASE_URL &&
    process.env.SUPABASE_SERVICE_ROLE_KEY
) {
    supabase = createClient(
        process.env.SUPABASE_URL,
        process.env.SUPABASE_SERVICE_ROLE_KEY,
        {
            realtime: {
                transport: ws
            }
        }
    );
}

module.exports = supabase;
