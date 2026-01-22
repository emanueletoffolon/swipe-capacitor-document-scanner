#!/bin/bash

# Script per eseguire la build Android con Java 21
# Uso: ./build-android.sh [gradle-args]

# Imposta JAVA_HOME a Java 21
export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home

# Verifica che Java 21 sia disponibile
if [ ! -d "$JAVA_HOME" ]; then
    echo "❌ Errore: Java 21 non trovato in $JAVA_HOME"
    echo "Installalo con: brew install openjdk@21"
    exit 1
fi

echo "✅ Usando Java 21: $JAVA_HOME"
$JAVA_HOME/bin/java -version

# Controlla se ANDROID_HOME è impostato
if [ -z "$ANDROID_HOME" ]; then
    # Prova a trovare Android SDK in posizioni comuni
    if [ -d "$HOME/Library/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
        echo "✅ Android SDK trovato: $ANDROID_HOME"
    elif [ -d "$HOME/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Android/sdk"
        echo "✅ Android SDK trovato: $ANDROID_HOME"
    else
        echo "⚠️  ANDROID_HOME non impostato. La build potrebbe fallire se l'SDK non è configurato."
        echo "   Imposta ANDROID_HOME o crea android/local.properties con sdk.dir=/path/to/sdk"
    fi
fi

# Vai nella cartella android
cd android

# Esegui gradle con gli argomenti passati o con build di default
if [ $# -eq 0 ]; then
    echo "📦 Eseguendo: ./gradlew clean build test"
    ./gradlew clean build test
else
    echo "📦 Eseguendo: ./gradlew $@"
    ./gradlew "$@"
fi

# Mostra il risultato
if [ $? -eq 0 ]; then
    echo "✅ Build Android completata con successo!"
else
    echo "❌ Build Android fallita!"
    exit 1
fi
