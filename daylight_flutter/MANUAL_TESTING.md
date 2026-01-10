
# Manual Testing Plan

## 1. Home Widget Extension
**Goal:** Verify that the home screen widget displays the correct time and city for the home timezone.

**Pre-requisites:**
- Build and install the app on a physical device or Simulator (iOS/Android).
- `home_widget` plugin must be implemented and configured.

**Steps:**
1.  **Launch App:** Open the Daylight app.
2.  **Verify Home Timezone:** Ensure "Home" timezone is set (e.g., Chennai). Note the time.
3.  **Background App:** Minimize the app to the home screen.
4.  **Add Widget:** 
    - **iOS:** Long press home screen -> (+) -> Search "Daylight" -> Add Widget.
    - **Android:** Long press home screen -> Widgets -> Daylight -> Drag to screen.
5.  **Verification:**
    - Check if the widget appears.
    - Verify it displays "Chennai" (or your home city).
    - Verify the time matches the app (within update intervals).
6.  **Interactive Test:**
    - Open App -> Change Home Timezone to "London".
    - Update Widget: Tap "Update Widget" button in app (if implemented) or wait for background refresh (usually 15-30 mins).
    - Verify widget updates to "London".

## 2. Dynamic Theme
**Goal:** Verify the app adapts to system theme changes.

**Steps:**
1.  Open App Settings within Daylight.
2.  Set Theme to "System".
3.  Change Device Settings -> Display -> Dark Mode (On/Off).
4.  Verify App UI colors invert appropriately.

