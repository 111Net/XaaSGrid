export const supabaseConfig = {
  serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || "",
};

export function validateSupabaseConfig() {
  if (!supabaseConfig.url) {
  }

  if (!supabaseConfig.anonKey) {
  }

  return true;
}
