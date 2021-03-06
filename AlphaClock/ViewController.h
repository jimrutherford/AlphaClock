//
//  ViewController.h
//  AlphaClock
//
//  Created by James Rutherford on 2012-11-29.
//  Copyright (c) 2012 Braxio Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPTRotaryChooser.h"

@interface ViewController : UIViewController <TPTRotaryChooserDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *clockView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
- (IBAction)configButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *clockBackground;
@property (weak, nonatomic) IBOutlet UIImageView *clockViewDropShadow;

@property NSMutableArray *elements;
@property NSMutableArray *minuteIndicators;

@property (weak, nonatomic) IBOutlet UIButton *configButton;

@property (nonatomic) TPTRotaryChooser *forgroundRotaryChooser;
@property (nonatomic) TPTRotaryChooser *backgroundRotaryChooser;
@property (nonatomic) TPTRotaryChooser *blurBGRotaryChooser;

@end
