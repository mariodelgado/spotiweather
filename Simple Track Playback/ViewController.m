//
//  ViewController.m
//  Empty iOS SDK Project
//
//  Created by Daniel Kennett on 2014-02-19.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "AppDelegate.h"
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
#import <Spotify/Spotify.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <AVFoundation/AVFoundation.h>


CLLocationManager *locationManager;
CLGeocoder *geocoder;
int locationFetchCounter;
int refreshcounter;

@interface ViewController () <SPTAudioStreamingDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *coverViewBG;
@property (weak, nonatomic) IBOutlet UIButton *playPause;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *weatherCond;
@property (weak, nonatomic) IBOutlet UILabel *Location;
@property (weak, nonatomic) IBOutlet UIView *pauseview;
@property (weak, nonatomic) IBOutlet UIView *coverSuperView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *mainblur;
@property (weak, nonatomic) IBOutlet UIView *startBG;
@property (weak, nonatomic) IBOutlet UIImageView *oval1;
@property (weak, nonatomic) IBOutlet UIImageView *oval2;
@property (weak, nonatomic) IBOutlet UIButton *settingsbutton;
@property (weak, nonatomic) IBOutlet UILabel *info1;
@property (weak, nonatomic) IBOutlet UILabel *info2;
@property (weak, nonatomic) IBOutlet UILabel *info3;

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, weak) NSString *condi;


@property (nonatomic, readwrite) CLLocationCoordinate2D mycord;
@property (nonatomic, readwrite) CLLocationDegrees lat;
@property (nonatomic, readwrite) CLLocationDegrees lon;
@property NSDictionary *result;

@property (nonatomic, strong) KFOpenWeatherMapAPIClient *apiClient;

@property NSString *uppercaseString;
@property NSString *uppercaseString1;



@property (assign, nonatomic) CGPoint offset;
    @property CGPoint translation;
@property CGFloat lastScale;
@property CGFloat lastRotation;
@property CGSize size1;

@property (weak,nonatomic) IBOutlet NSLayoutConstraint *coverYConstraint;

@end

@implementation ViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set itself as the first responder
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Resign as first responder
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playPause: nil];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self rewind: nil];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self fastForward: nil];
                break;
                
            default:
                break;
        }
    }
}



-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.layer.opacity = 0;
    self.artistLabel.layer.opacity = 0;
    self.coverView.layer.opacity = 0;
    self.info1.alpha =0;
    self.info2.alpha =0;
    self.info3.alpha =0;
    

    [self startupscreen];

    
    
    refreshcounter = 0;


    
    self.pauseview.bounds = self.coverView.bounds;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
    

    [self.coverSuperView addGestureRecognizer:panGestureRecognizer];
    

    
    
    
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
    [self setNeedsStatusBarAppearanceUpdate];

}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)startupscreen{
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.info1.alpha =0;
        self.info2.alpha =0;
        self.info3.alpha =0;
    } completion:^(BOOL finished) {
        nil;
    }];

    
  [UIView animateWithDuration:5.0 delay:0.3 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.oval2.transform = CGAffineTransformMakeRotation(2000);
      self.oval1.transform = CGAffineTransformMakeRotation(290);
  } completion:nil];
    [UIView animateWithDuration:1.3 delay:1.0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.oval2.transform = CGAffineTransformMakeScale(10, 10);
    } completion:nil];
    [UIView animateWithDuration:0.9 delay:1.3 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        self.oval1.transform = CGAffineTransformMakeScale(10, 10);
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:1.7 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.startBG.alpha =0;
    } completion:^(BOOL finished) {
        self.coverView.layer.opacity = 1;

    }];
    
    
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    geocoder = [[CLGeocoder alloc] init];
    
    locationFetchCounter = 0;
    [self blurimage];
    
    // fetching current location start from here
    [locationManager startUpdatingLocation];
    
    
    
}

-(void)startupscreenunwind{
    self.settingsbutton.enabled = YES;

    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.info1.alpha =0;
        self.info2.alpha =0;
        self.info3.alpha =0;
    } completion:^(BOOL finished) {
        nil;
    }];
    
    

    [UIView animateWithDuration:1.3 delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.oval2.transform = CGAffineTransformMakeScale(10, 10);
    } completion:nil];
    [UIView animateWithDuration:0.9 delay:0.2 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        self.oval1.transform = CGAffineTransformMakeScale(10, 10);
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.6 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.startBG.alpha =0;
        self.coverView.layer.opacity = 1;

    } completion:^(BOOL finished) {
        nil;
    }];
    
    
    

    
}


- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint point = [panGestureRecognizer locationInView:self.coverViewBG];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.coverSuperView];
    CGPoint point1 = [panGestureRecognizer locationInView:self.coverSuperView];
    CGPoint translation = [panGestureRecognizer translationInView:self.coverSuperView];
    CGFloat yvalue = self.coverYConstraint.constant;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %@", NSStringFromCGPoint(point));

    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
 
        
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.coverYConstraint.constant = self.coverViewBG.frame.origin.y-translation.y;
            
        } completion:^(BOOL finished) {
    }];

        NSLog(@"y value: %f", yvalue);
        
        if (self.coverYConstraint.constant < 10) {
            self.coverYConstraint.constant -= self.coverYConstraint.constant-(self.coverYConstraint.constant/20);
        }

        
        NSLog(@"Gesture changed: %@", NSStringFromCGPoint(point));
    }

else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (self.coverYConstraint.constant > 100)
        {
            self.coverYConstraint.constant = self.coverViewBG.frame.size.height/1.5;

            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.view layoutIfNeeded];
                self.coverSuperView.layer.opacity = 0;
                self.coverSuperView.transform = CGAffineTransformMakeScale(1.25, 1.25);
            } completion:^(BOOL finished) {
                [self resetcover];
                [self fastForward:nil];


            }];

        } else{
            self.coverYConstraint.constant = 10;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.view layoutIfNeeded];
                self.pauseview.layer.opacity = 0;

                
            } completion:^(BOOL finished) {
                
            }];
        }
        

        
        NSLog(@"Gesture ended: %@", NSStringFromCGPoint(point));
    }
}

-(void)resetcover{
    self.coverYConstraint.constant = 10;
    [self.view layoutIfNeeded];
self.coverSuperView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:0.4 delay:.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.coverSuperView.layer.opacity = 1;
        
    } completion:^(BOOL finished) {
        
    }];
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
                 

                 

                 
                 NSString *loc2 = [NSString stringWithFormat:@"%@", [responseModel valueForKeyPath:@"weather.main"][0]];
                 NSString *upper2 = [loc2 uppercaseString];
                 
                self.weatherCond.text= upper2;
                 
                 
                 NSString *loc1 = [NSString stringWithFormat:@"%@", responseModel.cityName];
                 NSString *upper1 = [loc1 uppercaseString];
                 self.Location.text = upper1;
                 NSLog(@"It's %@", upper1);

                 
        
                 
                 if ([self.weatherCond.text isEqualToString:@"CLOUDS"]) {
                     NSLog(@"It's Cloudy");
                     
                     
                     [SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:user:1276694298:playlist:7kKvk0X4SRYBP5J87tfXG4"]
                                      withSession:self.session
                                         callback:^(NSError *error, id object) {
                                             
                                             if (error != nil) {
                                                 NSLog(@"*** Album lookup got error %@", error);
                                                 return;
                                             }
                                             
                                             [self.player playTrackProvider:(id <SPTTrackProvider>)object  callback:^(NSError *error) {
                                                 self.player.shuffle = YES;
                                                 self.player.repeat = YES;
                                                 [self.player setIsPlaying:YES callback:nil];
                                             }];
                                             
                                         }];
                     
                     
                     [UIView animateWithDuration:.4 delay:.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                         self.titleLabel.layer.opacity = 1;
                         self.artistLabel.layer.opacity = 1;
                         self.coverView.layer.opacity = 1;
                         self.coverViewBG.layer.opacity = 1;
                     } completion:^(BOOL finished) {
                         nil;
                     }];

                    
                 }else{
                     
                     
                     [UIView animateWithDuration:.4 delay:.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                         self.titleLabel.layer.opacity = 1;
                         self.artistLabel.layer.opacity = 1;
                         self.coverView.layer.opacity = 1;
                         self.coverViewBG.layer.opacity = 1;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
                     
                     
                     NSLog(@"It's Nice out");

                     [SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:user:spotify:playlist:0i0KOEPUK7pA1A5A29ulk4"]
                                      withSession:self.session
                                         callback:^(NSError *error, id object) {
                                             
                                             if (error != nil) {
                                                 NSLog(@"*** Album lookup got error %@", error);
                                                 return;
                                             }
                                             
                                             [self.player playTrackProvider:(id <SPTTrackProvider>)object  callback:^(NSError *error) {
                                                 self.player.shuffle = YES;
                                                 self.player.repeat = YES;
                                                 [self.player setIsPlaying:YES callback:nil];
                                             }];

                                         }];


                 
                 }
             }
             else
             {
                 NSLog(@"could not get weather: %@", error);
                 

             }
         }];
        if (self.coverView == nil){
            [self performSelector:@selector(updateUI) withObject:nil afterDelay:10];}
        else{
        [self performSelector:@selector(updateUI) withObject:nil afterDelay:1];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
    [SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:user:spotify_france:playlist:3fo3sq7WExOXk1St5ajqya"]
                     withSession:self.session
                        callback:^(NSError *error, id object) {
                            
                            if (error != nil) {
                                NSLog(@"*** Album lookup got error %@", error);
                                return;
                            }
                            
                            [self.player playTrackProvider:(id <SPTTrackProvider>)object callback:nil];
                            
                        }];
}


#pragma mark - Actions

-(IBAction)rewind:(id)sender {
    [self.player skipPrevious:nil];
    if (self.playPause.selected == YES) {
        self.playPause.selected = !self.playPause.selected;
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.pauseview.layer.opacity = 0;
            
        } completion:^(BOOL finished) {
            nil;
        }];
        
    }else{
        nil;
        
        
    }
    
}
- (IBAction)pauseout:(id)sender {
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.pauseview.layer.opacity = 0;
        
    } completion:^(BOOL finished) {
        nil;
    }];

}
- (IBAction)pausedown:(id)sender {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pauseview.layer.opacity = 0.1;
        
    } completion:^(BOOL finished) {
        nil;
    }];

}

-(IBAction)playPause:(id)sender {
    
    if (self.info1.alpha == 1){
        [self startupscreenunwind];
    } else{
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
        self.playPause.selected = !self.playPause.selected;

    if (self.coverView.image == nil) {
        self.coverView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.3];
        self.pauseview.layer.opacity = 0;
        NSLog(@"play/pause");

        [[[UIApplication sharedApplication] delegate] performSelector:@selector(openLoginPage)];
    }
    else{
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
            self.pauseview.layer.opacity = 0;
            self.coverView.backgroundColor = [UIColor clearColor];
            
            
        } completion:^(BOOL finished) {
            nil;
        }];
        
        if (self.playPause.selected == YES) {
            [UIView animateWithDuration:3.0
                                  delay:0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat |UIViewAnimationOptionCurveEaseInOut animations:^{
                                      self.pauseview.layer.opacity = 0.4;
                                      NSLog(@"play/pause");


                                  } completion:^(BOOL finished) {
                                      nil;
                                  }];
        }else{
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.pauseview.layer.opacity = 0;
                NSLog(@"play/pause");

            } completion:^(BOOL finished) {
                nil;
            }];
            

        }
    }
    }
}

-(IBAction)fastForward:(id)sender {


    
    [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.coverViewBG.layer.opacity = 0;
        self.pauseview.layer.opacity = 0;

    } completion:^(BOOL finished) {
        [self.player skipNext:nil];

        [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.coverViewBG.layer.opacity = 1;
            
        } completion:^(BOOL finished) {
            [self updateCoverArt];
        }];
        

    }];
    
    if (self.playPause.selected == YES) {
        self.playPause.selected = !self.playPause.selected;

        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.pauseview.layer.opacity = 0;
            
        } completion:^(BOOL finished) {
            [self updateCoverArt];
        }];
        
        

    }else{
        nil;
        
        
    }
    

}

#pragma mark - Logic




-(void)updateUI {
    if (self.player.currentTrackMetadata == nil) {
        self.titleLabel.text = @"Nothing Playing";
        self.albumLabel.text = @"";
        self.artistLabel.text = @"";
    } else {
        

        NSString *strDay = [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataTrackName];
        self.uppercaseString = [strDay uppercaseString];
        self.titleLabel.text =
        self.uppercaseString;

        
        NSString *strDay1 = [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataArtistName];
        self.uppercaseString1 = [strDay1 uppercaseString];
        self.artistLabel.text =
        self.uppercaseString1;

        self.albumLabel.text = [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataAlbumName];
       // self.artistLabel.text = [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataArtistName];
        
        
    }
    
 

    
    

    
    
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
                
                [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    
                    self.coverViewBG.image = image;
                    self.coverView.image = image;
                } completion:^(BOOL finished) {
                    nil;
                }];

               
                Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
                
                
                MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]
                                                initWithImage:self.coverView.image];
                
                if (playingInfoCenter) {
                    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
                    NSDictionary *songInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                              self.uppercaseString, MPMediaItemPropertyArtist,
                                              self.uppercaseString1, MPMediaItemPropertyTitle,
                                              @"Some Album", MPMediaItemPropertyAlbumTitle,
                                              albumArt, MPMediaItemPropertyArtwork,
                                              nil];
                    center.nowPlayingInfo = songInfo;
                    
                }

  

                
                
                    if (image == nil) {
                    NSLog(@"Couldn't load cover image with error: %@", error);
                }
            });
        });
    }];
    

        
    [self updateUI];
}



-(void)blurimage{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
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
    
   [self resetLocation:nil];
    
    
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
        
        [SPTRequest requestItemAtURI:[NSURL URLWithString:@""]
                         withSession:session
                            callback:^(NSError *error, id object) {
                                
                                if (error != nil) {
                                    NSLog(@"*** Album lookup got error %@", error);
                                    return;
                                }
                                
                                // [self.player playTrackProvider:(id <SPTTrackProvider>)object callback:nil];
                                [self.player playTrackProvider:(id <SPTTrackProvider>)object  callback:^(NSError *error) {
                                    self.player.shuffle = YES;
                                    self.player.repeat = YES;
                                    [self.player setIsPlaying:YES callback:nil];
                                }];
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
    [self updateCoverArt];

}
- (IBAction)resetLocation:(id)sender {
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.titleLabel.layer.opacity = 0;
        self.artistLabel.layer.opacity = 0;
        self.coverView.layer.opacity = 0;
        self.coverViewBG.layer.opacity = 0;
    } completion:^(BOOL finished) {
        nil;
    }];
    
    locationFetchCounter = 0;

    self.weatherCond.text= @"Searching";
    self.Location.text= @"Acquiring Location";

    
    // fetching current location start from here
    [locationManager startUpdatingLocation];
    [self updateCoverArt];

    
    
}
- (IBAction)settingstoggle:(id)sender {
    self.settingsbutton.enabled = NO;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.oval2.transform = CGAffineTransformMakeRotation(-2000);
        self.oval1.transform = CGAffineTransformMakeRotation(-290);
        self.startBG.alpha =1;
        self.coverView.alpha = 0;

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.oval2.transform = CGAffineTransformMakeScale(1, 1);
            self.oval1.transform = CGAffineTransformMakeScale(1, 1);

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.info1.alpha =1;
                self.info2.alpha =1;
                self.info3.alpha =1;
                
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1.5 delay:0.9 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse |UIViewAnimationOptionRepeat animations:^{
                    self.oval2.transform = CGAffineTransformMakeScale(1.04, 1.04);

                    
                    
                } completion:^(BOOL finished) {
                    nil;
                }];
            }];
        }];
    }];

    
}
@end
