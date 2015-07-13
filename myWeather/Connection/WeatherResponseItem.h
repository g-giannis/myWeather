//
//  WeatherResponseItem.h
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/11/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeatherConditionItem;

@interface WeatherResponseItem : NSObject

@property (nonatomic) WeatherConditionItem *currentWeatherConditionItem;

@property (nonatomic) NSArray *hourlyWeatherConditionItems;

@property (nonatomic) NSArray *dailyWeatherConditionItems;

@property (nonatomic) NSError *error;

@end
