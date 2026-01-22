# Installation Instructions for Capacitor 8

## For npm installation

When using npm to install this plugin in your Capacitor project:

```bash
npm install swipe-capacitor-document-scanner@latest
npx cap sync
```

## Important Notes

1. **Pod name**: The CocoaPods pod name is `SwipeCapacitorDocumentScanner` (not with your username)
2. **Podspec file**: The plugin includes `SwipeCapacitorDocumentScanner.podspec` at the root
3. **iOS minimum deployment target**: iOS 16.0
4. **Android**: Java 17 is required, compileSdk 36

## If you get "No podspec found" error

Make sure:
1. You've run `npm install` first
2. You've run `npx cap sync` second
3. Delete the old podspec files if they exist:
   - `CapacitorDocumentScanner.podspec` (DELETE)
   - `EmanueletoffolonSwipeCapacitorDocumentScanner.podspec` (DELETE)

Keep only:
- `SwipeCapacitorDocumentScanner.podspec`

## Using the plugin in your app

After installation, import and use in your code:

```typescript
import { DocumentScanner } from 'swipe-capacitor-document-scanner';

// Scan a document
const result = await DocumentScanner.scanDocument({
  responseType: 'imageFilePath' // or 'base64'
});
```
