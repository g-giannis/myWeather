//
//  LocationManager.h
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/10/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "WeatherRequestInterface.h"

@class CLLocation;

typedef void (^LocationManagerCompletionHandler)(id<WeatherRequestInterface>weatherRequestItem, NSError *error);

/** object which handles the GPS location */
@interface LocationManager : NSObject

/** @return the singleton instance */
+ (LocationManager *)sharedInstance;

/** @return the current user's location */
@property (nonatomic, readonly) CLLocation *currentLocation;

/** @return the current authorization status */
@property (nonatomic, readonly) CLAuthorizationStatus authorizationStatus;

/** starts the GPS location updates */
- (void)startUpdatingLocation;

/** stops the GPS location updates */
- (void)stopUpdatingLocation;

/** executes a MKLocalSearchRequest to find the place that the user entered. If the placemark is found then a WeatherRequestItem
 is passed to the completion block.
 @param locationName the location name the user entered
 @param completionHandler the completion block. If successful contains a WeatherRequestItem. If not it contains an NSError object.
 */
- (void)weatherRequestItemForLocationName:(NSString *)locationName
                    withCompletionHandler:(LocationManagerCompletionHandler)completionHandler;

@end
