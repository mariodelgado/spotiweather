//
//  Config.h
//  Simple Track Playback
//
//  Created by Per-Olov Jernberg on 2014-11-18.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#ifndef Simple_Track_Playback_Config_h
#define Simple_Track_Playback_Config_h

#warning Please update these values to match the settings for your own application as these example values could change at any time.
// For an in-depth auth demo, see the "Basic Auth" demo project supplied with the SDK.
// Don't forget to add your callback URL's prefix to the URL Types section in the target's Info pane!

#define kClientId "85b185ca13574b9c9471b1156987b336"
#define kCallbackURL "spotifyiossdkexample://"

#define kTokenSwapServiceURL "https://whispering-beyond-6523.herokuapp.com/swap"
// or "http://localhost:1234/swap" with example token swap service

// If you don't provide a token swap service url the login will use implicit grant tokens, which https://peaceful-sierra-1249.herokuapp.com/swap

// means that your user will need to sign in again every time the token expires.

#define kTokenRefreshServiceURL "https://whispering-beyond-6523.herokuapp.com/refresh"
// or "http://localhost:1234/refresh" with example token refresh service

// If you don't provide a token refresh service url, the user will need to sign in again every https://peaceful-sierra-1249.herokuapp.com/refresh
// time their token expires.


#endif
