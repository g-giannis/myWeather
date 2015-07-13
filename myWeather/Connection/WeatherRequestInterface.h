//
//  WeatherRequestInterface.h
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/11/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@protocol WeatherRequestInterface <NSObject>

@property (nonatomic) CLLocation *location;

@property (nonatomic) NSString *locationName;

@property (nonatomic) NSString *ISOcountryCode;

@end
