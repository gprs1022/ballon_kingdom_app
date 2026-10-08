# 🚀 Google Play Store Publication & Policy Compliance Guide
**App Name:** Balloon Kingdom  
**Package Name:** `com.gprstech.ballonpop`  
**Current Release Version:** `1.0.0 (Version Code: 1)`  
**Bundle Location:** `build/app/outputs/bundle/release/app-release.aab` (57.0 MB)

---

## 🛡️ Policy & Families Program Compliance Summary

| Google Play Policy | Compliance Status | Implementation Details |
| :--- | :---: | :--- |
| **Families Policy (Kids)** | ✅ **100% Compliant** | Child-directed ads enabled (`MaxAdContentRating.g`, `AgeRestrictedTreatment.child`). |
| **Advertising ID (`AD_ID`)** | ✅ **Stripped** | Manifest removes `AD_ID` and all Privacy Sandbox `AdServices` permissions. |
| **Parental Gate** | ✅ **Active** | `ParentGateDialog` with math challenges protects parent dashboard, coin upgrades, and privacy settings. |
| **In-App Privacy Policy** | ✅ **Active** | In-app Privacy Policy dialog inside the Parent Dashboard with full disclosures. |
| **EEA/UK Consent (GDPR)** | ✅ **Integrated** | UMP SDK integration with user privacy choice options in the dashboard. |
| **Data Safety** | ✅ **Zero Data Collected** | No personal data, location, contacts, or analytics sent off-device. |
| **Target SDK Version** | ✅ **Target 36 (Android 15+)** | Exceeds Google Play requirement (minimum Target SDK 34). |
| **64-bit Architecture** | ✅ **Compliant** | Native binaries built for `arm64-v8a`, `armeabi-v7a`, `x86_64`. |
| **Keystore & Signing** | ✅ **Signed** | Release bundle signed with `upload-keystore.jks` (valid through 2054). |

---

## 📋 Google Play Console Questionnaire Answers

When filling out **App Content** in the Google Play Console:

### 1. Privacy Policy
* **Requirement:** Public URL accessible via browser.
* **Sample URL:** You can host your privacy policy on GitHub Pages, Google Sites, or your website.
* **Suggested Text:** State clearly that Balloon Kingdom collects **NO** personally identifiable information, no location data, and serves only G-rated child-safe ads with zero ad-tracking.

### 2. Ads Declaration
* **Does your app contain ads?** Select **"Yes"**.
* **Families Ads Certification:** When prompted, certify that your ads comply with Families Policy and that you use Google AdMob with child-directed treatment enabled.

### 3. App Access
* **Does your app have restricted parts?** Select **"All functionality is available without special access"**.

### 4. Content Rating (IARC)
* **Category:** Game -> Casual / Educational / Family.
* **Violence, Blood, Sex, Profanity, Drugs:** Select **"No"** to all.
* **Does the app natively allow users to interact or exchange content?** Select **"No"**.
* **Does the app share the user's current physical location?** Select **"No"**.
* **Expected Rating:** **PEGI 3 / ESRB Everyone / USK 0**.

### 5. Target Audience & Content (Families Program)
* **Target Age Groups:** Select **"5 and under"**, **"6-8"**, and **"9-12"**.
* **Appeal to Children:** "Yes, it is designed for children."
* **Families Policy Requirements:** Check the box agreeing to comply with Google Play's Families Policy.

### 6. Data Safety Form
* **Does your app collect or share any user data?** Select **"No"**.
  * No names, emails, user IDs.
  * No financial/payment data.
  * No location data.
  * No photos, audio, or files collected.
  * No device identifiers (Advertising ID is explicitly stripped).
* **Is all user data encrypted in transit?** N/A (No data collected).
* **Account Deletion:** Not applicable (app has no user accounts).

### 7. Financial Features / Government Apps
* **Financial Features:** Select **"My app doesn't provide any financial features"**.
* **Government Apps:** Select **"No"**.

---

## 🔑 Release Keystore & Credentials Reference

* **Keystore Path:** `android/app/upload-keystore.jks`
* **Keystore Type:** PKCS12 (valid until October 2054)
* **Key Alias:** `upload`
* **Keystore Password:** `balloonpop2026`
* **Key Password:** `balloonpop2026`
* **Gradle Configuration:** Pre-configured in `android/key.properties` and `android/app/build.gradle.kts`.

---

## 📲 Switching from AdMob Test IDs to Production IDs

Currently, the app safely runs in **Test Ads Mode** to prevent accidental policy violations or invalid traffic strikes during development.

When you are ready to show your own live ads:
1. Production **Ad Unit IDs** have been configured in [`lib/core/monetization/ad_service.dart`](file:///d:/ballon_kingdom_app/lib/core/monetization/ad_service.dart):
   - **App Open**: `ca-app-pub-9888777523011398/6989976334` (`app_opening_banner`)
   - **Banner**: `ca-app-pub-9888777523011398/1661628036` (`Bottom_Banner`)
   - **Interstitial**: `ca-app-pub-9888777523011398/1598048855` (`Game_Over_Interstitial`)
   - **Rewarded**: `ca-app-pub-9888777523011398/3218603933` (`reward_banner`)
2. Release builds now automatically use these live Ad Unit IDs!
3. Add your **AdMob App ID** (`ca-app-pub-9888777523011398~XXXXXXXXXX`) to `android/gradle.properties`:
   ```properties
   ADMOB_APP_ID=ca-app-pub-9888777523011398~XXXXXXXXXX
   ```

---

## 📤 Ready to Upload File
Your upload bundle is ready at:
📁 **`build\app\outputs\bundle\release\app-release.aab`**

Simply drag and drop this file into **Production** (or **Closed Testing**) in Google Play Console!
