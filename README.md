# Solo Leveling: personal life OS

*(Internally the project and Android package are still called `nizam` / `com.habeeb.nizam`, so updates keep installing over the existing app.)*

A gamified command center for one person: plan the day, track sleep, habits, water, prayer and tasks, and earn XP for all of it. It's an Android app built with Flutter that works fully offline and is installed directly as an APK (no Play Store).

**Status: all four phases are built.**
- **Phase 1:** app shell and design system, Today, Sleep & Wake, Tasks, work profiles, Habits, Water, Salah with offline prayer times, Mood, XP / levels / streaks, Rewards Shop, Quick Capture, reminders, Vivo phone setup.
- **Phase 2:** Money (Quick Log from 6 places, dashboard, budgets), Build Hour, Daily Targets, Focus / Pomodoro and retainer time tracking (CSV / PDF), azan chimes, morning and evening routines, Google sign-in with 2-way Calendar sync and Drive backup.
- **Phase 3:** Notes with templates and voice notes, meeting recorder with Gemini Minutes of Meeting, People (birthdays, follow-ups), Leads with the Google Maps share target, Mail Merge through Gmail.
- **Phase 4:** daily Quests, Weekly Boss, a growing plant, streak shields, full 8-part Life Score, Year in Pixels, badges, Learning tracker, screen-time limits, smart nudges, weekly/monthly reviews and reports, Today and Record-meeting widgets.

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

## 4. Google Calendar and Drive backup (one-time, about 10 minutes)

Nizam works fully offline without this. Do it once to switch on Calendar sync and Drive backups. You can do every step in Chrome on your phone at **console.cloud.google.com**.

1. **Create a project.** Use the project picker → *New project* → name it `Nizam`.
2. **Enable the APIs.** Go to *APIs & Services → Library* and enable **Google Calendar API**, **Google Drive API** and **Gmail API**.
3. **Set up the consent screen.** Go to *APIs & Services → OAuth consent screen* (newer consoles call it *Google Auth Platform*):
   - User type **External**, app name `Nizam`, your email as support and developer contact.
   - Leave it in **Testing**. Under *Test users* / *Audience*, add **your own Gmail address**. Only listed test users can sign in.
4. **Find your signing SHA-1.** Open the latest **Build APK** run in Actions. The run summary shows *Signing certificate fingerprints*; copy the `SHA1:` value. (The *Generate signing key* file also contains it.)
5. **Create an Android client.** Go to *Credentials → Create credentials → OAuth client ID → Android*:
   - Package name: `com.habeeb.nizam`
   - SHA-1: the value from step 4.
6. **Create a Web client.** Do *Create credentials → OAuth client ID → Web application* again (name it `Nizam web`, no URLs needed). Copy its **Client ID**, which ends in `.apps.googleusercontent.com`. Android sign-in needs this Web client ID; nothing else does.
7. **Connect in Nizam.** Go to **Me → Google account & backup → Web client ID**, paste the ID, then tap **Sign in with Google** and allow Calendar and Drive.

What happens next:
- A calendar called **Nizam** appears in your Google Calendar. Every task with a time is mirrored there, and edits flow both ways: the newest change wins.
- Your main calendar's events show on Today and in **Calendar**. You can rename or move them from Nizam.
- Sync runs on app open, a few seconds after any task change, and every 2 hours in the background.
- **Backups** go to Drive's hidden app folder. They run right after **Good Night** and again at **10 AM** as a safety net, and the newest 14 are kept. Restore from the same screen.
- If the 10 AM run can't sign in from the background, you'll get a *Tap to back up* notification instead.

Gmail is asked for separately, with the **Allow Gmail sending** button at the top of **Mail**. Only the *send* permission is requested.

The Gemini key is also pasted **inside the app** (section 7) and stored in Android secure storage. `config/nizam.example.json` shows the shape of these settings. **Real keys are never committed.** `.gitignore` blocks `config/*.json`, `*.jks` and `key.properties`.

## 5. The ₹ Quick Log, everywhere

- **In the app:** tap the gold **₹** button, or **tap empty space 4 times** quickly (Me → Money settings changes the count). Long-press ₹ for Quick Capture.
- **Quick Settings tile:** pull down the shade twice → edit (pencil) → drag **₹ Log money** into your tiles. It opens the popup over whatever app you're in.
- **Home-screen widget:** long-press the home screen → Widgets → **Nizam → Log money**.
- **Floating bubble:** Me → Money settings → *Floating ₹ bubble*. It needs *Display over other apps*. Drag it anywhere, and tap it to log.
- **App shortcut:** long-press the Nizam icon → **Log money**.
- **Natural input:** `250 chai`, `5000 SIP`, `+40000 retainer`, `1.5k uber` and `2L gold` fill in the amount, type and category for you.

## 6. Focus extras

- **Do Not Disturb during Pomodoro:** switch it on in Focus. The first time, Android asks you to allow Nizam under *Do Not Disturb access*.
- **Retainer hours:** start a *Work timer* or add time manually, tagged with a profile. **Time log** totals each profile by week or month and exports **CSV / PDF** to WhatsApp, Gmail, Drive and so on.

## 7. Gemini AI (meeting minutes, voice notes, drafting)

1. In Chrome, open **aistudio.google.com/apikey**, sign in, and tap **Create API key**. The free tier is enough.
2. In the app: **Me → AI (Gemini)** → paste the key → **Save** → **Test**. It should say *ready*.

The key lives only in Android secure storage. Without it, everything else works; only transcription, minutes and *Tidy with AI* are off.

## 8. Meetings, Leads and Mail

- **Record a meeting:** Notes → Meetings → **Record**, the **Record meeting** home-screen widget, or Quick Capture. Allow the microphone the first time. Recording runs as a foreground service (keeps going with the screen off) and saves 10-minute chunks. On Stop, each chunk is transcribed and Minutes of Meeting are generated; if the phone is offline it resumes later. Audio and minutes are copied to Drive under *Solo Leveling/Meetings*. From the minutes, one tap creates tasks, a follow-up reminder and a recap e-mail draft.
- **Leads from Google Maps:** in Maps open a business → **Share** → **Solo Leveling**. Name, address, phone and link are filled in for you. Each lead adds to the *leads* daily target.
- **Mail Merge:** Mail → New campaign → pick a template (`{{name}}`, `{{business|there}}` and so on), import a CSV or choose leads, preview each mail, then send. Mails go out one by one with 25–45 s gaps, up to 300 a day (keeps your Gmail account safe). If the app is closed, the queue continues in the background.

## 9. Game layer, insights and nudges

- **Today → Quests card:** three daily quests, the weekly boss, your plant (it grows with active days and wilts after two idle days) and streak shields. A week with 5+ active days earns a shield (max 3), which covers one missed day automatically.
- **Me:** Review (weekly / monthly), Report, Year in Pixels, Learning, Screen time, Nudges.
- **Screen time:** Me → Screen time → allow *Usage access* for Solo Leveling, then set daily limits per app. Going over triggers a nudge.
- **Nudges:** at most a few a day, never in quiet hours, each type can be turned off in Me → Nudges.
- **Widgets:** long-press home screen → Widgets → **Solo Leveling → Today** (score, XP, streak, next prayer) and **Record meeting**.

---

## How it works

- **Local-first:** SQLite through `drift`. Data leaves the phone only for features you switch on: Google Calendar / Drive / Gmail and Gemini.
- **Time:** every instant is stored in UTC and shown in Asia/Kolkata (configurable).
  - The app's "day" rolls over at **6 AM** (configurable), so a Good Night at 5:45 AM counts for the previous day.
  - Sleep is credited to the day you wake into.
- **Prayer days start at Fajr:** between midnight and Fajr you still see, and can mark, the previous day's Isha.
  - Times are calculated offline with `adhan` for Hyderabad. The default method is Karachi with Hanafi Asr; both can be changed in Me → Settings.
  - Marking a prayer before its window ends counts as **on time** (+5 XP). After that it's **late** (+3). An unmarked prayer turns **missed** once its window passes.
- **XP ledger:** one row per (day, source), so awarding is idempotent and un-ticking takes the XP back.
  - Level L starts at 50·L·(L−1) XP: Rookie → Starter → Builder → Hustler → Operator → Strategist → Architect → Closer → Founder → Legend.
  - Redeeming a reward spends your balance, never your level.
- **Life Score (0–100):** tasks 15, habits 12, daily targets 13, Salah 15, sleep 13, water 10, Build Hour 12, money discipline 10.
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

Each module (Sleep, Tasks, Habits, Water, Salah, Mood, Rewards, Money, Notes, Meetings, People, Leads, Mail, Quests, Learning, Screen time, Nudges…) can be switched off in **Me → Modules**.

### Developing

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after editing lib/core/db/app_db.dart
flutter analyze && flutter test
NIZAM_SHOTS=/tmp/shots flutter test test/widget            # optional: phone-size screenshots
flutter build apk --release
```

CI uses Flutter **3.35.7**. The `drift_schemas/` folder holds a snapshot of each database version; `test/data/migration_test.dart` upgrades real v1 and v2 databases to the latest schema (v3) to prove migrations keep your data. The prayer-time tests check `adhan` against an independent implementation of the solar formulas, to within 2½ minutes.

## Not yet verified on a real phone

CI can't exercise these, so check them after installing: recording with the screen off, Gemini calls, Gmail sending, Google sign-in, home widgets, the Quick Settings tile and bubble, usage stats, and background jobs on Vivo's battery manager.
