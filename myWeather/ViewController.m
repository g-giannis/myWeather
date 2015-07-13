//
//  ViewController.m
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/5/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import "ViewController.h"
#import "ConnectionManager.h"
#import "WeatherConditionItem.h"
#import "HourlyWeatherTableViewCell.h"
#import "DailyWeatherTableViewCell.h"
#import "LocationManager.h"
#import "HourlyCollectionViewDataSource.h"
#import "CustomTextField.h"
#import "WeatherRequestItem.h"
#import "WeatherResponseItem.h"
#import "Reachability.h"

#define RAND_BETWEEN(low, high) (((float) rand() / RAND_MAX) * (high - low)) + low

#define HOURLY_TABLEVIEW_ROW_HEIGHT 130.0
#define DAILY_TABLEVIEW_ROW_HEIGHT 70.0

#define CIRCLE_SIZE 40.0
#define LEFT_RIGHT_MARGIN 5.0

#define UITABLEVIEW_CONTENT_INSET UIEdgeInsetsMake(20.0, 0, 0, 0)

#define PUSH_DIRECTION CGVectorMake(RAND_BETWEEN(-1.0, 1.0), RAND_BETWEEN(-1.0, 1.0))


@interface ViewController () <UITextFieldDelegate>
{
   BOOL statusBarHidden;
   
   WeatherRequestItem *weatherRequestItem;
   WeatherResponseItem *weatherResponseItem;
   
   ConnectionManager *connectionManager;
   HourlyCollectionViewDataSource *hourlyCollectionViewDataSource;
   
   UIDynamicAnimator *animator;
   NSMutableArray *circleViews;
   NSTimer *pushBehaviorTimer;
   
   UIVisualEffectView *visualEffectView;
   UILabel *mainInformationLabel;

   // Top section
   __weak IBOutlet CustomTextField *locationNameTextField;
   __weak IBOutlet UIButton *locationButton;
   __weak IBOutlet UIButton *infoButton;

   // Left current weather condition values
   __weak IBOutlet UIImageView *weatherConditionImageView;
   __weak IBOutlet UILabel *weatherConditionDescriptionLabel;
   __weak IBOutlet UIImageView *humidityImageView;
   __weak IBOutlet UILabel *humidityLabel;
   __weak IBOutlet UIImageView *windSpeedImageView;
   __weak IBOutlet UILabel *windSpeedLabel;
   
   // Right current weather condition values
   __weak IBOutlet UILabel *currentTemparatureLabel;
   __weak IBOutlet UILabel *minTemperatureLabel;
   __weak IBOutlet UILabel *maxTemperatureLabel;
}

@end

@implementation ViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Adjust UITableView header view
   CGRect frame = self.tableView.tableHeaderView.frame;
   frame.size.height = [UIScreen mainScreen].bounds.size.height * 0.97;
   self.tableView.tableHeaderView.frame = frame;
   
   statusBarHidden = NO;
   
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(applicationDidEnterBackground:)
                                                name:UIApplicationDidEnterBackgroundNotification
                                              object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(applicationWillEnterForeground:)
                                                name:UIApplicationWillEnterForegroundNotification
                                              object:nil];

   [[LocationManager sharedInstance] startUpdatingLocation];
   
   connectionManager = [ConnectionManager new];
   hourlyCollectionViewDataSource = [HourlyCollectionViewDataSource new];
  
   [self createCircleViews];
   [self startPushBehaviorTimer];
   
   // Blur Effect View
   UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
   visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
   visualEffectView.layer.cornerRadius = 7.0;
   visualEffectView.frame = [self initialVisualEffectViewFrame];
   visualEffectView.clipsToBounds = YES;
   [self.tableView insertSubview:visualEffectView atIndex:0];
   
   self.tableView.contentInset = UITABLEVIEW_CONTENT_INSET;
   
   // Refresh Control
   UIRefreshControl *refreshControl = [UIRefreshControl new];
   refreshControl.tintColor = [UIColor whiteColor];
   [refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
   [self.tableView addSubview:refreshControl];
   
   [self createMainInformationLabel];
   [self updateUI];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   [pushBehaviorTimer invalidate];
   pushBehaviorTimer = nil;
}

#pragma mark - UIStatusBar Methods

- (UIStatusBarStyle)preferredStatusBarStyle
{
   return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
   return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
   return UIStatusBarAnimationFade;
}

#pragma mark - NSNotification Center Observer Methods

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
   // Stop push behavior to save energy
   [pushBehaviorTimer invalidate];
   pushBehaviorTimer = nil;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
   [self startPushBehaviorTimer];
}

#pragma mark - Helper Methods

- (CGRect)initialVisualEffectViewFrame
{
   return CGRectMake(LEFT_RIGHT_MARGIN,
                     self.tableView.tableHeaderView.frame.size.height,
                     self.view.frame.size.width - (LEFT_RIGHT_MARGIN * 2),
                     DAILY_TABLEVIEW_ROW_HEIGHT + 50.0);
}

- (UILabel *)customLabel
{
   UILabel *customLabel = [UILabel new];
   customLabel.translatesAutoresizingMaskIntoConstraints = NO;
   customLabel.numberOfLines = 0;
   customLabel.textColor = [UIColor whiteColor];
   customLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18.0];
   
   return customLabel;
}

- (void)createMainInformationLabel
{
   mainInformationLabel = [self customLabel];
   [visualEffectView addSubview:mainInformationLabel];
   
   // Auto-Layout Constraints
   NSDictionary *metrics = @{@"margin" : @(LEFT_RIGHT_MARGIN)};
   NSDictionary *views = NSDictionaryOfVariableBindings(mainInformationLabel);
   NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainInformationLabel]-margin-|"
                                                                            options:0
                                                                            metrics:metrics
                                                                              views:views];
   NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[mainInformationLabel]-margin-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views];
   [visualEffectView addConstraints:horizontalConstraints];
   [visualEffectView addConstraints:verticalConstraints];
}

- (void)createCircleViews
{
   // UITableView backgroundView
   UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
   backgroundImageView.image = [UIImage imageNamed:@"Background"];
   self.tableView.backgroundView = backgroundImageView;

   // Create the circle views and assign the behaviors
   animator = [[UIDynamicAnimator alloc] initWithReferenceView:backgroundImageView];
   circleViews = [NSMutableArray new];
   
   for (int i = 0; i < 6; i++)
   {
      UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(arc4random_uniform(backgroundImageView.frame.size.width),
                                                                    arc4random_uniform(backgroundImageView.frame.size.height),
                                                                    CIRCLE_SIZE,
                                                                    CIRCLE_SIZE)];
      [backgroundImageView addSubview:circleView];
      
      CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
      scaleAnimation.fromValue = @(RAND_BETWEEN(0, 1.0));
      scaleAnimation.toValue = @(RAND_BETWEEN(0.0, 3.0));
      scaleAnimation.duration = 10.0;
      scaleAnimation.fillMode = kCAFillModeForwards;
      scaleAnimation.repeatCount = FLT_MAX;
      scaleAnimation.autoreverses = YES;
      scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
      scaleAnimation.removedOnCompletion = NO;
      [circleView.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
   
      // Layer adjustments
      UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleView.bounds];

      circleView.layer.cornerRadius = circleView.frame.size.width / 2;
      circleView.layer.backgroundColor = [UIColor whiteColor].CGColor;
      circleView.layer.opacity = 0.4;
      circleView.layer.shadowColor = [UIColor whiteColor].CGColor;
      circleView.layer.shadowOpacity = 1.0;
      circleView.layer.shadowOffset = CGSizeZero;
      circleView.layer.shadowRadius = 3.0;
      circleView.layer.shadowPath = path.CGPath;
      circleView.layer.masksToBounds = NO;

      UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[circleView] mode:UIPushBehaviorModeInstantaneous];
      pushBehavior.pushDirection = PUSH_DIRECTION;
      pushBehavior.active = YES;
      pushBehavior.magnitude = 0.08;
      [animator addBehavior:pushBehavior];
      
      [circleViews addObject:circleView];
   }
   
   UIDynamicItemBehavior *viewDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:circleViews];
   viewDynamicBehavior.allowsRotation = NO;
   viewDynamicBehavior.elasticity = 1.0;
   viewDynamicBehavior.friction = 0;
   viewDynamicBehavior.resistance = 0;
   [animator addBehavior:viewDynamicBehavior];
   
   UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:circleViews];
   [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-100, -100, -100, -100)];
   collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
   [animator addBehavior:collisionBehavior];
}

- (void)startPushBehaviorTimer
{
   if (!pushBehaviorTimer)
   {
      pushBehaviorTimer = [NSTimer scheduledTimerWithTimeInterval:8
                                                           target:self
                                                         selector:@selector(animateCircleViewsWithPushBehavior)
                                                         userInfo:nil
                                                          repeats:YES];
   }

   [pushBehaviorTimer fire];
}

- (void)animateCircleViewsWithPushBehavior
{
   for (id behavior in animator.behaviors)
   {
      if ([behavior isKindOfClass:[UIPushBehavior class]])
      {
         UIPushBehavior *pushBehavior = behavior;
         pushBehavior.pushDirection = PUSH_DIRECTION;
         pushBehavior.magnitude = 0.05;
         [pushBehavior setActive:YES];
      }
   }
}

- (void)animateAlphaInCellsAndVisualEffectViewSize
{
   for (UITableViewCell *tableViewCell in self.tableView.visibleCells)
   {
      tableViewCell.alpha = 0;
   }
   
   [UIView animateWithDuration:0.3
                    animations:
    ^{
       CGRect visualEffectViewFrame = visualEffectView.frame;
       visualEffectViewFrame.size.height = self.tableView.contentSize.height - self.tableView.tableHeaderView.frame.size.height - LEFT_RIGHT_MARGIN;
       visualEffectView.frame = visualEffectViewFrame;
    }
                    completion:^(BOOL finished)
    {
       [UIView animateWithDuration:0.2
                        animations:
        ^{
           for (UITableViewCell *tableViewCell in self.tableView.visibleCells)
           {
              tableViewCell.alpha = 1.0;
           }
        }];
    }];
}

- (void)updateUI
{
   locationNameTextField.text = @"-----";
   
   weatherConditionImageView.image = nil;
   humidityImageView.hidden = YES;
   windSpeedImageView.hidden = YES;
   
   weatherConditionDescriptionLabel.text = @"--";
   
   currentTemparatureLabel.text = @"--°";
   minTemperatureLabel.text = @"--°";
   maxTemperatureLabel.text = @"--°";
   
   humidityLabel.text = @"--";
   windSpeedLabel.text = @"--";
   
   if (!weatherResponseItem)
   {
      mainInformationLabel.hidden = NO;
      mainInformationLabel.text = @"Please tap the location button to get weather data based on current GPS location or fill the address next to the location button";
   }
   else
   {
      if (weatherResponseItem.error)
      {
         mainInformationLabel.hidden = NO;
         mainInformationLabel.text = weatherResponseItem.error.localizedFailureReason;
         
         [UIView animateWithDuration:0.3
                          animations:
         ^{
            visualEffectView.frame = [self initialVisualEffectViewFrame];
         }];
         
         [self.tableView reloadData];
      }
      else
      {
         humidityImageView.hidden = NO;
         windSpeedImageView.hidden = NO;

         // Set current weather conditions
         WeatherConditionItem *currentWeatherConditionItem = weatherResponseItem.currentWeatherConditionItem;
         
         locationNameTextField.text = weatherResponseItem.currentWeatherConditionItem.locationName;
         currentTemparatureLabel.text = [NSString stringWithFormat:@"%.0f°", [currentWeatherConditionItem.temperature floatValue]];
         minTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", [currentWeatherConditionItem.minTemperature floatValue]];
         maxTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", [currentWeatherConditionItem.maxTemperature floatValue]];
         weatherConditionImageView.image = [UIImage imageNamed:currentWeatherConditionItem.iconName];
         weatherConditionDescriptionLabel.text = currentWeatherConditionItem.conditionText;
         humidityLabel.text = [NSString stringWithFormat:@"%.0f %%", [currentWeatherConditionItem.humidityPercentage floatValue]];
         windSpeedLabel.text = [NSString stringWithFormat:@"%.0f km/h", [currentWeatherConditionItem.windSpeed floatValue]];

         mainInformationLabel.hidden = YES;

         if ([weatherResponseItem.dailyWeatherConditionItems count] > 0)
         {
            [self.tableView reloadData];
            [self animateAlphaInCellsAndVisualEffectViewSize];
         }
      }
   }
}

- (void)updateLocationNameTextfieldState
{
   locationNameTextField.userInteractionEnabled = !locationButton.selected;
   locationNameTextField.alpha = locationNameTextField.userInteractionEnabled ? 1.0 : 0.6;
}

- (void)allowLocationEditing:(BOOL)locationEditingIsAllowed
{
   locationNameTextField.userInteractionEnabled = locationEditingIsAllowed;
   locationButton.userInteractionEnabled = locationEditingIsAllowed;
}

- (void)showInfoActionSheet
{
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"About"
                                                                            message:@"The icons where distributed from Icons8 under Creative Commons Attribution-NoDerivs 3.0 Unported license."
                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
   
   UIAlertAction *linkAction = [UIAlertAction actionWithTitle:@"Go to Icons8 website"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
   {
      NSURL *url = [NSURL URLWithString:@"https://icons8.com/license"];
      [[UIApplication sharedApplication] openURL:url];
   }];

   UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
   [alertController addAction:linkAction];
   [alertController addAction:okAction];
   
   // Prevent crash on iPad
   [alertController setModalPresentationStyle:UIModalPresentationPopover];
   UIPopoverPresentationController *popoverPresentationController = [alertController popoverPresentationController];
   popoverPresentationController.sourceView = infoButton;
   popoverPresentationController.sourceRect = infoButton.bounds;
   
   [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WebService Methods

- (void)fetchWeatherDataFromWebService
{
   Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
   NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
   
   if (networkStatus == NotReachable)
   {
      weatherResponseItem = [WeatherResponseItem new];
      weatherResponseItem.error = [NSError errorWithDomain:@"Domain"
                                                      code:NSURLErrorNotConnectedToInternet
                                                  userInfo:@{NSLocalizedFailureReasonErrorKey : @"No internet connection available"}];
      [hourlyCollectionViewDataSource setHourlyWeatherConditionItems:weatherResponseItem.hourlyWeatherConditionItems];
      [self updateUI];
      weatherResponseItem = nil;
      
      return;
   }

   
   if (!weatherRequestItem)
   {
      weatherRequestItem = [WeatherRequestItem new];
   }

   if (locationButton.selected)
   {
      weatherRequestItem.location = [LocationManager sharedInstance].currentLocation;
   }
   else
   {
      weatherRequestItem.locationName = locationNameTextField.text;
   }
   
   if (   weatherRequestItem.location != nil
       || weatherRequestItem.locationName != nil)
   {
      [self allowLocationEditing:NO];
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
      
      __weak ViewController *weakSelf = self;

      // Fetch the weather conditions from the Web Service
      [connectionManager fetchWeatherConditionsForRequestItem:weatherRequestItem
                                            completionHandler:^(WeatherResponseItem *theWeatherResponseItem)
       {
          weatherResponseItem = theWeatherResponseItem;
          
          [hourlyCollectionViewDataSource setHourlyWeatherConditionItems:weatherResponseItem.hourlyWeatherConditionItems];
          [weakSelf updateUI];
          [weakSelf allowLocationEditing:YES];
          [weakSelf updateLocationNameTextfieldState];
          
          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          
          weatherRequestItem = nil;
       }];
   }
   else
   {
      weatherResponseItem = [WeatherResponseItem new];
      weatherResponseItem.error = [NSError errorWithDomain:@"Domain"
                                                      code:NSURLErrorNotConnectedToInternet
                                                  userInfo:@{NSLocalizedFailureReasonErrorKey : @"No GPS location or location name!"}];
      [hourlyCollectionViewDataSource setHourlyWeatherConditionItems:weatherResponseItem.hourlyWeatherConditionItems];
      [self updateUI];
      weatherResponseItem = nil;
   }
}

- (void)searchForCurrentLocationName
{
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

   __weak ViewController *weakSelf = self;

   [[LocationManager sharedInstance] weatherRequestItemForLocationName:locationNameTextField.text
                                                 withCompletionHandler:^(id<WeatherRequestInterface>theWeatherRequestItem, NSError *error)
   {
      if (!error)
      {
         weatherRequestItem = theWeatherRequestItem;
         locationNameTextField.text = [weatherRequestItem locationName];
         [weakSelf fetchWeatherDataFromWebService];
      }
      else
      {
         weatherResponseItem = [WeatherResponseItem new];
         weatherResponseItem.error = error;
         
         [hourlyCollectionViewDataSource setHourlyWeatherConditionItems:weatherResponseItem.hourlyWeatherConditionItems];
         [weakSelf updateUI];
         [weakSelf.tableView reloadData];
      }
      
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
   }];
}

#pragma mark - Action Methods

- (IBAction)infoButtonTapped:(UIButton *)sender
{
   [self showInfoActionSheet];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl
{
   [self fetchWeatherDataFromWebService];
   
   [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.2];
}

- (IBAction)locationButtonTapped:(UIButton *)sender
{
   if ([LocationManager sharedInstance].authorizationStatus == kCLAuthorizationStatusDenied)
   {
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location permissions needed"
                                                                               message:@"Please allow 'Location Services' for the Weather app in the Settings menu"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
      
      UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
      UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
      {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
      }];
      
      [alertController addAction:cancelAction];
      [alertController addAction:settingsAction];
      [self presentViewController:alertController animated:YES completion:nil];
   }
   else
   {
      [[LocationManager sharedInstance] startUpdatingLocation];

      sender.selected = !sender.selected;
      
      [self updateLocationNameTextfieldState];
      
      if (sender.selected)
      {
         [self fetchWeatherDataFromWebService];
      }
      else
      {
         [[LocationManager sharedInstance] stopUpdatingLocation];
      }
   }
}

#pragma mark - UITableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   CGFloat tableViewRowHeight = HOURLY_TABLEVIEW_ROW_HEIGHT;
   
   if (indexPath.row != 0)
   {
      tableViewRowHeight = DAILY_TABLEVIEW_ROW_HEIGHT;
   }
   
   return tableViewRowHeight;
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [[weatherResponseItem dailyWeatherConditionItems] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   UITableViewCell *tableViewCell;
   
   if (indexPath.row == 0)
   {
      HourlyWeatherTableViewCell *hourlyTableViewCell = [tableView dequeueReusableCellWithIdentifier:HOURLY_WEATHER_TABLEVIEW_CELL_ID
                                                                                        forIndexPath:indexPath];
      hourlyCollectionViewDataSource.collectionView = hourlyTableViewCell.collectionView;
      hourlyTableViewCell.collectionView.dataSource = hourlyCollectionViewDataSource;

      tableViewCell = hourlyTableViewCell;
   }
   else
   {
      DailyWeatherTableViewCell *dailyWeatherTableViewCell = [tableView dequeueReusableCellWithIdentifier:kDailyWeatherTableViewCellIdentifier
                                                                                             forIndexPath:indexPath];
      NSArray *dailyWeatherConditionItems = [weatherResponseItem dailyWeatherConditionItems];
      
      if ([dailyWeatherConditionItems count] > 0)
      {
         WeatherConditionItem *weatherConditionItem = dailyWeatherConditionItems[indexPath.row - 1];
         
         NSDateFormatter *dateFormatter = [NSDateFormatter new];
         [dateFormatter setDateFormat:@"EEEE"];
         NSDate *date = [NSDate dateWithTimeIntervalSince1970:[weatherConditionItem.dateTimestamp floatValue]];
         NSString *dayName = [dateFormatter stringFromDate:date];
         
         dailyWeatherTableViewCell.dayLabel.text = dayName;
         dailyWeatherTableViewCell.minTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", [weatherConditionItem.minTemperature floatValue]];
         dailyWeatherTableViewCell.maxTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", [weatherConditionItem.maxTemperature floatValue]];
         dailyWeatherTableViewCell.weatherConditionImageView.image = [UIImage imageNamed:weatherConditionItem.iconName];
      }
      
      tableViewCell = dailyWeatherTableViewCell;
   }
   
   tableViewCell.backgroundColor = [UIColor clearColor];
   
   return tableViewCell;
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   [locationNameTextField resignFirstResponder];
   
   [UIView animateWithDuration:0.2
                    animations:
    ^{
       // Hide the status bar if the content passes the status bar position
       statusBarHidden = scrollView.contentOffset.y > 30.0;
       [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [self searchForCurrentLocationName];
   
   [textField resignFirstResponder];
   
   return NO;
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender
{
   [locationNameTextField invalidateIntrinsicContentSize];
}

@end
