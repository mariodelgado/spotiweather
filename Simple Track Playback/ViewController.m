//
//  ViewController.m
//  Empty iOS SDK Project
//
//  Created by Daniel Kennett on 2014-02-19.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

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

@interface ViewController () <SPTAudioStreamingDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *coverViewBG;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *weatherCond;
@property (weak, nonatomic) IBOutlet UILabel *Location;

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;


@property (nonatomic, readwrite) CLLocationCoordinate2D mycord;
@property (nonatomic, readwrite) CLLocationDegrees lat;
@property (nonatomic, readwrite) CLLocationDegrees lon;
@property NSDictionary *result;

@property (nonatomic, strong) KFOpenWeatherMapAPIClient *apiClient;




@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    geocoder = [[CLGeocoder alloc] init];
    
    locationFetchCounter = 0;
               [self blurimage];
    
    // fetching current location start from here
    [locationManager startUpdatingLocation];
    
    
//    [weatherAPI setLangWithPreferedLanguage];
//    [weatherAPI setTemperatureFormat:kOWMTempFahrenheit];
    
//    [weatherAPI currentWeatherByCityName:@"San Francisco" withCallback:^(NSError *error, NSDictionary *result) {
//        
//        
//        if (error) {
//        self.weatherCond.text =@"Error";
//            NSLog(@"Weather: %@",result[@"weather"][0][@"description"]);
//
//            return;
//        }
//        
//        // The data is ready
//
//        
//        self.weatherCond.text = result[@"weather"][0][@"description"];
//        
//      //  result[@"weather"][@"main"];
//
//        
//
//     //   NSString *cityName = result[@"name"];
//       // NSNumber *currentTemp = result[@"main"][@"temp"];
//        
//    }];
//    
//    
//    
//    
//    
//    
//    
    

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // this delegate method is constantly invoked every some miliseconds.
    // we only need to receive the first response, so we skip the others.
    if (locationFetchCounter > 0) return;
    locationFetchCounter++;
    
    // after we have current coordinates, we use this method to fetch the information data of fetched coordinate
    [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
        
        NSString *street = placemark.thoroughfare;
        NSString *city = placemark.locality;
        NSString *posCode = placemark.postalCode;
        NSString *country = placemark.country;
        
        NSLog(@"we live in %@", country);
        
        // stopping locationManager from fetching again
        [locationManager stopUpdatingLocation];
        
        
        
        OWMWeatherAPI *weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"810da70aaecb6564a2d192bdd4bc35e4"];
        
        self.apiClient = [[KFOpenWeatherMapAPIClient alloc] initWithAPIKey:@"810da70aaecb6564a2d192bdd4bc35e4" andAPIVersion:@"2.5"];
        
        
        [self.apiClient weatherForCityName:city withResultBlock:^(BOOL success, id responseData, NSError *error)
         {
             if (success)
             {
                 KFOWMWeatherResponseModel *responseModel = (KFOWMWeatherResponseModel *)responseData;
                 NSLog(@"received weather: %@, conditions: %@", responseModel.cityName, [responseModel valueForKeyPath:@"weather.main"][0]);
                 

                 
                 self.weatherCond.text = [NSString stringWithFormat:@"%@", [responseModel valueForKeyPath:@"weather.main"][0]];
                 
                 
                 
                 self.Location.text = [NSString stringWithFormat:@"%@", responseModel.cityName];
                 


                 
                 
             }
             else
             {
                 NSLog(@"could not get weather: %@", error);
             }
         }];

    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}


#pragma mark - Actions

-(IBAction)rewind:(id)sender {
    [self.player skipPrevious:nil];
}

-(IBAction)playPause:(id)sender {
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
}

-(IBAction)fastForward:(id)sender {
    [self.player skipNext:nil];
}

#pragma mark - Logic




-(void)updateUI {
    if (self.player.currentTrackMetadata == nil) {
        self.titleLabel.text = @"Nothing Playing";
        self.albumLabel.text = @"";
        self.artistLabel.text = @"";
    } else {
        self.titleLabel.text = [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataTrackName];
        self.albumLabel.text = [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataAlbumName];
        self.artistLabel.text = [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataArtistName];
    }
    [self updateCoverArt];
}

-(void)updateCoverArt {
    if (self.player.currentTrackMetadata == nil) {
        self.coverView.image = nil;
        self.coverViewBG.image = nil;

        return;
    }
    
    [self.spinner startAnimating];
    
    [SPTAlbum albumWithURI:[NSURL URLWithString:[self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataAlbumURI]]
                   session:self.session
                  callback:^(NSError *error, SPTAlbum *album) {
                      
        NSURL *imageURL = album.largestCover.imageURL;
        if (imageURL == nil) {
            NSLog(@"Album %@ doesn't have any images!", album);
            self.coverView.image = nil;
            self.coverViewBG.image = nil;

            return;
        }
                      
        // Pop over to a background queue to load the image over the network.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            UIImage *image = nil;
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:0 error:&error];
                          
            if (imageData != nil) {
                image = [UIImage imageWithData:imageData];
            }
                          
            // …and back to the main queue to display the image.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinner stopAnimating];
                 self.coverViewBG.image = image;
                    self.coverView.image = image;
               
                
  

                
                
                    if (image == nil) {
                    NSLog(@"Couldn't load cover image with error: %@", error);
                }
            });
        });
    }];
}



-(void)blurimage{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.layer.opacity = 1;
    
    blurEffectView.frame = CGRectMake(0, 0, self.coverViewBG.frame.size.width+40, self.coverViewBG.frame.size.height+200);
    [self.coverViewBG addSubview:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:CGRectMake(0, 0, 900, 900)];
    [[blurEffectView contentView] addSubview:vibrancyEffectView];


}


-(void)handleNewSession:(SPTSession *)session {

    self.session = session;
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:@kClientId];
        self.player.playbackDelegate = self;
    }

    [self.player loginWithSession:session callback:^(NSError *error) {

		if (error != nil) {
			NSLog(@"*** Enabling playback got error: %@", error);
			return;
		}

		[SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:user:ztpruitt:playlist:0ymZzMHLIapX8dowGmI7ez"]
                         withSession:session
                            callback:^(NSError *error, id object) {

            if (error != nil) {
                NSLog(@"*** Album lookup got error %@", error);
                return;
            }

            [self.player playTrackProvider:(id <SPTTrackProvider>)object callback:nil];

        }];
	}];
}

#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    [self updateUI];
}

@end
