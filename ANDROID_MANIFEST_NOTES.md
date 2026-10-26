# Android Auto Backup

In `android/app/src/main/AndroidManifest.xml`, make sure the `<application>` tag has:

```xml
<application
    android:label="Stakebook"
    android:allowBackup="true"
    ...>
```

shared_preferences stores data in `shared_prefs/FlutterSharedPreferences.xml`,
which Auto Backup includes by default (up to 25 MB), so no extra rules file is needed.
Auto Backup only restores on a new device / reinstall with the same Google account;
the manual JSON backup covers everything else.
