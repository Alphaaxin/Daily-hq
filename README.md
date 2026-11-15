# Nizam: personal life OS

A gamified command center for one person: plan the day, track sleep, habits, water, prayer and tasks, and earn XP for all of it. It's an Android app built with Flutter that works fully offline and is installed directly as an APK (no Play Store).

**Status: Phase 1 is done.** It includes the app shell and design system, the Today dashboard, Sleep & Wake, local Tasks, work profiles, Habits, Water, Salah with offline prayer times, Mood, XP, levels and streaks, the Rewards Shop, Quick Capture, local notifications and the Vivo phone setup.

---

## 1. Get the APK onto your phone (no laptop needed)

Every push to `main` (or to a `claude/**` branch) builds the app on GitHub.

1. On your phone, open the repo on github.com and go to **Actions → Build APK**. Open the latest green run.
2. Under **Artifacts**, download **`nizam-apk-arm64-…`**. It's the right build for the Vivo X200 Pro. The `universal` APK works on any phone but is bigger.
3. GitHub delivers a `.zip`. Open it in the Files app and tap `nizam-arm64-v8a.apk`.
4. If Android asks, allow **Install unknown apps** for your browser or Files app.
5. Open Nizam. The first screen walks you through the phone settings in section 3.

> Artifacts download only when you're signed in to GitHub. They're kept for 30 days.

## 2. One-time: a permanent signing key (so updates keep your data)

Android only installs a new APK over the old one when both are signed with the same key. Without this step each build gets a throwaway key, and you'd have to uninstall, losing your data, before every update.

1. Go to **Actions → Generate signing key (run once) → Run workflow**.
2. When it finishes, download the artifact `nizam-signing-secrets-DELETE-AFTER-USE` and open the `.txt` inside.
3. Go to **Settings → Secrets and variables → Actions → New repository secret** and add four secrets, copying each name and value from the file:
   - `NIZAM_KEYSTORE_B64`
   - `NIZAM_STORE_PASSWORD`
   - `NIZAM_KEY_PASSWORD`
   - `NIZAM_KEY_ALIAS`
4. Keep a private copy of the file somewhere safe, such as a password manager. Then **delete the artifact and that workflow run**.
5. Re-run **Build APK**. The warning "Debug-signed APK" should be gone.
6. If you installed a debug-signed build before adding the key, uninstall it once, then install the new signed APK. From then on, updates install over the top.

## 3. Vivo / OriginOS settings (so reminders always fire)

Vivo's battery manager kills background apps aggressively. The in-app **Phone setup** (also under **Me → Run phone setup**) opens each screen for you:

| Setting | Where |
|---|---|
| Notifications | Tap **Allow** in Phone setup |
| Alarms & reminders (exact alarms) | Tap **Allow**, then switch on Nizam |
| Battery optimisation | Tap **Open** and choose *Allow / Don't optimise*. Then also go to **Settings → Battery → Background power consumption management → Nizam → Allow high background power consumption** |
| Autostart | Tap **Open** to reach **i Manager → App manager → Autostart → Nizam**. If it doesn't open: **Settings → Apps → Autostart** |
| Lock in recents | Open recent apps, pull Nizam's card **down** to lock it (a padlock appears) |
| Display over other apps | Tap **Allow** (used in Phase 2 for the ₹ popup and bubble) |

If reminders ever stop, re-run Phone setup. OS updates sometimes reset these switches.

## 4. Google Cloud and Gemini (needed from Phase 2)

Phase 1 needs no accounts or keys. These steps get filled in when Phase 2 adds Google Sign-In:

- a Google Cloud project;
- an OAuth consent screen in *testing* mode with only your account;
- the Calendar, Gmail and Drive APIs enabled;
- an Android OAuth client using the SHA-1 of your signing key;
- a Gemini API key, which you paste **inside the app** so it's stored in Android secure storage.

`config/nizam.example.json` shows the shape of these settings. **Real keys are never committed.** `.gitignore` blocks `config/*.json`, `*.jks` and `key.properties`.

---

## How it works

- **Local-first:** SQLite through `drift`. Nothing leaves the phone in Phase 1.
- **Time:** every instant is stored in UTC and shown in Asia/Kolkata (configurable).
  - The app's "day" rolls over at **6 AM** (configurable), so a Good Night at 5:45 AM counts for the previous day.
  - Sleep is credited to the day you wake into.
- **Prayer days start at Fajr:** between midnight and Fajr you still see, and can mark, the previous day's Isha.
  - Times are calculated offline with `adhan` for Hyderabad. The default method is Karachi with Hanafi Asr; both can be changed in Me → Settings.
  - Marking a prayer before its window ends counts as **on time** (+5 XP). After that it's **late** (+3). An unmarked prayer turns **missed** once its window passes.
- **XP ledger:** one row per (day, source), so awarding is idempotent and un-ticking takes the XP back.
  - Level L starts at 50·L·(L−1) XP: Rookie → Starter → Builder → Hustler → Operator → Strategist → Architect → Closer → Founder → Legend.
  - Redeeming a reward spends your balance, never your level.
- **Life Score v1 (0–100):** tasks 25, habits 20, Salah 20, sleep 20, water 15.
  - Modules you switch off, and an empty task list, drop out and the remaining weights are rescaled.
- **Reminders:** exact alarms via `flutter_local_notifications`, re-planned whenever state changes.
  - Water: every 90 min after your last glass while you're awake; stops at the goal, at Good Night and during quiet hours.
  - Tasks: at the due time, with a *Mark done* button.
  - Bedtime: a nudge when your average sleep is under target.

### Layout

```
lib/
  app/              router, shell (tabs + gold ₹ button), app root
  core/             db (drift), time (DayClock), theme, notifications, settings, providers
  features/<module>/
    domain/         pure Dart rules (unit-tested)
    data/           drift repository + Riverpod providers
    ui/             widgets
test/
  domain/           day rollover, XP/levels, streaks, Life Score, sleep, prayer times, recurrence, water
  data/             repositories on an in-memory database
  widget/           screens render with seeded data
```

Each module (Sleep, Tasks, Habits, Water, Salah, Mood, Rewards) can be switched off in **Me → Modules**.

### Developing

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after editing lib/core/db/app_db.dart
flutter analyze && flutter test
NIZAM_SHOTS=/tmp/shots flutter test test/widget            # optional: phone-size screenshots
flutter build apk --release
```

CI uses Flutter **3.35.7**. The prayer-time tests check `adhan` against an independent implementation of the solar formulas, to within 2½ minutes.

## Roadmap

- **Phase 2:**
  - Money: Quick Log, its entry points (Quick Settings tile, bubble, widget, 4-tap) and the dashboard.
  - Google Sign-In, Calendar 2-way sync and Drive backup.
  - Build Hour, Daily Targets, Focus mode and retainer time tracking.
  - Azan notifications and routines.
- **Phase 3:**
  - Notes with templates and voice capture.
  - Meeting recorder that produces Minutes of Meeting with Gemini.
  - People & Leads, including the Maps share target.
  - Mail Merge via Gmail.
- **Phase 4:**
  - Quests, Weekly Boss, avatar/plant, streak shields, full Life Score and Year in Pixels.
  - Learning tracker, screen time and smart nudges.
  - Reports and the remaining widgets.
