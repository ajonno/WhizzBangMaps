# WhizzBangMaps (Tourist Helper)

IDE: XCode Version 7.3.1 (7D1014)

Swift 2.2

Note: I found the Google endpoint for POI data to be somewhat flakey and occasionally it would not return a payload (could be due to rate limiting). This is handled in the app, but fyi.

Cocoapods was used so please open the workspace file in XCode - WhizzBangMaps.xcworkspace

All pods are included in the repo so you should be able to pull this down and build without needing to 'pod install'.

Tested and ran ok both on sim and on device (iPhone 6). For purpose of this app was just targetted at iPhone.

Note: app wont re-render the shortest path points if for example you change location / have a significant location change whilst the app is running on device. You would need to re-start the app. Would be nice addition tho.

Limited error handling code. Would add additional in prod app. 

Had fun with this, enjoy the map(ping) app!
