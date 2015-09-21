# ios-nanodegree-OnTheMap
Udacity iOS Developer Nanodegree - Project 3

Welcome to my Udacity IOS Nanodegree Project #3 page!

# Features:
- Login using Udacity API or Facebook
- View Student Locations on a map or as a list
- Share your location and media url
- Update your location
- View a list of the distance of student locations to Udacity HQ

# Some Extra Features:
- Batched download requests (Loads all the locations)
- Extra tab: Distance to Udacity HQ List (sorted from furthest to closest)
- Can use current location

# Some Installation Instructions:
1. Download or clone repository
2. You must install the FacebookSDK. Follow instructions:
- Download Facebook SDK here: https://developers.facebook.com/resources/facebook-ios-sdk-current.pkg
- Install the package.
- Open ~/Documents/FacebookSDK
- Drag the FBSDKCoreKit.framework & FBSDKLoginKit.framework to the Project Navigator.

# Some Usage Instructions:
1. Press the Placemark Icon to post a location
2. Press the Refresh Icon to refresh data (only on map view and student location view). 
3. Press the Logout Icon (top left) to logout.
4. Distance Tab View is disabled until ALL data is loaded. 
5. On Posting View, tap the Globe icon to find a location
6. On Posting View, tap the Location icon to find current location 
7. On Posting View, tap the Safari Browser Icon to open custom browser to browse for url.
8. On Posting View, once URL and location have been selected, tap the Checkmark icon to post location. 
9. On Student Locations Table View, tap a row to open the student’s URL
10. On Distance Table View, tap a row to zoom into that student’s location

# Notes
1. I decided to call the location struct OTMStudentLocation. I use another strut, called OTMStudentInformation, to store data about the user. 

