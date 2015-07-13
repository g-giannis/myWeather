//
//  HourlyCollectionViewCell.h
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/8/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kHourlyCollectionViewCellIdentifier = @"HourlyCollectionViewCellIdentifier";

/** the UICollectionViewCell which shows the hourly weather */
@interface HourlyCollectionViewCell : UICollectionViewCell

/** the label which shows the temperature */
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

/** the image view which shows the weather condition */
@property (weak, nonatomic) IBOutlet UIImageView *weatherConditionImageView;

/** the label which shows the time (e.g. "12:17 PM") */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
