//
//  LocationManager.m
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/10/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "WeatherRequestItem.h"

@interface LocationManager () <CLLocationManagerDelegate>
{
   CLLocationManager *locationManager;
}

@end

@implementation LocationManager

- (id)init
{
   self = [super init];
   
   if (self)
   {
      locationManager = [CLLocationManager new];
      locationManager.delegate = self;
   }
   
   return self;
}

#pragma mark - Public Methods

+ (LocationManager *)sharedInstance
{
   static LocationManager *instance = nil;
   static dispatch_once_t predicate;
   
   dispatch_once(&predicate,
   ^{
      instance = [LocationManager new];
   });
   
   return instance;
}

- (CLAuthorizationStatus)authorizationStatus
{
   return [CLLocationManager authorizationStatus];
}

- (void)startUpdatingLocation
{
   CLAuthorizationStatus locationAuthorization = [CLLocationManager authorizationStatus];
   
   if (locationAuthorization == kCLAuthorizationStatusNotDetermined)
   {
      [locationManager requestWhenInUseAuthorization];
   }
   
   locationManager.desiredAccuracy = kCLLocationAccuracyBest;
   [locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
   [locationManager stopUpdatingLocation];
}

- (void)weatherRequestItemForLocationName:(NSString *)locationName
                    withCompletionHandler:(LocationManagerCompletionHandler)completionHandler
{
   MKLocalSearchRequest *localSearchRequest = [MKLocalSearchRequest new];
   localSearchRequest.naturalLanguageQuery = locationName;
   
   MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:localSearchRequest];
   
   [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
   {
      WeatherRequestItem *weatherRequestItem = [WeatherRequestItem new];
      
      if (!error)
      {
         MKMapItem *mapItem = response.mapItems.firstObject;
         NSString *city = mapItem.placemark.locality;
         weatherRequestItem.locationName = city;
         weatherRequestItem.ISOcountryCode = mapItem.placemark.ISOcountryCode;
         
         if (completionHandler != nil)
         {
            dispatch_async(dispatch_get_main_queue(),
            ^{
               completionHandler(weatherRequestItem, nil);
            });
         }
      }
      else
      {
         NSString *failureReasonString = [self messageStringForPlacemarkError:error];
         error = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedFailureReasonErrorKey : failureReasonString}];
         
         if (completionHandler != nil)
         {
            dispatch_async(dispatch_get_main_queue(),
            ^{
               completionHandler(nil, error);
            });
            
         }
      }
   }];
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
   [self checkLocationAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
   // TODO: Handle failures
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
   CLLocation *location = [locations lastObject];
   
   if (location.horizontalAccuracy > 0)
   {
      _currentLocation = location;
   }
}

#pragma mark - Helper Methods

- (void)checkLocationAuthorization
{
   CLAuthorizationStatus locationAuthorization = [CLLocationManager authorizationStatus];
   
   if (locationAuthorization == kCLAuthorizationStatusAuthorizedWhenInUse)
   {
      [locationManager startUpdatingLocation];
   }
   else if (locationAuthorization == kCLAuthorizationStatusDenied)
   {
      // Location permission denied
   }
}

- (NSString *)messageStringForPlacemarkError:(NSError*)placemarkError
{
   NSString *messageString = nil;
   
   switch ([placemarkError code])
   {
      case MKErrorUnknown:
      {
         messageString = @"Unknown error occurred";
         
         break;
      }
      case MKErrorServerFailure:
      {
         messageString = @"The map server was unable to return the desired information";
         
         break;
      }
      case MKErrorLoadingThrottled:
      {
         messageString = @"The data was not loaded because data throttling is in effect";
         
         break;
      }
      case MKErrorPlacemarkNotFound:
      {
         messageString = @"The specified placemark could not be found";
         
         break;
      }
      case MKErrorDirectionsNotFound:
      {
         messageString = @"The specified directions could not be found";
         
         break;
      }
      case NSURLErrorNotConnectedToInternet:
      {
         messageString = @"No internet connection available";
         
         break;
      }
      default:
      {
         messageString = [placemarkError localizedDescription];
         
         break;
      }
   }
   
   return messageString;
}

@end
