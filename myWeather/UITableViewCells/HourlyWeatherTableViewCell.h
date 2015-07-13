//
//  HourlyWeatherTableViewCell.h
//  Weather
//
//  Created by Giannis Giannopoulos on 7/7/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HOURLY_WEATHER_TABLEVIEW_CELL_ID @"HourlyWeatherTableViewCellIdentifier"

/** the UITableViewCell which contains the UICollectionView with the hourly weather conditions */
@interface HourlyWeatherTableViewCell : UITableViewCell

/** the UICollectionView with the hourly weather conditions */
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
