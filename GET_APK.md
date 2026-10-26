# Get the APK (no installs needed)

1. Create a free account at github.com and make a new **private** repository (e.g. "stakebook").
2. Upload these items to the repo root (drag and drop on the web page):
   - the `lib` folder
   - the `.github` folder (it contains workflows/build-apk.yml)
3. Open the repo's **Actions** tab -> **Build APK** -> **Run workflow**.
4. Wait about 5-8 minutes. Open the finished run and download **stakebook-apk** from Artifacts.
5. Unzip it to get `app-release.apk`, send it to your phone (USB, Drive, WhatsApp to yourself).
6. On the phone, open the file and allow "Install from unknown sources" when asked.

Notes:
- The APK is signed with a debug key. It installs fine, but to update later you must
  build from the same repo/key; if an update fails, use Backup in the app first,
  uninstall, install the new APK, then Restore.
- If the build fails, copy the error from the Actions log and send it to me.
