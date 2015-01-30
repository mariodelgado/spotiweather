//
//  AppDelegate.m
//  Empty iOS SDK Project
//
//  Created by Daniel Kennett on 2014-02-19.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "Config.h"
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "OWMWeatherAPI.h"
#import "KFOpenWeatherMapAPIClient.h"
#import "KFOWMWeatherResponseModel.h"
#import "KFOWMMainWeatherModel.h"
#import "KFOWMWeatherModel.h"
#import "KFOWMForecastResponseModel.h"
#import "KFOWMCityModel.h"
#import "KFOWMDailyForecastResponseModel.h"
#import "KFOWMDailyForecastListModel.h"
#import "KFOWMSearchResponseModel.h"
#import "KFOWMSystemModel.h"
CLLocationManager *locationManager;
CLGeocoder *geocoder;
int locationFetchCounter;


#define kSessionUserDefaultsKey "SpotifySession"

@implementation AppDelegate





-(void)enableAudioPlaybackWithSession:(SPTSession *)session {
    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sessionData forKey:@kSessionUserDefaultsKey];
    [userDefaults synchronize];
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    [viewController handleNewSession:session];
}

- (void)openLoginPage {
    SPTAuth *auth = [SPTAuth defaultInstance];

    NSString *swapUrl = @kTokenSwapServiceURL;
    NSURL *loginURL;
    if (swapUrl == nil || [swapUrl isEqualToString:@""]) {
        // If we don't have a token exchange service, we need to request the token response type.
        loginURL = [auth loginURLForClientId:@kClientId
                         declaredRedirectURL:[NSURL URLWithString:@kCallbackURL]
                                      scopes:@[SPTAuthStreamingScope]
                            withResponseType:@"token"];
    }
    else {
        loginURL = [auth loginURLForClientId:@kClientId
                         declaredRedirectURL:[NSURL URLWithString:@kCallbackURL]
                                      scopes:@[SPTAuthStreamingScope]];

    }
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
        CGRect webFrame = CGRectMake(0.0, 0.0, 320.0, 480);
        UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];
        [webView setBackgroundColor:[UIColor whiteColor]];
        //NSString *urlAddress = loginURL;
        NSURL *url = loginURL;
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [webView loadRequest:requestObj];
        
        UIViewController *viewController1 = [[UIViewController alloc] init];
        viewController1.view = webView;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController1];
        viewController1.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(done:)];
        viewController1.title = @"Login to Spotify";
        
        [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
    });
}

- (void)renewTokenAndEnablePlayback {
    id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:@kSessionUserDefaultsKey];
    SPTSession *session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
    SPTAuth *auth = [SPTAuth defaultInstance];

    [auth renewSession:session withServiceEndpointAtURL:[NSURL URLWithString:@kTokenRefreshServiceURL] callback:^(NSError *error, SPTSession *session) {
        if (error) {
            NSLog(@"*** Error renewing session: %@", error);
            return;
        }
        
        [self enableAudioPlaybackWithSession:session];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:@kSessionUserDefaultsKey];
    SPTSession *session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;

    NSString *refreshUrl = @kTokenRefreshServiceURL;

    if (session) {
        // We have a session stored.
        if ([session isValid]) {
            // It's still valid, enable playback.
            [self enableAudioPlaybackWithSession:session];
        } else {
            // Oh noes, the token has expired.

            // If we're not using a backend token service we need to prompt the user to sign in again here.
            if (refreshUrl == nil || [refreshUrl isEqualToString:@""]) {
                [self openLoginPage];
            } else {
                [self renewTokenAndEnablePlayback];
            }
        }
    } else {
        // We don't have an session, prompt the user to sign in.
        [self openLoginPage];
    }

    return YES;
}

-(void)done:(id)sender{
    
    [self.window.rootViewController dismissViewControllerAnimated: TRUE completion:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).
        
        if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
        }
           [self.window.rootViewController dismissViewControllerAnimated: TRUE completion:nil];
        
        NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
        [[NSUserDefaults standardUserDefaults] setObject:sessionData
                                                  forKey:@kSessionUserDefaultsKey];
        [self enableAudioPlaybackWithSession:session];
        
        [self.window.rootViewController dismissViewControllerAnimated: TRUE completion:nil];
        

        
        
    };
    
    /*
     STEP 2: Handle the callback from the authentication service. -[SPAuth -canHandleURL:withDeclaredRedirectURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */
    
    NSString *swapUrl = @kTokenSwapServiceURL;
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:@kCallbackURL]]) {
        if (swapUrl == nil || [swapUrl isEqualToString:@""]) {
            // If we don't have a token exchange service, we'll just handle the implicit token response directly.
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        } else {
            // If we have a token exchange service, we'll call it and get the token.
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
                                                tokenSwapServiceEndpointAtURL:[NSURL URLWithString:swapUrl]
                                                                     callback:authCallback];
        }
        return YES;
    }
    
    return NO;
}

@end
