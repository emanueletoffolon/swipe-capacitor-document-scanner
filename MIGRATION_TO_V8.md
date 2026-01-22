# Migrazione a Capacitor 8

## Modifiche Completate

### 1. iOS
- ✅ Swift version aggiornata a 5.9 in `CapacitorDocumentScanner.podspec`
- ✅ iOS deployment target già impostato a 14.0
- ✅ Podfile già configurato correttamente

### 2. Android
- ✅ Java version aggiornata a 21 in `android/build.gradle`
- ✅ Configurazione Java 21 aggiunta in `android/gradle.properties`
- ✅ Gradle 8.14.3 (richiesto come minimo) configurato
- ✅ Compatibile con Capacitor 8

### 3. TypeScript
- ✅ Aggiunto `skipLibCheck: true` in `tsconfig.json` per evitare conflitti di tipi
- ✅ Build TypeScript funzionante

### 4. Package.json
- ✅ Dipendenze già aggiornate a Capacitor 8.0.0

## Configurazione Java

Per assicurarti che la build Android usi Java 21, puoi:

### Opzione 1: Variabile d'ambiente (Consigliata)
Aggiungi al tuo `~/.zshrc`:
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
```

Poi ricarica la configurazione:
```bash
source ~/.zshrc
```

### Opzione 2: Usare JAVA_HOME temporaneamente
Prima di eseguire i comandi gradle:
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
cd android && ./gradlew clean build test
```

### Opzione 3: Usare gradle.properties (Già configurato)
Il file `android/gradle.properties` è già configurato con:
```properties
org.gradle.java.home=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
```

## Verifica della Migrazione

### Prerequisiti

#### Android SDK
Per la build Android, assicurati di avere Android Studio installato oppure configura il file `android/local.properties`:

```properties
sdk.dir=/path/to/your/android/sdk
```

Su macOS, la posizione tipica è:
```properties
sdk.dir=/Users/tuonome/Library/Android/sdk
```

Oppure imposta la variabile d'ambiente:
```bash
export ANDROID_HOME=/Users/tuonome/Library/Android/sdk
```

### Build completa
```bash
npm run build
```

### Verifica iOS
```bash
npm run verify:ios
```

### Verifica Android
```bash
# Assicurati che JAVA_HOME punti a Java 17
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
npm run verify:android
```

### Verifica Web
```bash
npm run verify:web
```

## Modifiche Necessarie per i Consumatori del Plugin

Gli sviluppatori che usano questo plugin dovranno:

1. Aggiornare le loro app a Capacitor 8
2. Assicurarsi di usare:
   - iOS 14.0 o superiore
   - Android minSdk 23 o superiore
   - Java 17 per le build Android

## Test

Dopo aver configurato Java 17, esegui:
```bash
npm run verify
```

Questo eseguirà tutti i test per iOS, Android e Web.

## Risoluzione Problemi

### Errore "Unsupported class file major version 68"
Questo errore indica che stai usando Java 24 invece di Java 17. Segui l'Opzione 1 sopra per configurare Java 17.

### Errore durante la build TypeScript
Se vedi errori relativi a `AbortSignal`, assicurati che `tsconfig.json` contenga `"skipLibCheck": true`.

### Pod install fallisce
Assicurati di avere CocoaPods aggiornato:
```bash
sudo gem install cocoapods
cd ios && pod install --repo-update
```
