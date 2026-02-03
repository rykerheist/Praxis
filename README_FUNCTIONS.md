# Supabase Edge Functions Setup for Praxis

To enable the "Voice-to-Text" and AI analysis features, you need to deploy the server-side code.

## Prerequisites
1. Install Supabase CLI: `brew install supabase/tap/supabase` (or Windows equivalent).
2. Login: `supabase login`
3. Link your project: `supabase link --project-ref your-project-ref`

## Deploying the Function

1. Navigate to the project root in your terminal.
2. Login to Supabase (if you haven't):
   ```bash
   npx supabase login
   ```
3. Deploy the function:
   ```bash
   npx supabase functions deploy process-session
   ```
4. Set your Secrets (Environment Variables) in the Supabase Dashboard or via CLI:
   ```bash
   npx supabase secrets set GEMINI_API_KEY=your_gemini_api_key
   ```
   *Note: `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are usually available by default, but double check.*

## Database Update
Ensure your `sessions` table has columns for the analysis:
```sql
alter table sessions 
add column transcript text,
add column ai_analysis jsonb;
```

## How it Works
1. Flutter app records audio and uploads to `session_recordings` bucket.
2. Flutter app calls `supabase.functions.invoke('process-session')`.
3. The function creates a `GoogleGenerativeAI` client.
4. It downloads the audio, feeds it to Gemini 1.5 Flash.
5. It gets a JSON response with Transcript, Action Items, and "Core Friction".
6. It saves this back to the `sessions` table in your database.
