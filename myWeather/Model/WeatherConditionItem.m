//
//  WeatherConditionItem.m
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/6/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import "WeatherConditionItem.h"

#define M_PER_SEC_TO_KM_PER_HOUR(mPerSec) (mPerSec * 18) / 5

@implementation WeatherConditionItem

- (void)setIconName:(NSString *)iconName
{
   NSString *mappedImage = [WeatherConditionItem weatherIconMappings][iconName];
   
   if (!mappedImage)
   {
      mappedImage = iconName;
   }
   
   _iconName = mappedImage;
}

#pragma mark - Public Methods

+ (WeatherConditionItem *)dailyWeatherConditionItemFromJSON:(NSDictionary *)json
{
   WeatherConditionItem *weatherConditionItem = [WeatherConditionItem new];
   weatherConditionItem.dateTimestamp = json[@"dt"];
   weatherConditionItem.humidityPercentage = json[@"humidity"];

   NSNumber *windSpeed = json[@"speed"];
   
   if ([windSpeed floatValue] != 0)
   {
      windSpeed = @(M_PER_SEC_TO_KM_PER_HOUR([windSpeed floatValue])); // Conversion from m / sec -> km / h
   }
   
   weatherConditionItem.windSpeed = windSpeed;
   
   NSDictionary *temperatureDictionary = json[@"temp"];
   
   if (temperatureDictionary != nil)
   {
      weatherConditionItem.temperature = temperatureDictionary[@"day"];
      weatherConditionItem.minTemperature = temperatureDictionary[@"min"];
      weatherConditionItem.maxTemperature = temperatureDictionary[@"max"];
   }
   
   NSDictionary *weatherDictionary = [json[@"weather"] firstObject];
   
   if (weatherDictionary != nil)
   {
      weatherConditionItem.iconName = weatherDictionary[@"icon"];
      weatherConditionItem.conditionText = weatherDictionary[@"description"];
   }
   
   return weatherConditionItem;
}

+ (WeatherConditionItem *)currentWeatherConditionItemFromJSON:(NSDictionary *)json
{
   WeatherConditionItem *weatherConditionItem = [WeatherConditionItem new];
   weatherConditionItem.locationName = json[@"name"];
   weatherConditionItem.dateTimestamp = json[@"dt"];
   NSDictionary *mainItem = json[@"main"];
   
   if (mainItem != nil)
   {
      weatherConditionItem.humidityPercentage = mainItem[@"humidity"];
      weatherConditionItem.temperature = mainItem[@"temp"];
      weatherConditionItem.minTemperature = mainItem[@"temp_min"];
      weatherConditionItem.maxTemperature = mainItem[@"temp_max"];
   }
   
   NSArray *weatherArray = json[@"weather"];
   
   if (weatherArray != nil)
   {
      NSDictionary *weatherDictionary = [weatherArray firstObject];
      weatherConditionItem.iconName = weatherDictionary[@"icon"];
      weatherConditionItem.conditionText = weatherDictionary[@"description"];
   }
   
   return weatherConditionItem;
}

#pragma mark - Helper Methods

+ (NSDictionary *)weatherIconMappings
{
   static NSDictionary *weatherIconMappings = nil;
   
   if (!weatherIconMappings)
   {
      weatherIconMappings = @{@"01d" : @"weather-clear",
                              @"02d" : @"weather-few",
                              @"03d" : @"weather-few",
                              @"04d" : @"weather-broken",
                              @"09d" : @"weather-shower",
                              @"10d" : @"weather-rain",
                              @"11d" : @"weather-tstorm",
                              @"13d" : @"weather-snow",
                              @"50d" : @"weather-mist",
                              @"01n" : @"weather-moon",
                              @"02n" : @"weather-few-night",
                              @"03n" : @"weather-few-night",
                              @"04n" : @"weather-broken",
                              @"09n" : @"weather-shower",
                              @"10n" : @"weather-rain-night",
                              @"11n" : @"weather-tstorm",
                              @"13n" : @"weather-snow",
                              @"50n" : @"weather-mist"};
   }
   
   return weatherIconMappings;
}

@end
