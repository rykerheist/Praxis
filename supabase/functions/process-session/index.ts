// @ts-nocheck
// Phase 6.2: Server-Side Intelligence (The "Brain" of Giles)
// This function is triggered by the Flutter app after a session upload.
// It retrieves the audio, sends it to Gemini 1.5 Flash for transcription & analysis,
// and updates the session database record.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2"; // FIXED: Changed jsr to npm
import { GoogleGenerativeAI } from "npm:@google/generative-ai";
import { Buffer } from "node:buffer"; // FIXED: Added for performance

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 1. Parse Input (Supports audio 'filename' OR raw 'textNotes')
    const { sessionId, filename, textNotes } = await req.json();

    if (!sessionId) {
      throw new Error("Missing sessionId");
    }
    if (!filename && !textNotes) {
      throw new Error("Must provide either 'filename' (audio) or 'textNotes' (raw text)");
    }

    // 2. Initialize Supabase Client (Service Role for full access)
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    console.log(`Processing session: ${sessionId}. Mode: ${filename ? 'Audio' : 'Text'}`);

    // 3. Initialize Gemini (Giles)
    const apiKey = Deno.env.get('GEMINI_API_KEY') ?? '';
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-3.0-flash" });

    // 4. Prepare Prompt
    const basePrompt = `
      You are GILES, an elite Organizational Psychologist and Chief of Staff.
      
      TONE OF VOICE CONSTANTS:
      - Brevity is paramount.
      - If a butler wouldn't say it, do not write it.
      - Never say "Here is a summary" or "I have analyzed". Just present the data.
      - Tone: Professional, detached, ultra-concise, high-competence.

      Your task is to:
      1. ${filename ? 'Provide a verbatim transcript of the key parts.' : 'Refine and structure the provided raw notes into a coherent narrative.'}
      2. Extract 3-5 "Strategic Action Items" - clear, high-level next steps.
      3. Identify the "Core Friction" - the underlying psychological blocker the client is facing.
      
      Format the output as JSON with keys: "transcript", "action_items" (array), "core_friction".
    `;

    let generateContentInput = [];

    // 5. Handle Audio vs Text logic
    if (filename) {
      // --- AUDIO PATH ---
      const { data: fileData, error: downloadError } = await supabase
        .storage
        .from('session_recordings')
        .download(filename);

      if (downloadError) throw downloadError;

      const arrayBuffer = await fileData.arrayBuffer();
      
      // FIXED: Use Buffer (O(N)) instead of reduce (O(N^2)) to prevent crash/timeout on large files
      const base64Audio = Buffer.from(arrayBuffer).toString('base64');

      generateContentInput = [
        basePrompt,
        {
          inlineData: {
            mimeType: "audio/m4a", // Defaulting to m4a/aac for mobile compatibility
            data: base64Audio
          }
        }
      ];
    } else {
      // --- TEXT PATH ---
      const textPrompt = `${basePrompt}\n\nHere are the raw notes from the coach:\n"${textNotes}"`;
      generateContentInput = [textPrompt];
    }

    // 6. Generate Analysis from Gemini
    const result = await model.generateContent(generateContentInput);

    const responseText = result.response.text();
    // Simple cleanup to ensure JSON parsing if the model adds markdown ticks
    const cleanJson = responseText.replace(/```json|```/g, '');
    const analysis = JSON.parse(cleanJson);

    // 6. Update Database
    // Assuming a 'sessions' table exists with an 'analysis' jsonb column
    // If not, we store it in a generic notes field or create a new table.
    // For this prototype, we'll try to update the 'sessions' table.
    
    const { error: updateError } = await supabase
      .from('sessions')
      .update({
        transcript_text: analysis.transcript,
        ai_analysis: analysis,
        status: 'completed'
      })
      .eq('id', sessionId);

    if (updateError) {
      console.error("DB Update Error", updateError);
      // Fallback: Just log it if the schema isn't fully ready
    }

    return new Response(
      JSON.stringify({ success: true, analysis }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error("Error processing session:", error);
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 },
    );
  }
});
