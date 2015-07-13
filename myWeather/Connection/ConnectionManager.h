//
//  ConnectionManager.h
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/6/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherRequestInterface.h"

@class WeatherResponseItem;

typedef void (^ConnectionCompletionHandler)(WeatherResponseItem *weatherResponseItem);

typedef NS_ENUM(NSUInteger, WeatherType)
{
   WeatherTypeCurrentConditions,
   WeatherTypeHourlyConditions,
   WeatherTypeDailyConditions,
};

/** object which handles the connection and fetch of content from the Weather Web Service */
@interface ConnectionManager : NSObject

/** executes a fetch request based on the request item from the Weather Web Service and calls the block on completion
 @param requestItem the request item
 @param completionHandler the block which passes the weatherResponseItem with the results from the fetch
 */
- (void)fetchWeatherConditionsForRequestItem:(id<WeatherRequestInterface>)requestItem
                           completionHandler:(ConnectionCompletionHandler)completionHandler;

@end
