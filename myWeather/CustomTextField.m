//
//  CustomTextField.m
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/11/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (CGSize)intrinsicContentSize
{
   if (self.isEditing)
   {
      CGSize size = [self.text sizeWithAttributes:self.typingAttributes];
      CGFloat offset = 2;
      CGSize retVal = CGSizeMake(size.width + self.rightView.bounds.size.width + self.leftView.bounds.size.width + offset, size.height);
      
      return retVal;
   }
   
   return [super intrinsicContentSize];
}

@end
