//
//  ViewController.h
//  WordClock
//
//  Created by James Rutherford on 2012-11-29.
//  Copyright (c) 2012 Braxio Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *clockView;
- (IBAction)configButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *clockBackground;
@property (weak, nonatomic) IBOutlet UIImageView *clockViewDropShadow;

@property NSMutableArray *elements;


@end
