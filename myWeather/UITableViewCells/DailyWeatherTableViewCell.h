//
//  DailyWeatherTableViewCell.h
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/8/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kDailyWeatherTableViewCellIdentifier = @"DailyWeatherTableViewCellIdentifier";

/** UITableViewCell which shows the daily weather condition */
@interface DailyWeatherTableViewCell : UITableViewCell

/** the UILabel which shows the day (e.g. "Thursday") */
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

/** the UIImageView which represents the weather condition */
@property (weak, nonatomic) IBOutlet UIImageView *weatherConditionImageView;

/** the UILabel which shows the minimum temperature degrees */
@property (weak, nonatomic) IBOutlet UILabel *minTemperatureLabel;

/** the UILabel which shows the maximum temperature degrees */
@property (weak, nonatomic) IBOutlet UILabel *maxTemperatureLabel;

@end
