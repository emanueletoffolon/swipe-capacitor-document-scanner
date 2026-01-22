# Changelog

All notable changes to this project will be documented in this file.

## [8.0.0] - 2026-01-22

### 🚀 Migrazione a Capacitor 8

#### Breaking Changes
- **BREAKING:** Richiede Capacitor 8.0.0 o superiore
- **BREAKING:** iOS: richiede Swift 5.9 e iOS 14.0+
- **BREAKING:** Android: richiede Java 21 e Gradle 8.14.3 (minimo), minSdk 23

#### Changed
- Aggiornato Swift version a 5.9 (da 5.1)
- Aggiornato Java compatibility a 21 (da 17)
- Aggiornato Gradle a 8.14.3 (da 8.11.1)
- Aggiunto `skipLibCheck: true` in tsconfig.json per compatibilità
- Configurato Gradle per usare Java 21 automaticamente

#### Added
- Script `build-android.sh` per gestire build Android con Java 21
- Documentazione migrazione in `MIGRATION_TO_V8.md`
- Riepilogo aggiornamento in `UPGRADE_SUMMARY.md`
- Quick start guide in `QUICK_START.md`
- Configurazione automatica Java 21 in `gradle.properties`
- Suppressione warning compileSdk 36

#### Developer Notes
- Se usi questo plugin, assicurati di:
  - Aggiornare la tua app a Capacitor 8
  - Usare Java 21 per le build Android
  - Usare Gradle 8.14.3 o superiore
  - Avere Xcode con Swift 5.9+ per iOS

#### Dependencies
- `@capacitor/android`: ^8.0.0
- `@capacitor/core`: ^8.0.0
- `@capacitor/ios`: ^8.0.0

#### Test Results
- ✅ Build TypeScript: SUCCESS
- ✅ Build Android: SUCCESS (142 tasks in 37s)
- ✅ Gradle 8.14.3 con Java 21.0.10

---

## [7.x.x] and earlier

Per le versioni precedenti, consulta la cronologia Git:
```bash
git log --oneline --decorate
```
