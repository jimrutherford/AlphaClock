//
//  ViewController.m
//  AlphaClock
//
//  Created by James Rutherford on 2012-11-29.
//  Copyright (c) 2012 Braxio Interactive. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ImageWithColor.h"
#import	"UIColor+UIColorAdditions.h"

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

#define kTextHeight 60
#define kTextWidth	60
#define kHorizontalPadding 10
#define kVerticalPadding 10
#define kNumberOfColumns	11
#define kNumberOfRows	10
#define kShowAlpha 1.0f
#define kHideAlpha 0.2f
#define kInidicatorPadding 25

#define optionKeyForgroundColor @"forgroundColor"
#define optionKeyBackgroundColor @"backgroundColor"

@interface ViewController ()

@end

@implementation ViewController

@synthesize elements;
@synthesize minuteIndicators;
@synthesize clockBackground;
@synthesize clockViewDropShadow;
@synthesize forgroundRotaryChooser;
@synthesize backgroundRotaryChooser;

NSCalendar *gregorianCal;
NSArray * hours;
NSArray * minutes;
NSMutableDictionary *dict;

NSString *lastModifier;
NSString *lastMinute;
NSString *lastHour;

NSArray *forgroundColors;
NSArray *backgroundColors;

NSUserDefaults *userDefaults;

#pragma mark -
#pragma mark Main View Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];

	// init some objects that will be needed later
	gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	hours = @[@"TWELVE", @"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE", @"SIX", @"SEVEN", @"EIGHT", @"NINE", @"TEN", @"ELEVEN", @"TWELVE"];
	minutes = @[@"OCLOCK", @"five", @"ten", @"QUARTER", @"TWENTY", @"TWENTYFIVE", @"HALF", @"TWENTYFIVE", @"TWENTY", @"QUARTER", @"ten", @"five"];
	
	lastMinute = lastHour = lastModifier = @"";

	
	// populate arrays with colors
	forgroundColors = @[
	[UIColor colorWithRed:1.00f green:0.62f blue:0.63f alpha:1.00f],
	[UIColor colorWithRed:0.61f green:0.82f blue:1.00f alpha:1.00f],
	[UIColor colorWithRed:1.00f green:0.91f blue:0.62f alpha:1.00f],
	[UIColor colorWithRed:0.82f green:0.61f blue:1.00f alpha:1.00f],
	[UIColor colorWithRed:0.59f green:1.00f blue:0.62f alpha:1.00f],
	[UIColor colorWithRed:0.93f green:0.94f blue:0.94f alpha:1.00f]
	];
	
	backgroundColors = @[
	[UIColor colorWithRed:0.40f green:0.00f blue:0.00f alpha:1.00f],
	[UIColor colorWithRed:0.00f green:0.00f blue:0.42f alpha:1.00f],
	[UIColor colorWithRed:0.24f green:0.18f blue:0.00f alpha:1.00f],
	[UIColor colorWithRed:0.24f green:0.00f blue:0.25f alpha:1.00f],
	[UIColor colorWithRed:0.00f green:0.25f blue:0.00f alpha:1.00f],
	[UIColor colorWithRed:0.00f green:0.00f blue:0.00f alpha:1.00f]
	];
	
	
	userDefaults = [NSUserDefaults standardUserDefaults];

	// get default or lastUsed colors
	UIColor * startingForgroundColor = [forgroundColors objectAtIndex:5];
	UIColor * startingBackgroundColor = [backgroundColors objectAtIndex:5];
	
	if ([userDefaults objectForKey:optionKeyForgroundColor] != nil)
	{
		startingForgroundColor = [NSString colorFromNSString:[userDefaults objectForKey:optionKeyForgroundColor]];
	}

	if ([userDefaults objectForKey:optionKeyBackgroundColor] != nil)
	{
		startingBackgroundColor = [NSString colorFromNSString:[userDefaults objectForKey:optionKeyBackgroundColor]];
	}
	elements = [[NSMutableArray alloc] init];
	minuteIndicators = [[NSMutableArray alloc] init];
	
	
	for (int row = 0; row <kNumberOfRows; row++)
	{
		for (int col = 0; col < kNumberOfColumns; col++)
		{
			UILabel *label = [[UILabel alloc] init];
			label.backgroundColor = [UIColor clearColor];
			label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30];
			label.textAlignment = NSTextAlignmentCenter;
			label.text = [self randomLetter];
			label.textColor = startingForgroundColor;
			label.alpha = kHideAlpha;
			
			[self.clockView addSubview:label];
			[elements addObject:label];
		}
	}
	
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
			@0, @"IT",
			@3, @"IS",
			@13, @"QUARTER",
			@22, @"TWENTY",
			@28, @"five",
			@22, @"TWENTYFIVE",
			@33, @"HALF",
			@38, @"ten",
			@42, @"TO",
			@44, @"PAST",
			@51, @"NINE",
			@55, @"ONE",
			@58, @"SIX",
			@61, @"THREE",
			@66, @"FOUR",
			@70, @"FIVE",
			@74, @"TWO",
			@77, @"EIGHT",
			@82, @"ELEVEN",
			@88, @"SEVEN",
			@93, @"TWELVE",
			@99, @"TEN",
			@104, @"OCLOCK",
			nil];
	
	for(id key in dict)
	{
		int startIndex =  [[dict objectForKey:key] intValue];
		
		for (int a = startIndex; a < startIndex + [key length]; a++)
		{
			unichar character = [key characterAtIndex: a - startIndex];			
			[(UILabel*)[self.elements objectAtIndex:a] setText:[[NSString stringWithFormat:@"%C", character] uppercaseString]];
		}
	}
	
	[self updateTextStartingAtIndex:[[dict objectForKey:@"IT"] intValue] withLength:2 showing:YES];
	[self updateTextStartingAtIndex:[[dict objectForKey:@"IS"] intValue] withLength:2 showing:YES];
	
	[clockBackground setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[clockViewDropShadow setFrame:CGRectMake(-15, 0, clockViewDropShadow.frame.size.width, clockViewDropShadow.frame.size.height)];
	
	forgroundRotaryChooser = [[TPTRotaryChooser alloc] initWithFrame:CGRectMake(22, 25, 200, 200)];
	forgroundRotaryChooser.backgroundColor = [UIColor clearColor];
	forgroundRotaryChooser.numberOfSegments = 6;
	forgroundRotaryChooser.delegate = self;
	forgroundRotaryChooser.backgroundImage = [UIImage imageNamed:@"forgroundColors"];
	forgroundRotaryChooser.knobImage = [UIImage imageNamed:@"dial"];
	forgroundRotaryChooser.tag = 100;

	backgroundRotaryChooser = [[TPTRotaryChooser alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	backgroundRotaryChooser.backgroundColor = [UIColor clearColor];
	backgroundRotaryChooser.numberOfSegments = 6;
	backgroundRotaryChooser.delegate = self;
	backgroundRotaryChooser.backgroundImage = [UIImage imageNamed:@"bacgroundColors"];
	backgroundRotaryChooser.knobImage = [UIImage imageNamed:@"dial"];
	backgroundRotaryChooser.tag = 200;
	
	// set the selected segments of our rotary choosers
	for (int a = 0; a < [forgroundColors count]; a++)
	{
		if ([[UIColor stringFromUIColor:startingForgroundColor] isEqualToString:[UIColor stringFromUIColor:[forgroundColors objectAtIndex:a]]] )
		{
			forgroundRotaryChooser.selectedSegment = a;
			break;
		}
	}
	
	for (int a = 0; a < [backgroundColors count]; a++)
	{
		if ([[UIColor stringFromUIColor:startingBackgroundColor] isEqualToString:[UIColor stringFromUIColor:[backgroundColors objectAtIndex:a]]] )
		{
			backgroundRotaryChooser.selectedSegment = a;
			break;
		}
	}
	
	[self setForgroundColor:startingForgroundColor];
	[self.clockBackground setBackgroundColor:startingBackgroundColor];
	
	[self.optionsView addSubview:forgroundRotaryChooser];
	[self.optionsView addSubview:backgroundRotaryChooser];
	
	[self.configButton setAlpha:kHideAlpha];
	
	// draw minute indicators
	UIImage *indicator = [UIImage imageNamed:@"minuteIndicator" imageWithColor:startingForgroundColor];
	for (int a = 0; a < 4; a++) {
		UIImageView * image = [[UIImageView alloc] initWithImage:indicator];

		image.alpha = kHideAlpha;
		
		[self.clockView addSubview:image];
		[minuteIndicators addObject:image];
	}

	// setup and add gesture recognizers to hide/show options panel
	UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
	UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
	
	[swipeLeftRecognizer setDirection:( UISwipeGestureRecognizerDirectionLeft )];
	[swipeRightRecognizer setDirection:( UISwipeGestureRecognizerDirectionRight )];
	
	[[self view] addGestureRecognizer:swipeLeftRecognizer];
	[[self view] addGestureRecognizer:swipeRightRecognizer];
	
	[self updateTime];
}

#pragma mark -
#pragma mark Clock Display Logic

- (void) updateTime
{
	NSDateComponents *dateComponents = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
												  fromDate: [NSDate date]];

	// if we are 35 minutes past the hour or greater, our display needs to be
	// "PAST" the next hour.  Lets add one to the hour in this case
	int hour = [dateComponents hour];
	if ([dateComponents minute] > 34)
	{
		hour += 1;
	}
	
	[self displayMinute:[dateComponents minute]];
	[self displayHour:hour];
	
	[self performSelector:@selector(updateTime) withObject:self afterDelay:15.0f];
}


- (void) displayMinute:(int)minute
{
	NSString *minuteKey = [minutes objectAtIndex:[self indexFromMinute:minute]];
	
	NSString *modifierKey = minute > 34 ? @"TO" : @"PAST";
	if (minute < 5) modifierKey = @"OCLOCK";
		
	if (![lastMinute isEqualToString:minuteKey])
	{
		[self updateTextStartingAtIndex:[[dict objectForKey:lastMinute] intValue] withLength:[lastMinute length] showing:NO];
		[self updateTextStartingAtIndex:[[dict objectForKey:minuteKey] intValue] withLength:[minuteKey length] showing:YES];
		lastMinute = minuteKey;
	}
	
	if (![lastModifier isEqualToString:modifierKey])
	{
		[self updateTextStartingAtIndex:[[dict objectForKey:modifierKey] intValue] withLength:[modifierKey length] showing:YES];
		[self updateTextStartingAtIndex:[[dict objectForKey:lastModifier] intValue] withLength:[lastModifier length] showing:NO];
		
		lastModifier = modifierKey;
	}
	
	// update the partial minute indicator
	int partialMinutes = minute % 5;
	
	if (partialMinutes == 0)
	{
		for (int a = 0; a < [minuteIndicators count]; a++)
		{
			UIImageView * indicator = (UIImageView*)[self.minuteIndicators objectAtIndex:a];
			indicator.alpha = kHideAlpha;
		}
	}
	else
	{
		for (int a = 0; a < partialMinutes; a++)
		{
			UIImageView * indicator = (UIImageView*)[self.minuteIndicators objectAtIndex:a];
			indicator.alpha = kShowAlpha;
		}
	}
}

- (void) displayHour:(int)hour
{
	NSString *key = [hours objectAtIndex:hour % 12];
	
	if (![lastHour isEqualToString:key])
	{
		[self updateTextStartingAtIndex:[[dict objectForKey:key] intValue] withLength:[key length] showing:YES];	
		[self updateTextStartingAtIndex:[[dict objectForKey:lastHour] intValue] withLength:[lastHour length] showing:NO];

		lastHour = key;
	}
}

- (void) updateTextStartingAtIndex:(int)index withLength:(int)length showing:(BOOL)show
{
	UILabel * label;
	float newAlpha = show ? kShowAlpha : kHideAlpha;
	for (int a = index; a < index + length; a++)
	{
		label = (UILabel*)[self.elements objectAtIndex:a];
		if (newAlpha != label.alpha)
		{
			[label setAlpha:newAlpha];
		}
	}
}

#pragma mark -
#pragma mark Options Menu

- (IBAction)configButton:(id)sender {

	CGRect clockViewFrame = self.clockView.frame;
	if (clockViewFrame.origin.x == 0)
	{
		[self showOptionsMenu:YES];
	}
	else
	{
		[self showOptionsMenu:NO];
	}
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
	if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
	{
		[self showOptionsMenu:NO];
	}
	else
	{
		[self showOptionsMenu:YES];
	}
}

- (void) showOptionsMenu:(BOOL)show
{
	CGRect clockViewFrame = self.clockView.frame;
    
	if (show)
	{
		clockViewFrame.origin.x = 250;
	}
	else
	{
		clockViewFrame.origin.x = 0;
	}

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
    self.clockView.frame = clockViewFrame;
	
    [UIView commitAnimations];

}

#pragma mark -
#pragma mark TPTRotaryChooser Delegate Methods

- (void)rotaryChooserDidChangeSelectedSegment:(TPTRotaryChooser *)chooser
{
	if (chooser.tag == 100)
	{
		[self setForgroundColor:[forgroundColors objectAtIndex:chooser.currentSegment]];
	}
}

- (void)rotaryChooserDidSelectedSegment:(TPTRotaryChooser *)chooser
{
	if (chooser.tag == 100)
	{
		UIColor * newForgroundColor = (UIColor*)[forgroundColors objectAtIndex:chooser.selectedSegment];
		[self setForgroundColor:newForgroundColor];
		NSString *stringColor = [UIColor stringFromUIColor:newForgroundColor];
		[userDefaults setObject:stringColor forKey:optionKeyForgroundColor];
		
		for (int a = 0; a < 4; a++) {
			UIImage *indicator = [UIImage imageNamed:@"minuteIndicator" imageWithColor:newForgroundColor];
			UIImageView * image = (UIImageView*)[minuteIndicators objectAtIndex:a];
			image.image = indicator;
		}
		
	}
	else if (chooser.tag == 200)
	{
		UIColor * newBackgroundColor = (UIColor*)[backgroundColors objectAtIndex:chooser.selectedSegment];
		[self.clockBackground setBackgroundColor:newBackgroundColor];
		NSString *stringColor = [UIColor stringFromUIColor:newBackgroundColor];
		[userDefaults setObject:stringColor forKey:optionKeyBackgroundColor];
	}
	[userDefaults synchronize];
}

#pragma mark -
#pragma mark Visual Styling

- (void) setForgroundColor:(UIColor*)color
{
	for (UILabel* label in elements)
	{
		label.textColor = color;
	}
	[self.configButton setImage:[UIImage imageNamed:@"config" imageWithColor:color] forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Device Rotation and Layout

- (void)deviceDidRotate:(NSNotification *)notification
{
	UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
	[self layoutElementsWithOrientation:currentOrientation];
}

- (void) layoutElementsWithOrientation:(UIDeviceOrientation)orientation
{
	float width = ScreenWidth;
	float height = ScreenHeight;
	
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
		height = ScreenWidth;
		width = ScreenHeight;
	}
	
	float horizontalCenterOffset = (width - (kNumberOfColumns * (kTextWidth + kHorizontalPadding))) /2;
	float verticalCenterOffset = (height - (kNumberOfRows * (kTextHeight + kVerticalPadding))) /2;
	
	for (int row = 0; row <kNumberOfRows; row++)
	{
		for (int col = 0; col < kNumberOfColumns; col++)
		{
			float x = col * (kTextWidth + kHorizontalPadding) + horizontalCenterOffset;
			float y = row * (kTextHeight + kVerticalPadding) + verticalCenterOffset;
			
			UILabel *label = (UILabel*)[self.elements objectAtIndex:col + (row * kNumberOfColumns)];
			label.frame = CGRectMake(x, y, kTextWidth, kTextHeight);
		}
	}
	
	UIImage *indicator = [UIImage imageNamed:@"minuteIndicator"];
	float minuteIndicatorHorizontalCenterOffset = (width - (4 * indicator.size.width) - (3 * kInidicatorPadding)) /2;
	for (int a = 0; a < 4; a++) {
		UIImageView * image = (UIImageView*)[minuteIndicators objectAtIndex:a];
		image.frame = CGRectMake(minuteIndicatorHorizontalCenterOffset + a * kInidicatorPadding, height - 40, indicator.size.width, indicator.size.height);
	}

	self.clockBackground.frame = self.optionsView.frame = CGRectMake(0, 0, width, height);
	 
	backgroundRotaryChooser.frame = CGRectMake(22, height - 200 - 25, 200, 200);
}

#pragma mark -
#pragma mark Utility Methods

NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

- (int) indexFromMinute:(int)minute
{
	return (minute - (minute % 5)) / 5;
}

-(NSString *) randomLetter {
	unichar character = [letters characterAtIndex: arc4random()%[letters length]];
    return [NSString stringWithFormat:@"%C", character];
}


#pragma mark -
#pragma mark Boilerplate

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
