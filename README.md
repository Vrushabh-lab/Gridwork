# Gridwork (standalone)

A dashboarding and data-visualization app, self-hosted on entirely free services:

- **Vercel** — hosts the website and one small serverless function (free)
- **Supabase** — the database, giving you live sync across devices (free)
- **Your own AI API key** — powers the "Ask a question" feature (small per-use cost, not part of hosting)

No credit card is required for Vercel or Supabase's free tiers. Total setup time: about 15 minutes.

---

## 1. Create your database (Supabase)

1. Go to https://supabase.com and sign up (free).
2. Click **New project**. Give it any name, set a database password (save it somewhere), pick the region closest to you.
3. Once it's created, open the **SQL Editor** (left sidebar) → **New query**.
4. Open `supabase-schema.sql` from this folder, copy all of it, paste it into the SQL editor, and click **Run**.
5. Go to **Project Settings → API**. You'll need two values from this page in step 3 below:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon public** key (a long string — this is safe to put in frontend code)

## 2. Get an AI API key (for the "Ask a question" feature)

1. Go to https://console.anthropic.com and sign up.
2. Go to **API Keys** and create a new key. Copy it — you won't be able to see it again.
3. Note: unlike the hosting above, API usage isn't free — it's billed per request, but small "ask a chart" queries cost fractions of a cent each with the model this is configured to use. You can set a spending limit in the console if you want a safety cap.
   - If you'd rather skip this for now, you can deploy everything else and add the AI feature later — the rest of the app works fine without it.

## 3. Add your Supabase keys to the app

1. Open `index.html` in a text editor.
2. Near the top, find:
   ```js
   var SUPABASE_URL = "YOUR_SUPABASE_URL";
   var SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
   ```
3. Replace both placeholder values with what you copied in step 1.5, and save the file.

## 4. Put the code on GitHub

Vercel deploys from a GitHub repository.

1. Go to https://github.com and sign up if you don't have an account.
2. Create a **New repository** (any name, e.g. `gridwork`). Keep it private if you'd like.
3. Upload this whole folder's contents to that repository — either:
   - Drag and drop all the files (including the `api` folder) into GitHub's web uploader ("Add file" → "Upload files"), or
   - If you're comfortable with git: `git init && git add . && git commit -m "init" && git remote add origin <your-repo-url> && git push -u origin main`

## 5. Deploy on Vercel

1. Go to https://vercel.com and sign up using your GitHub account (this makes step 2 automatic).
2. Click **Add New → Project**, and select the repository you just created.
3. Before deploying, open **Environment Variables** and add:
   - Name: `ANTHROPIC_API_KEY`
   - Value: the key you copied in step 2
   (Skip this if you chose to skip the AI feature for now — the app still deploys fine without it.)
4. Click **Deploy**. In under a minute you'll get a live URL like `https://gridwork-yourname.vercel.app` — that's your website, live, shareable, and free.

## 6. Turn on realtime sync (if it isn't already on)

The schema script tries to enable this automatically. To double check:
1. In Supabase, go to **Database → Replication**.
2. Confirm `datasets`, `dashboards`, and `cards` are toggled on under the `supabase_realtime` publication.

---

## Using it day to day

Just open your Vercel URL — bookmark it, add it to your phone's home screen, whatever's convenient. No login screen, no Claude account needed; it's your own website now.

## Known limits (same honest caveats as before)

- Datasets are capped at 20,000 rows per upload (configurable in `index.html` if you need more — search for `MAX_ROWS`).
- No live database connections (Postgres, Snowflake, etc.) — this reads files/pasted data you give it, not external data sources.
- Anyone who has your Vercel URL can read and write your data, since there's no login screen. Fine for a private/internal tool; if you want real per-person access control, add Supabase Auth — ask me and I can wire that in.
- The AI feature calls Claude on each question — usage costs are yours, separate from the free hosting.

## If something breaks

- **"Almost there" banner won't go away** → double check the Supabase URL/key in `index.html` are pasted correctly, with no extra spaces.
- **Charts load but "Ask a question" fails** → check the `ANTHROPIC_API_KEY` environment variable is set in Vercel's project settings, then redeploy (Vercel → Deployments → ⋯ → Redeploy).
- **Changes don't show up on another device** → check Supabase → Database → Replication has the three tables enabled (step 6 above).
