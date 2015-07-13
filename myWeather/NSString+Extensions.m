//
//  NSString+Extensions.m
//  myWeather
//
//  Created by Giannis Giannopoulos on 7/11/15.
//  Copyright (c) 2015 Giannis Giannopoulos. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

- (BOOL)isEmpty
{
   NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
   NSString *stringWithNoWhitespaces = [self stringByTrimmingCharactersInSet:characterSet];
   BOOL isEmpty = stringWithNoWhitespaces.length == 0;
   
   return isEmpty;
}

@end
