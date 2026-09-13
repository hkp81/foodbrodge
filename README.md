# FoodBridge

FoodBridge is a static GitHub Pages app backed by Supabase. Listings and authentication are server-backed; no user data is stored in `localStorage`.

## Supabase setup

1. Create a Supabase project and copy its **Project URL** and ** anon/public key**.
2. In Supabase SQL Editor, run [`supabase/schema.sql`](supabase/schema.sql).
3. In Authentication → URL Configuration, add the deployed GitHub Pages URL to **Site URL** and **Redirect URLs**.
4. For local development, copy `config.example.js` to `config.js` and fill in the URL and anon key. `config.js` is ignored by git.
5. In the repository’s Settings → Secrets and variables → Actions, add secrets named `SUPABASE_URL` and `SUPABASE_ANON_KEY`. The anon key is safe for browser use; never add a service-role key.
6. Push to `main` (or run the Pages workflow manually). The workflow creates an untracked `config.js` in the Pages artifact from those secrets.

If runtime configuration is missing or Supabase cannot be reached, the app shows an explicit setup/error message and uses read-only sample listings; it never pretends that local demo authentication succeeded.
