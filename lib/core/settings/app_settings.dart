import 'dart:convert';

import '../db/app_db.dart';

/// Every module that can be switched off in Me → Modules.
enum Module { sleep, tasks, habits, water, salah, mood, rewards, money, focus, targets, routines }

extension ModuleLabel on Module {
  String get label => const [
    'Sleep & Wake',
    'Tasks',
    'Habits',
    'Water',
    'Salah',
    'Mood',
    'Rewards',
    'Money',
    'Build Hour & Focus',
    'Daily targets',
    'Routines',
  ][index];
}

class AppSettings {
  const AppSettings({
    this.name = 'Habeeb',
    this.timezone = 'Asia/Kolkata',
    this.rolloverHour = 6,
    this.waterGoal = 8,
    this.waterIntervalMin = 90,
    this.waterReminders = true,
    this.sleepTargetHours = 7.0,
    this.bedtimeNudge = true,
    this.taskReminders = true,
    this.prayerMethod = 'karachi',
    this.hanafiAsr = true,
    this.latitude = 17.3850,
    this.longitude = 78.4867,
    this.quietStart = 6,
    this.quietEnd = 11,
    this.onboarded = false,
    this.autostartConfirmed = false,
    this.sleepPromptDismissed = '',
    this.disabled = const {},
    this.monthlyBudgetPaise = 2000000,
    this.quickLogTaps = 4,
    this.bubble = false,
    this.azan = true,
    this.azanOff = const [],
    this.azanBefore = false,
    this.pomoWork = 25,
    this.pomoBreak = 5,
    this.focusDnd = false,
    this.eyeBreaks = true,
    this.eveningHour = 21,
    this.googleWebClientId = '',
    this.googleEmail = '',
    this.lastBackupUtc = '',
    this.nizamCalendarId = '',
    this.backupAfterGoodNight = true,
  });

  final String name;
  final String timezone;
  final int rolloverHour;
  final int waterGoal;
  final int waterIntervalMin;
  final bool waterReminders;
  final double sleepTargetHours;
  final bool bedtimeNudge;
  final bool taskReminders;
  final String prayerMethod;
  final bool hanafiAsr;
  final double latitude;
  final double longitude;

  /// Quiet hours (local), may wrap past midnight. Default suits sleeping ~6 → 11.
  final int quietStart;
  final int quietEnd;
  final bool onboarded;
  final bool autostartConfirmed;
  final String sleepPromptDismissed;
  final Set<Module> disabled;

  // Phase 2
  final int monthlyBudgetPaise;
  final int quickLogTaps;
  final bool bubble;
  final bool azan;
  final List<String> azanOff;
  final bool azanBefore;
  final int pomoWork;
  final int pomoBreak;
  final bool focusDnd;
  final bool eyeBreaks;
  final int eveningHour;
  final String googleWebClientId;
  final String googleEmail;
  final String lastBackupUtc;
  final String nizamCalendarId;
  final bool backupAfterGoodNight;

  bool on(Module m) => !disabled.contains(m);

  Map<String, Object?> toMap() => {
    'name': name,
    'timezone': timezone,
    'rolloverHour': rolloverHour,
    'waterGoal': waterGoal,
    'waterIntervalMin': waterIntervalMin,
    'waterReminders': waterReminders,
    'sleepTargetHours': sleepTargetHours,
    'bedtimeNudge': bedtimeNudge,
    'taskReminders': taskReminders,
    'prayerMethod': prayerMethod,
    'hanafiAsr': hanafiAsr,
    'latitude': latitude,
    'longitude': longitude,
    'quietStart': quietStart,
    'quietEnd': quietEnd,
    'onboarded': onboarded,
    'autostartConfirmed': autostartConfirmed,
    'sleepPromptDismissed': sleepPromptDismissed,
    'disabled': disabled.map((m) => m.name).toList(),
    'monthlyBudgetPaise': monthlyBudgetPaise,
    'quickLogTaps': quickLogTaps,
    'bubble': bubble,
    'azan': azan,
    'azanOff': azanOff,
    'azanBefore': azanBefore,
    'pomoWork': pomoWork,
    'pomoBreak': pomoBreak,
    'focusDnd': focusDnd,
    'eyeBreaks': eyeBreaks,
    'eveningHour': eveningHour,
    'googleWebClientId': googleWebClientId,
    'googleEmail': googleEmail,
    'lastBackupUtc': lastBackupUtc,
    'nizamCalendarId': nizamCalendarId,
    'backupAfterGoodNight': backupAfterGoodNight,
  };

  static AppSettings fromMap(Map<String, Object?> m) {
    const d = AppSettings();
    T v<T>(String k, T def) {
      final x = m[k];
      if (x is T) return x;
      if (def is double && x is num) return x.toDouble() as T;
      if (def is int && x is num) return x.toInt() as T;
      return def;
    }

    final dis = (m['disabled'] is List ? m['disabled'] as List : const [])
        .map((e) => Module.values.where((x) => x.name == e))
        .expand((e) => e)
        .toSet();
    return AppSettings(
      name: v('name', d.name),
      timezone: v('timezone', d.timezone),
      rolloverHour: v('rolloverHour', d.rolloverHour),
      waterGoal: v('waterGoal', d.waterGoal),
      waterIntervalMin: v('waterIntervalMin', d.waterIntervalMin),
      waterReminders: v('waterReminders', d.waterReminders),
      sleepTargetHours: v('sleepTargetHours', d.sleepTargetHours),
      bedtimeNudge: v('bedtimeNudge', d.bedtimeNudge),
      taskReminders: v('taskReminders', d.taskReminders),
      prayerMethod: v('prayerMethod', d.prayerMethod),
      hanafiAsr: v('hanafiAsr', d.hanafiAsr),
      latitude: v('latitude', d.latitude),
      longitude: v('longitude', d.longitude),
      quietStart: v('quietStart', d.quietStart),
      quietEnd: v('quietEnd', d.quietEnd),
      onboarded: v('onboarded', d.onboarded),
      autostartConfirmed: v('autostartConfirmed', d.autostartConfirmed),
      sleepPromptDismissed: v('sleepPromptDismissed', d.sleepPromptDismissed),
      disabled: dis,
      monthlyBudgetPaise: v('monthlyBudgetPaise', d.monthlyBudgetPaise),
      quickLogTaps: v('quickLogTaps', d.quickLogTaps),
      bubble: v('bubble', d.bubble),
      azan: v('azan', d.azan),
      azanOff: (m['azanOff'] is List ? (m['azanOff'] as List).whereType<String>().toList() : const <String>[]),
      azanBefore: v('azanBefore', d.azanBefore),
      pomoWork: v('pomoWork', d.pomoWork),
      pomoBreak: v('pomoBreak', d.pomoBreak),
      focusDnd: v('focusDnd', d.focusDnd),
      eyeBreaks: v('eyeBreaks', d.eyeBreaks),
      eveningHour: v('eveningHour', d.eveningHour),
      googleWebClientId: v('googleWebClientId', d.googleWebClientId),
      googleEmail: v('googleEmail', d.googleEmail),
      lastBackupUtc: v('lastBackupUtc', d.lastBackupUtc),
      nizamCalendarId: v('nizamCalendarId', d.nizamCalendarId),
      backupAfterGoodNight: v('backupAfterGoodNight', d.backupAfterGoodNight),
    );
  }
}

class SettingsRepo {
  SettingsRepo(this.db);
  final AppDb db;

  Stream<AppSettings> watch() => db.select(db.settings).watch().map(_fold);

  Future<AppSettings> load() async => _fold(await db.select(db.settings).get());

  AppSettings _fold(List<Setting> rows) {
    final m = <String, Object?>{};
    for (final r in rows) {
      try {
        m[r.key] = jsonDecode(r.value);
      } catch (_) {}
    }
    return AppSettings.fromMap(m);
  }

  Future<void> set(String key, Object? value) =>
      db.into(db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: jsonEncode(value)));

  Future<void> setModule(AppSettings s, Module m, bool enabled) {
    final d = {...s.disabled};
    enabled ? d.remove(m) : d.add(m);
    return set('disabled', d.map((e) => e.name).toList());
  }
}
