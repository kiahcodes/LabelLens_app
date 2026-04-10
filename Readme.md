# LabelLens — AI-Powered Ingredient Safety Scanner

> **Your personal AI health guardian. Know what's in everything.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.111-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Groq](https://img.shields.io/badge/Groq-LLaMA_70B-F55036)](https://groq.com)
[![Supabase](https://img.shields.io/badge/Supabase-Free_Tier-3ECF8E?logo=supabase)](https://supabase.com)

---

## What is LabelLens?

LabelLens is a **production-grade, AI-powered mobile app** that scans food and cosmetic product labels and delivers instant, personalized ingredient safety analysis. Users simply point their camera at an ingredient list — the app extracts the text, sends it through an AI pipeline, and returns a full safety verdict in seconds.

**The problem:** Millions of people cannot understand the ingredients on product labels. Chemical names are obscure. Harmful preservatives are disguised under aliases. Regulatory status varies by country. And none of this is personalized to your specific health situation.

**The solution:** LabelLens turns every label into plain-language health intelligence — personalized for pregnancy, baby mode, and specific allergies — with regulatory data from India (FSSAI), USA (FDA), EU (EFSA), and WHO.

---

## Key Features

| Feature | Description |
|---|---|
| **OCR Scanning** | On-device text recognition via Google ML Kit |
| **AI Safety Analysis** | Every ingredient analyzed by LLaMA 3.3 70B via Groq |
| **Personalization** | Pregnancy mode, baby mode, allergy detection |
| **Disguised Ingredients** | Detects MSG hidden as "Autolyzed Yeast Extract" etc |
| **Global Regulations** | FSSAI, FDA, EFSA, WHO status per ingredient |
| **Safer Alternatives** | Real products from Open Food Facts database |
| **Voice Chatbot** | Ask questions about any scanned product |
| **TTS / STT** | Read results aloud, speak questions |
| **Hindi Translation** | Hindi support via MyMemory API |
| **Label Honesty Score** | Detects misleading claims on packaging |
| **Sustainability** | Carbon footprint, recyclability, vegan/cruelty-free |
| **Community Stats** | See what products others are scanning |

---

## Tech Stack 

| Layer | Technology | Cost |
|---|---|---|
| Mobile frontend | Flutter (Dart) | 
| On-device OCR | Google ML Kit Text Recognition|
| AI/LLM | Groq API — LLaMA 3.3 70B Versatile |
| Backend | Python + FastAPI |
| Database + Auth | Supabase (Postgres + Auth + Storage) |
| Backend hosting | Render.com |
| Product data | Open Food Facts API |
| Translation | MyMemory API |
| TTS | flutter_tts (on-device) |
| STT | speech_to_text (on-device) |
| State management | Riverpod |
| HTTP client | Dio |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App (Mobile)                     │
│  Camera → ML Kit OCR → Confirm → Loading → Analysis Screen  │
│         │  Dio HTTP Client  │  Supabase SDK  │
└─────────────────────────┬───────────────────┬───────────────┘
                          │                   │
              POST /scan  │                   │ Direct DB reads
                          ▼                   ▼
              ┌───────────────────┐   ┌───────────────┐
              │   FastAPI Backend  │   │   Supabase     │
              │   (Render.com)     │   │   (Postgres)   │
              │                   │   │                │
              │  1. Groq LLaMA    │   │  profiles      │
              │  2. Personalize   │   │  scan_history  │
              │  3. Open Food     │   │  community_stats│
              │     Facts         │   │  notifications │
              │  4. Save to DB    │   └───────────────┘
              └───────────────────┘
                          │
              ┌───────────┴──────────┐
              │                      │
         ┌────▼────┐          ┌──────▼──────┐
         │  Groq   │          │  MyMemory   │
         │  API    │          │  Translation│
         └─────────┘          └─────────────┘
```

---

## Project Structure

```
labellens/
├── flutter/                    # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   ├── app.dart            # MaterialApp + routing
│   │   ├── core/
│   │   │   ├── theme/          # AppTheme, AppColors, AppShadows
│   │   │   ├── constants/      # Demo data, config
│   │   │   └── routing/        # GoRouter setup
│   │   ├── features/
│   │   │   ├── splash/         # Intro/landing screen
│   │   │   ├── auth/           # Login, signup, Google OAuth
│   │   │   ├── onboarding/     # 6-screen personalization flow
│   │   │   ├── dashboard/      # Home screen with scan history
│   │   │   ├── scan/           # Camera, OCR confirm, loading
│   │   │   ├── analysis/       # 4-tab results screen
│   │   │   ├── chatbot/        # AI chatbot with voice
│   │   │   ├── profile/        # User profile editor
│   │   │   └── notifications/  # Notification center
│   │   ├── models/             # ScanResult, Ingredient, etc.
│   │   └── services/           # ApiService, TtsService, SttService
│   └── android/
│       └── app/src/main/
│           └── AndroidManifest.xml
│
└── backend/                    # FastAPI Python backend
    ├── app/
    │   ├── main.py             # FastAPI app + CORS
    │   ├── config.py           # Pydantic settings
    │   ├── routers/
    │   │   ├── scan.py         # POST /scan (main pipeline)
    │   │   ├── chatbot.py      # POST /chatbot
    │   │   └── history.py      # GET /scan-history, /quota-status
    │   ├── services/
    │   │   ├── gemini_service.py      # Groq LLaMA integration
    │   │   ├── personalization.py     # Rule-based safety overrides
    │   │   ├── openfoodfacts.py       # Alternatives fetching
    │   │   ├── translate_service.py   # MyMemory translation
    │   │   └── community_service.py   # Community stats
    │   ├── prompts/
    │   │   └── scan_prompt.py  # Full LLM system prompt
    │   └── utils/
    │       ├── json_parser.py  # Safe JSON parsing with fallbacks
    │       └── hash_utils.py   # Product deduplication
    └── requirements.txt
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x ([install guide](https://flutter.dev/docs/get-started/install))
- Python 3.11 ([download](https://python.org/downloads/release/python-3119))
- Git
- A real Android device (recommended) or emulator

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/labellens.git
cd labellens
```

### 2. Backend setup

```bash
cd backend

# Create virtual environment with Python 3.11
python3.11 -m venv .venv
source .venv/bin/activate          # Linux/Mac
# .venv\Scripts\activate           # Windows

# Install dependencies
pip install -r requirements.txt

# Create environment file
cp .env.example .env
```

Edit `.env` with your credentials:

```env
GROQ_API_KEY=your_groq_key_here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

Start the backend:

```bash
uvicorn app.main:app --reload --port 8000
```

Visit `http://localhost:8000/health` — you should see `{"status":"ok"}`.

### 3. Flutter setup

```bash
cd flutter

# Install dependencies
flutter pub get

# Update Supabase credentials in lib/main.dart
# Replace YOUR_SUPABASE_URL and YOUR_ANON_KEY

# Run on connected device
flutter run
```

### 4. Supabase setup

1. Create a free project at [supabase.com](https://supabase.com)
2. Open **SQL Editor** and run the full migration:

```sql
-- profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  age INTEGER,
  gender TEXT,
  is_pregnant BOOLEAN DEFAULT false,
  is_breastfeeding BOOLEAN DEFAULT false,
  baby_mode BOOLEAN DEFAULT false,
  allergies TEXT[] DEFAULT '{}',
  skin_type TEXT,
  dietary_restrictions TEXT[] DEFAULT '{}',
  preferred_language TEXT DEFAULT 'en',
  theme_preference TEXT DEFAULT 'system',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- scan_history table
CREATE TABLE IF NOT EXISTS public.scan_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_name TEXT,
  brand TEXT,
  product_type TEXT,
  raw_ocr_text TEXT,
  gemini_response JSONB,
  overall_safety_score INTEGER,
  verdict TEXT,
  label_honesty_score INTEGER,
  sustainability_score INTEGER,
  scanned_at TIMESTAMPTZ DEFAULT now()
);

-- community_stats table
CREATE TABLE IF NOT EXISTS public.community_stats (
  product_hash TEXT PRIMARY KEY,
  product_name TEXT,
  brand TEXT,
  scan_count INTEGER DEFAULT 1,
  avg_safety_score FLOAT,
  verdict TEXT,
  last_updated TIMESTAMPTZ DEFAULT now()
);

-- notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT,
  body TEXT,
  type TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scan_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users manage own profile" ON public.profiles
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users view own scans" ON public.scan_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role inserts scans" ON public.scan_history
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users manage own notifications" ON public.notifications
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Anyone reads community stats" ON public.community_stats
  FOR SELECT TO authenticated USING (true);
```

3. Enable **Google OAuth**: Authentication → Providers → Google → Enable
4. Enable **Realtime** on `scan_history`: Database → Replication → toggle `scan_history`

### 5. Get a Groq API key

1. Go to [console.groq.com](https://console.groq.com)
2. Sign up for free
3. Create an API key
4. Add it to your `.env` file

Free tier includes sufficient quota for development and hackathon demos.

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Health check |
| `POST` | `/scan` | Full ingredient analysis pipeline |
| `POST` | `/chatbot` | AI chatbot about a scanned product |
| `GET` | `/scan-history/{user_id}` | Past scans for a user |
| `GET` | `/scan/{scan_id}` | Full result for a specific scan |
| `GET` | `/quota-status` | Today's Groq API usage |

### POST /scan — request body

```json
{
  "ocr_text": "Ingredients: Sugar, Salt, TBHQ, Artificial Color Red 40",
  "product_type": "food",
  "user_profile": {
    "allergies": ["Dairy"],
    "is_pregnant": false,
    "baby_mode": true,
    "dietary_restrictions": [],
    "preferred_language": "en"
  },
  "user_id": "uuid-here"
}
```

### POST /scan — response (abbreviated)

```json
{
  "scan_id": "uuid",
  "product_name": "Chocolate Snack",
  "verdict": "RED",
  "overall_safety_score": 25,
  "ingredients": [
    {
      "canonical_name": "Tertiary Butylhydroquinone",
      "safety_label": "RED",
      "pregnancy_risk": true,
      "baby_risk": true,
      "regulation_IN": "Permitted max 0.02% (FSSAI)",
      "regulation_EU": "Banned by EFSA",
      "health_impact": "May cause oxidative stress..."
    }
  ],
  "personalized_risks": ["TBHQ may not be safe for infants."],
  "alternatives": [...],
  "summary": "...",
  "chatbot_context": "..."
}
```

---

## AI Pipeline

Every scan goes through 5 steps:

```
OCR Text
    │
    ▼
1. Groq LLaMA 3.3 70B
   └─ Extracts all ingredients
   └─ Classifies RED / YELLOW / GREEN
   └─ Detects disguised names (e.g. MSG → Autolyzed Yeast Extract)
   └─ Returns regulatory status per region
   └─ Classifies product category for alternatives
    │
    ▼
2. Personalization Engine (Python, rule-based)
   └─ If pregnant + pregnancy_risk → force RED
   └─ If baby_mode + baby_risk → force RED
   └─ If allergen matches user list → force RED
   └─ Recalculates overall score
    │
    ▼
3. Open Food Facts API
   └─ Fetches safer alternatives in same category
   └─ Filters to only higher-scoring products
    │
    ▼
4. MyMemory Translation (if Hindi selected)
   └─ Translates summary and chatbot responses
    │
    ▼
5. Saved to Supabase
   └─ scan_history row inserted
   └─ community_stats updated
```

---

## Personalization Safety Overrides

The personalization engine enforces these rules **deterministically**, regardless of what the AI returns:

```python
KNOWN_PREGNANCY_RISKS = {
    'retinol', 'caffeine', 'saccharin', 'tbhq',
    'aspartame', 'bha', 'bht', 'red 40', 'yellow 5',
    'yellow 6', 'sodium nitrite', 'sodium nitrate', ...
}

KNOWN_BABY_RISKS = {
    'saccharin', 'tbhq', 'caffeine', 'aspartame',
    'sodium benzoate', 'red 40', 'yellow 5', 'msg', ...
}
```

If any ingredient name matches these lists, its `safety_label` is forced to `RED` before the final score is calculated. This ensures the app never misses a known dangerous ingredient, even if the AI fails to flag it.

---

## Demo Products (Hackathon)

| Verdict | Product | Why it works |
|---|---|---|
| 🔴 RED | Kurkure / Lays | TBHQ, artificial colors, high sodium |
| 🟡 YELLOW | Maggi Noodles | MSG (hidden), high sodium, flavor enhancers |
| 🟢 GREEN | Tata Iodized Salt | Single ingredient, no preservatives |

**Demo mode** is built into the app. Tap the **Demo** button on the dashboard to load pre-cached scan results instantly.

---

## Deployment

### Backend (Render.com)

1. Push code to GitHub
2. Go to [render.com](https://render.com) → New Web Service → connect repo
3. Settings:
   - Runtime: Python
   - Build command: `pip install -r requirements.txt`
   - Start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. Add environment variables (GROQ_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
5. Deploy

**Keep Render warm:** Set up a free monitor at [uptimerobot.com](https://uptimerobot.com) to ping your health endpoint every 5 minutes. This prevents the 60-second cold start on the free tier.

### Flutter (Android APK)

```bash
cd flutter
flutter build apk --release
# APK at: build/app/outputs/flutter-apk/app-release.apk

# Install directly to connected device:
flutter install --release
```

---

## Environment Variables

### Backend `.env`

```env
GROQ_API_KEY=gsk_...
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
```

### Flutter `lib/main.dart`

```dart
await Supabase.initialize(
  url: 'https://your-project.supabase.co',
  anonKey: 'eyJhbGci...',
);
```
---

## Acknowledgements

- [Groq](https://groq.com) — fastest LLM inference available, free tier generous enough for prototyping
- [Open Food Facts](https://world.openfoodfacts.org) — the world's largest open food database
- [Supabase](https://supabase.com) — Firebase alternative with a genuinely useful free tier
- [MyMemory](https://mymemory.translated.net) — free translation API, no signup required
- [Flutter](https://flutter.dev) — single codebase, native performance
- [Render](https://render.com) — the only free hosting that actually works for FastAPI

---

