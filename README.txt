SimpleWeb - iPad Browser targeting iOS 10

SETUP IN XCODE (on your 2012 iMac):

1. Open Xcode
2. File > New > Project
3. iOS > Application > Single View App > Next
4. Product Name: SimpleWeb
   Team: (leave blank)
   Organization Identifier: com.example
   Language: Swift
   Deployment Target: iOS 10.0
   Use Core Data: unchecked
   Include Tests: unchecked
   Next > Create

5. In the project navigator, delete ViewController.swift (move to trash)

6. Drag all .swift files from the SimpleWeb folder into your Xcode project
   (AppDelegate.swift, BrowserViewController.swift, Tab.swift,
    TabManager.swift, BookmarkManager.swift, BookmarksViewController.swift,
    TabSwitcherViewController.swift)
   Check "Copy items if needed" > Finish

7. Click on the project root in the navigator
   Select the "SimpleWeb" target > General tab
   Under "Deployment Info" set:
     - Devices: iPad
     - Main Interface: (leave blank / clear if it says Main)

8. Open Info.plist in the project
   Delete the "Main storyboard file base name" entry if present

9. Click on the project root > Build Settings tab
   Search for "iOS Deployment Target" and verify it's 10.0

10. At the top, select your iMac's name as the scheme device
    (or "Generic iPad" and build)

11. Product > Archive

12. In the Organizer window, select the archive > Export
    Choose "Development" or "Ad Hoc"
    Check "Rebuild from Bitcode" if needed
    Sign with your Apple ID (free Apple ID works for sideloading)
    Save the IPA file

13. Sideload the IPA to your iPad using:
    - Apple Configurator 2 (macOS)
    - Cydia Impactor
    - AltStore
    - sideloadly

FEATURES:
- WebKit-based rendering (same engine as Safari)
- Tab management (add/switch/close tabs)
- Back/Forward navigation
- Bookmarks (add, view, delete)
- Tab switcher view
- Share button

NOTE:
- First launch shows a blank tab - type a URL in the top bar and press Go
- All websites load via WKWebView, same rendering as Safari
