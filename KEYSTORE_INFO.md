# Android Keystore & Release Signing Information

This document contains the signing credentials and certificate fingerprints for **Balloon Kingdom** (`com.gprstech.ballonpop`).

> [!CAUTION]
> Keep `upload-keystore.jks` and `key.properties` secure. Never commit them to a public GitHub repository. They are already listed in `.gitignore`.

---

## 1. Keystore Details

| Parameter | Value |
|---|---|
| **File Location** | `android/app/upload-keystore.jks` |
| **Properties File** | `android/key.properties` |
| **Alias** | `upload` |
| **Store Password** | `balloonpop2026` |
| **Key Password** | `balloonpop2026` |
| **Keystore Type** | `PKCS12` (Standard) |
| **Validity** | Until **January 27, 2054** (10,000 days) |
| **Key Algorithm** | `RSA 2048-bit` |
| **Distinguished Name (DName)** | `CN=Balloon Kingdom, OU=GPRS Tech, O=GPRSTech, L=New Delhi, ST=Delhi, C=IN` |

---

## 2. Certificate Fingerprints

Use these fingerprints when configuring **Google Play Console**, **Google Cloud API Console**, **Firebase**, or **Google Sign-In**:

- **SHA1**:
  ```
  0B:4C:46:17:97:A7:FD:92:56:DF:E5:30:CA:D6:EE:4F:93:5C:41:13
  ```

- **SHA256**:
  ```
  B6:0E:2B:18:26:9C:44:7D:4A:6E:91:E0:28:B3:D0:A2:3F:B3:37:A7:93:67:25:4F:D3:D8:01:B9:D4:20:25:E8
  ```

---

## 3. Configuration in `android/key.properties`

```properties
storePassword=balloonpop2026
keyPassword=balloonpop2026
keyAlias=upload
storeFile=upload-keystore.jks
```

---

## 4. Build Commands

### A. Build Release APK
```bash
flutter build apk --release
```
Artifact generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### B. Build Google Play App Bundle (AAB)
```bash
flutter build appbundle --release
```
Artifact generated at:
`build/app/outputs/bundle/release/app-release.aab`
