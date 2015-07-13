//
//  HourlyCollectionViewDataSource.h
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/10/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** The DataSource object for the Hourly UICollectionView */
@interface HourlyCollectionViewDataSource : NSObject <UICollectionViewDataSource>

/** sets the specified hourly condition items that will be displayed inside the UICollectionView
 @param theHourlyWeatherConditionItems the specified hourly condition items
 */
- (void)setHourlyWeatherConditionItems:(NSArray *)theHourlyWeatherConditionItems;

/** reference to the HourlyWeatherTableViewCell's UICollectionView */
@property (nonatomic) UICollectionView *collectionView;

@end
