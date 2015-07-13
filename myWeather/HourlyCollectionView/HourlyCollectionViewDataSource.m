//
//  HourlyCollectionViewDataSource.m
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/10/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import "HourlyCollectionViewDataSource.h"
#import "HourlyCollectionViewCell.h"
#import "WeatherConditionItem.h"

@interface HourlyCollectionViewDataSource () 
{
   NSArray *hourlyWeatherConditionItems;
}

@end

@implementation HourlyCollectionViewDataSource

#pragma mark - Public Methods

- (void)setHourlyWeatherConditionItems:(NSArray *)theHourlyWeatherConditionItems
{
   hourlyWeatherConditionItems = nil;
   hourlyWeatherConditionItems = [theHourlyWeatherConditionItems copy];
   [_collectionView reloadData];
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
   if (!_collectionView)
   {
      _collectionView = collectionView;
   }
}

#pragma mark - UICollectionView DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
   return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   return [hourlyWeatherConditionItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   HourlyCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHourlyCollectionViewCellIdentifier
                                                                              forIndexPath:indexPath];
   
   WeatherConditionItem *weatherConditionItem = hourlyWeatherConditionItems[indexPath.row];
   cell.weatherConditionImageView.image = [UIImage imageNamed:weatherConditionItem.iconName];
   
   // Format 12:42 PM based on User Settings
   NSDateFormatter *dateFormatter = [NSDateFormatter new];
   [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
   
   NSDate *date = [NSDate dateWithTimeIntervalSince1970:[weatherConditionItem.dateTimestamp integerValue]];
   NSString *currentTime = [dateFormatter stringFromDate:date];
   
   cell.timeLabel.text = currentTime;
   cell.temperatureLabel.text = [NSString stringWithFormat:@"%.0f°", [weatherConditionItem.temperature floatValue]];
   
   return cell;
}

@end
