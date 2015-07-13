//
//  WeatherConditionItem.h
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/6/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherConditionItem : NSObject

/** @return the date in 1970 timestamp format */
@property (nonatomic) NSNumber *dateTimestamp;

/** @return the condition text (e.g. "Sky is clear") */
@property (nonatomic) NSString *conditionText;

/** @return the humidity in percentage (e.g. "40 %") */
@property (nonatomic) NSNumber *humidityPercentage;

/** @return the wind speed in km / h */
@property (nonatomic) NSNumber *windSpeed;

/** @return the current temperature degress */
@property (nonatomic) NSNumber *temperature;

/** @return the minimum temperature degress */
@property (nonatomic) NSNumber *minTemperature;

/** @return the maximum temperature degress */
@property (nonatomic) NSNumber *maxTemperature;

/** @return the current weather city location (e.g. "Hamburg") */
@property (nonatomic) NSString *locationName;

/** @return the icon name that represents the current weather conditions */
@property (nonatomic) NSString *iconName;

/** convention method which parses the JSON, initializes and returns a daily weather condition item
 @param json the specified JSON to parse
 @return the daily weather condition item
 */
+ (WeatherConditionItem *)dailyWeatherConditionItemFromJSON:(NSDictionary *)json;

/** convention method which parses the JSON, initializes and returns the current weather condition item
 @param json the specified JSON to parse
 @return the current weather condition item
 */
+ (WeatherConditionItem *)currentWeatherConditionItemFromJSON:(NSDictionary *)json;

@end
