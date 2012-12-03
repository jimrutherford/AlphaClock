//
//  ViewController.m
//  WordClock
//
//  Created by James Rutherford on 2012-11-29.
//  Copyright (c) 2012 Braxio Interactive. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ImageWithColor.h"

#define kTextHeight 60
#define kTextWidth	60
#define kHorizontalPadding 10
#define kVerticalPadding 10
#define kNumberOfColumns	11
#define kNumberOfRows	10
#define kShowAlpha 1.0f
#define kHideAlpha 0.2f

@interface ViewController ()

@end

@implementation ViewController

@synthesize elements;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

	elements = [[NSMutableArray alloc] init];
	
	float horizontalCenterOffset = (self.view.frame.size.width - (kNumberOfColumns * (kTextWidth + kHorizontalPadding))) /2;
	float verticalCenterOffset = (self.view.frame.size.height - (kNumberOfRows * (kTextHeight + kVerticalPadding))) /2;
	
	for (int row = 0; row <kNumberOfRows; row++)
	{
		for (int col = 0; col < kNumberOfColumns; col++)
		{
			float x = col * (kTextWidth + kHorizontalPadding) + horizontalCenterOffset;
			float y = row * (kTextHeight + kVerticalPadding) + verticalCenterOffset;
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kTextWidth, kTextHeight)];
			label.backgroundColor = [UIColor clearColor];
			label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30];
			label.textAlignment = NSTextAlignmentCenter;
			label.text = [self randomLetter];
			label.textColor = [UIColor whiteColor];
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
	
	// init some objects that will be needed later
	gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	hours = @[@"TWELVE", @"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE", @"SIX", @"SEVEN", @"EIGHT", @"NINE", @"TEN", @"ELEVEN", @"TWELVE"];
	minutes = @[@"OCLOCK", @"five", @"ten", @"QUARTER", @"TWENTY", @"TWENTYFIVE", @"HALF", @"TWENTYFIVE", @"TWENTY", @"QUARTER", @"ten", @"five"];
	
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
	
	lastMinute = lastHour = lastModifier = @"";
	
	[clockBackground setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[clockViewDropShadow setFrame:CGRectMake(-15, 0, clockViewDropShadow.frame.size.width, clockViewDropShadow.frame.size.height)];
	
	
	forgroundRotaryChooser = [[TPTRotaryChooser alloc] initWithFrame:CGRectMake(10, 20, 200, 200)];
	forgroundRotaryChooser.backgroundColor = [UIColor clearColor];
	forgroundRotaryChooser.numberOfSegments = 6;
	forgroundRotaryChooser.selectedSegment = 5;
	forgroundRotaryChooser.delegate = self;
	forgroundRotaryChooser.backgroundImage = [UIImage imageNamed:@"forgroundColors"];
	forgroundRotaryChooser.knobImage = [UIImage imageNamed:@"dial"];
	forgroundRotaryChooser.tag = 100;

	backgroundRotaryChooser = [[TPTRotaryChooser alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 200 - 20, 200, 200)];
	backgroundRotaryChooser.backgroundColor = [UIColor clearColor];
	backgroundRotaryChooser.numberOfSegments = 6;
	backgroundRotaryChooser.selectedSegment = 5;
	backgroundRotaryChooser.delegate = self;
	backgroundRotaryChooser.backgroundImage = [UIImage imageNamed:@"bacgroundColors"];
	backgroundRotaryChooser.knobImage = [UIImage imageNamed:@"dial"];
	backgroundRotaryChooser.tag = 200;
	
	[self setForgroundColor:[UIColor whiteColor]];
	[self.clockBackground setBackgroundColor:[UIColor blackColor]];
	
	[self.optionsView addSubview:forgroundRotaryChooser];
	[self.optionsView addSubview:backgroundRotaryChooser];
	
	[self.configButton setAlpha:kHideAlpha];
	
	[self updateTime];
}


- (void) setForgroundColor:(UIColor*)color
{
	for (UILabel* label in elements)
	{
		label.textColor = color;
	}
	[self.configButton setImage:[UIImage imageNamed:@"config" imageWithColor:color] forState:UIControlStateNormal];
}

- (void) updateTime
{
	NSDateComponents *dateComponents = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
												  fromDate: [NSDate date]];

	[self displayMinute:[dateComponents minute]];
	
	int hour = [dateComponents hour];
	if ([dateComponents minute] > 34)
	{
		hour += 1;
	}
	
	[self displayHour:hour];
	
	[self performSelector:@selector(updateTime) withObject:self afterDelay:15.0f];
}

- (int) indexFromMinute:(int)minute
{
	return (minute - (minute % 5)) / 5;
}

- (void) displayMinute:(int)minute
{
	NSString *minuteKey = [minutes objectAtIndex:[self indexFromMinute:minute]];
	
	NSString *modifierKey = minute > 30 ? @"TO" : @"PAST";
	if (minute < 5) modifierKey = @"OCLOCK";
		
	if (![lastMinute isEqualToString:minuteKey])
	{
		[self updateTextStartingAtIndex:[[dict objectForKey:minuteKey] intValue] withLength:[minuteKey length] showing:YES];
		if (!([lastMinute isEqualToString:@"TWENTY"] && [modifierKey isEqualToString:@"PAST"]))
		{
			[self updateTextStartingAtIndex:[[dict objectForKey:lastMinute] intValue] withLength:[lastMinute length] showing:NO];
		}
		lastMinute = minuteKey;
	}
	
	if (![lastModifier isEqualToString:modifierKey])
	{
		[self updateTextStartingAtIndex:[[dict objectForKey:modifierKey] intValue] withLength:[modifierKey length] showing:YES];
		[self updateTextStartingAtIndex:[[dict objectForKey:lastModifier] intValue] withLength:[lastModifier length] showing:NO];
		
		lastModifier = modifierKey;
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
	for (int a = index; a < index + length; a++)
	{
		[(UILabel*)[self.elements objectAtIndex:a] setAlpha:(show ? kShowAlpha : kHideAlpha)];
	}
}


NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

-(NSString *) randomLetter {
	unichar character = [letters characterAtIndex: arc4random()%[letters length]];
    return [NSString stringWithFormat:@"%C", character];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)configButton:(id)sender {
	
	CGRect clockViewFrame = self.clockView.frame;
    
	if (clockViewFrame.origin.x == 0)
	{
		
		clockViewFrame.origin.x = 250;
	}
	else
	{
		clockViewFrame.origin.x = 0;
	}
	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
    self.clockView.frame = clockViewFrame;
	
    [UIView commitAnimations];

}

- (void)rotaryChooserDidChangeSelectedSegment:(TPTRotaryChooser *)chooser
{
	NSLog(@"changing");
	if (chooser.tag == 100)
	{
		[self setForgroundColor:[forgroundColors objectAtIndex:chooser.currentSegment]];
	}
}

- (void)rotaryChooserDidSelectedSegment:(TPTRotaryChooser *)chooser
{
	NSLog(@"selected");
	if (chooser.tag == 100)
	{
		[self setForgroundColor:[forgroundColors objectAtIndex:chooser.selectedSegment]];
	}
	else if (chooser.tag == 200)
	{
		[self.clockBackground setBackgroundColor:[backgroundColors objectAtIndex:chooser.selectedSegment]];
	}
}


@end
