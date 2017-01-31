//
//  ConnectionManager.m
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/6/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import "ConnectionManager.h"
#import <CoreLocation/CoreLocation.h>
#import "WeatherConditionItem.h"
#import "NSString+Extensions.h"
#import "WeatherResponseItem.h"

#define API_KEY @"41ec9da41ac6f354ddbc5658e7fdeb90"

@interface ConnectionManager ()
{
   NSURLSession *urlSession;
   
   WeatherConditionItem *currentWeatherConditionItem;
   NSArray *hourlyWeatherConditionItems;
   NSArray *dailyWeatherConditionItems;
}

@property (nonatomic, strong) ConnectionCompletionHandler completionHandlerBlock;

@end

@implementation ConnectionManager

#pragma mark - Public Methods

- (void)fetchWeatherConditionsForRequestItem:(id<WeatherRequestInterface>)requestItem
                           completionHandler:(ConnectionCompletionHandler)completionHandler
{
   if (!_completionHandlerBlock)
   {
      _completionHandlerBlock = completionHandler;
   }

   if (!urlSession)
   {
      NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
      urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
   }

   CLLocation *location;
   NSString *locationName;
   
   if ([requestItem respondsToSelector:@selector(location)])
   {
      location = [requestItem location];
   }
   
   if ([requestItem respondsToSelector:@selector(locationName)])
   {
      locationName = [requestItem locationName];
   }
   
   NSString *currentURLString;
   NSString *hourlyURLString;
   NSString *dailyURLString;
   
   if (locationName != nil)
   {
      NSString *countryCode;

      if ([requestItem respondsToSelector:@selector(ISOcountryCode)])
      {
         if (!requestItem.ISOcountryCode.isEmpty)
         {
            countryCode = [requestItem ISOcountryCode];
         }
      }
      
      if (!countryCode)
      {
         countryCode = @"";
      }
      else
      {
         countryCode = [NSString stringWithFormat:@",%@", countryCode];
      }
      
      NSString *currentURL = @"http://api.openweathermap.org/data/2.5/weather?q=%@%@&APPID=%@&units=metric";
      currentURLString = [NSString stringWithFormat:currentURL, locationName, countryCode, API_KEY];
     
      NSString *hourlyURL = @"http://api.openweathermap.org/data/2.5/forecast?q=%@%@&APPID=%@&units=metric&cnt=10";
      
      hourlyURLString = [NSString stringWithFormat:hourlyURL, locationName, countryCode, API_KEY];
      
      NSString *dailyURL = @"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@%@&APPID=%@&units=metric&cnt=6";
      dailyURLString = [NSString stringWithFormat:dailyURL, locationName, countryCode, API_KEY];
   }
   else if (location != nil)
   {
      NSString *currentURL = @"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&APPID=%@&units=metric";
      currentURLString = [NSString stringWithFormat:currentURL, location.coordinate.latitude, location.coordinate.longitude, API_KEY];
     
      NSString *hourlyURL = @"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&APPID=%@&units=metric&cnt=10";
      hourlyURLString = [NSString stringWithFormat:hourlyURL, location.coordinate.latitude, location.coordinate.longitude, API_KEY];
      
      NSString *dailyURL = @"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&APPID=%@&units=metric&cnt=6";
      dailyURLString = [NSString stringWithFormat:dailyURL, location.coordinate.latitude, location.coordinate.longitude, API_KEY];
   }
   
   [self fetchDataFromURLString:currentURLString weatherType:WeatherTypeCurrentConditions];
   [self fetchDataFromURLString:hourlyURLString weatherType:WeatherTypeHourlyConditions];
   [self fetchDataFromURLString:dailyURLString weatherType:WeatherTypeDailyConditions];
}

#pragma mark - Helper Methods

- (void)fetchDataFromURLString:(NSString *)urlString weatherType:(WeatherType)weatherType
{
   __weak ConnectionManager *weakSelf = self;

   if (urlString != nil)
   {
      NSURL *url = [NSURL URLWithString:urlString];
      NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
         if (!error)
         {
            NSError *jsonError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];

            NSNumber *code = json[@"cod"];

            NSError *error;
            
            if ([code integerValue] != 200)
            {
               NSString *message = json[@"message"];
               error = [NSError errorWithDomain:@"Domain" code:[code integerValue] userInfo:@{NSLocalizedFailureReasonErrorKey : message}];
            }
            
            if (weatherType == WeatherTypeCurrentConditions)
            {
               currentWeatherConditionItem = [WeatherConditionItem currentWeatherConditionItemFromJSON:json];
            }
            if (weatherType == WeatherTypeHourlyConditions)
            {
               hourlyWeatherConditionItems = [self hourlyWeatherConditionsFromJSON:json];
            }
            else if (weatherType == WeatherTypeDailyConditions)
            {
               dailyWeatherConditionItems = [self dailyWeatherConditionsFromJSON:json];
            }
            
            dispatch_async(dispatch_get_main_queue(),
            ^{
               if (error)
               {
                  WeatherResponseItem *weatherResponseItem = [WeatherResponseItem new];
                  weatherResponseItem.error = error;
                  
                  weakSelf.completionHandlerBlock(weatherResponseItem);
               }
               else
               {
                  if (   currentWeatherConditionItem != nil
                      && [hourlyWeatherConditionItems count] > 0
                      && [dailyWeatherConditionItems count] > 0)
                  {
                     WeatherResponseItem *weatherResponseItem = [WeatherResponseItem new];
                     weatherResponseItem.currentWeatherConditionItem = currentWeatherConditionItem;
                     weatherResponseItem.hourlyWeatherConditionItems = hourlyWeatherConditionItems;
                     weatherResponseItem.dailyWeatherConditionItems = dailyWeatherConditionItems;
                     
                     if (_completionHandlerBlock != nil)
                     {
                        weakSelf.completionHandlerBlock(weatherResponseItem);
                     }
                     
                     currentWeatherConditionItem = nil;
                     hourlyWeatherConditionItems = nil;
                     dailyWeatherConditionItems = nil;
                  }
               }
            });
         }
         else
         {
            WeatherResponseItem *weatherResponseItem = [WeatherResponseItem new];
            weatherResponseItem.error = error;
            
            dispatch_async(dispatch_get_main_queue(),
            ^{
               if (_completionHandlerBlock != nil)
               {
                  weakSelf.completionHandlerBlock(weatherResponseItem);
               }
            });
         }
      }];
      
      [dataTask resume];
   }
   else
   {
      dispatch_async(dispatch_get_main_queue(),
      ^{
         if (_completionHandlerBlock != nil)
         {
            weakSelf.completionHandlerBlock(nil);
         }
      });
   }
}

- (NSArray *)hourlyWeatherConditionsFromJSON:(NSDictionary *)json
{
   NSMutableArray *hourlyWeatherItems = [NSMutableArray new];
   
   NSArray *list = json[@"list"];
   
   for (NSDictionary *item in list)
   {
      WeatherConditionItem *weatherItem = [WeatherConditionItem currentWeatherConditionItemFromJSON:item];
      [hourlyWeatherItems addObject:weatherItem];
   }
   
   // Sort the results based on date
   NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimestamp" ascending:YES];
   NSArray *sortedArray = [hourlyWeatherItems sortedArrayUsingDescriptors:@[dateSortDescriptor]];
   
   return sortedArray;
}

- (NSArray *)dailyWeatherConditionsFromJSON:(NSDictionary *)json
{
   NSMutableArray *dailyWeatherItems = [NSMutableArray new];
   
   NSArray *list = json[@"list"];
   
   NSString *locationName = json[@"city"][@"name"];
   
   for (NSDictionary *item in list)
   {
      WeatherConditionItem *weatherItem = [WeatherConditionItem dailyWeatherConditionItemFromJSON:item];
      weatherItem.locationName = locationName;
      
      NSDate *date = [NSDate dateWithTimeIntervalSince1970:[weatherItem.dateTimestamp floatValue]];
      BOOL today = [[NSCalendar currentCalendar] isDateInToday:date];
      
      if (!today)
      {
         [dailyWeatherItems addObject:weatherItem];
      }
   }
   
   // Sort the results based on date
   NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimestamp" ascending:YES];
   NSArray *sortedArray = [dailyWeatherItems sortedArrayUsingDescriptors:@[dateSortDescriptor]];
   
   return sortedArray;
}

@end
