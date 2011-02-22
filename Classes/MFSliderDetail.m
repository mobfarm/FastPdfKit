//
//  ThumbnailViewController.m
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import "MFSliderDetail.h"


@implementation MFSliderDetail
@synthesize delegate, object, temp, dataSource, corner;

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)aPage andImage:(NSString *)_image andSize:(CGSize)_size andObject:(id)_object andDataSource:(id)_source{
	// NSLog(@"Init with page: %i", aPage);
	[self setObject:_object];
	size = _size;
	thumbnail = _image;
	page = aPage+1;
	temp = NO;
	dataSource = _source;
	return self;
}

- (id)initWithPageNumberNoThumb:(int)aPage andImage:(NSString *)_image andSize:(CGSize)_size andObject:(id)_object andDataSource:(id)_source{
	[self setObject:_object];
	size = _size;
	thumbnail = _image;
	page = aPage+1;	
	temp = YES;
	dataSource = _source;
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// NSLog(@"Did load Page %i", page);
	//[self.view setBackgroundColor:[UIColor clearColor]];
	
	[self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
	if (temp) {
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[spinner setFrame:CGRectMake(size.width/2.0 - spinner.frame.size.width/2.0, size.height/2.0 - spinner.frame.size.height/2.0, spinner.frame.size.width, spinner.frame.size.height)];
		[spinner startAnimating];
		[self.view addSubview:spinner];
		[spinner release];
		
		
		// image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, size.width-10, size.height-10)]; // Fissare dimensioni
		// [image setImage:[UIImage imageNamed:thumbnail]];
		// [image setUserInteractionEnabled:YES];
		// [self.view addSubview:image];
		// [image release];
		
	} else {
		UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, size.width-10, size.height-10)]; // Fissare dimensioni
		// NSLog(@"%f, %f", self.view.frame.origin.x, self.view.frame.origin.y);
		[image setImage:[UIImage imageWithContentsOfFile:thumbnail]];
		//[image setImage:[UIImage imageNamed:thumbnail]];
		[image setUserInteractionEnabled:YES];
		[self.view addSubview:image];
		[image release];
		
		
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			/*UIImageView *color = [[UIImageView alloc] initWithFrame:CGRectMake(size.width-34, 3, 31, 31)];
			//NSString *name = [NSString stringWithFormat:@"%iMarkS.png", [[self dataSource] getColorForPage:page]];
			// NSLog(@"Name: %@", name);
			[color setImage:[UIImage imageNamed:name]];
			[color setUserInteractionEnabled:YES];
			[self setCorner:color];
			[color release];
			[self.view addSubview:corner];*/
			
			UILabel *pageLabel = [[UILabel alloc ] initWithFrame:CGRectMake(10, 84, size.width-30, size.height-30) ];
			pageLabel.textAlignment =  UITextAlignmentCenter;
			pageLabel.textColor = [UIColor whiteColor];
			pageLabel.backgroundColor = [UIColor clearColor];
			pageLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(21.0)];
			NSString *titlelabel = [NSString stringWithFormat:@"%i",page];
			[pageLabel setText:titlelabel]; 
			[self.view addSubview:pageLabel];
			[pageLabel release];
		}else {
			
			/*UIImageView *color = [[UIImageView alloc] initWithFrame:CGRectMake(size.width-17, 3, 15, 15)];
			//NSString *name = [NSString stringWithFormat:@"%iMarkS.png", [[self dataSource] getColorForPage:page]];
			// NSLog(@"Name: %@", name);
			[color setImage:[UIImage imageNamed:name]];
			[color setUserInteractionEnabled:YES];
			[self setCorner:color];
			[color release];
			[self.view addSubview:corner];*/
			
			UILabel *pageLabel = [[UILabel alloc ] initWithFrame:CGRectMake(12, 40, size.width-30, size.height-30) ];
			pageLabel.textAlignment =  UITextAlignmentCenter;
			pageLabel.textColor = [UIColor whiteColor];
			pageLabel.backgroundColor = [UIColor clearColor];
			pageLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(10.0)];
			NSString *titlelabel = [NSString stringWithFormat:@"%i",page];
			[pageLabel setText:titlelabel]; 
			[self.view addSubview:pageLabel];
			[pageLabel release];
		}	
	}
	[super viewDidLoad];
}

- (void)updateCorner{
	// NSLog(@"Update Corner for page %i", page);
	//NSString *name = [NSString stringWithFormat:@"%iMarkS.png", [[self dataSource] getColorForPage:page]];
	//[corner setImage:[UIImage imageNamed:name]];
}

- (void)setSelected:(BOOL)selected{
	/*
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationDelegate:self];
	if (selected && border.alpha == 0.0) {
		border.alpha = 1.0;
	} else if (!selected && border.alpha == 1.0){
		border.alpha = 0.0;
	}
    [UIView commitAnimations];
	*/  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	NSSet *allTouches = [event allTouches];
	
	switch ([allTouches count]) {
		case 1: { //Single touch
			
			//Get the first touch.
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			
			switch ([touch tapCount])
			 {
				 case 1: {	//Single Tap.
					 [self.delegate thumbTapped:page withObject:object];
					 [self setSelected:YES];
					} break;
				 case 2: {	//Double tap.
					 
				 } break;
			 }
		} break;
		case 2: { //Double Touch
			
		} break;
		default:
			break;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[corner release];
	[self.view removeFromSuperview];
	// NSLog(@"Dealloc page %i", page);
	// [[[self.view subviews] objectAtIndex:0] removeFromSuperview];
	// [image release];
    [super dealloc];
}


@end
