//
//  UIColor+UIColorAdditions.h
//  WordClock
//
//  Created by James Rutherford on 2012-12-04.
//  Copyright (c) 2012 Braxio Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColorAdditions)

+ (NSString *)stringFromUIColor:(UIColor *)color;

@end

@interface NSString (UIColorAdditions)

+ (UIColor *)colorFromNSString:(NSString *)string;

@end
