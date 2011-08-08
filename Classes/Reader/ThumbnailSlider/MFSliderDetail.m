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

// Load the view and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)aPage andImage:(NSString *)_image andSize:(CGSize)_size andObject:(id)_object andDataSource:(id)_source{
	[self setObject:_object];
	
	size = _size; //size of the thumb
	thumbnail = _image; //path of image
	page = aPage+1; //number of page : set +1 because page 0 on pdf not exists
	temp = NO;
	dataSource = _source;
	return self;
}

- (id)initWithPageNumberNoThumb:(int)aPage andImage:(NSString *)_image andSize:(CGSize)_size andObject:(id)_object andDataSource:(id)_source{
	//not used
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
    
    [super viewDidLoad];
    
	[self.view setBackgroundColor:[UIColor clearColor]];
	
	if (temp) {
		//if thumb is not created show a spinner
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[spinner setFrame:CGRectMake(size.width/2.0 - spinner.frame.size.width/2.0, size.height/2.0 - spinner.frame.size.height/2.0, spinner.frame.size.width, spinner.frame.size.height)];
		[spinner startAnimating];
		[self.view addSubview:spinner];
		[spinner release];
		
	} else {
		//set the image
		UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 3, size.width-10, size.height-10)]; // dimension of image
		[image setImage:[UIImage imageWithContentsOfFile:thumbnail]];
		[image setBackgroundColor:[UIColor clearColor]];
		[image setUserInteractionEnabled:YES];
		[self.view addSubview:image];
		[image release];
		
		
		//set the label with the number of pages
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			//ipad
			UILabel *pageLabel = [[UILabel alloc ] initWithFrame:CGRectMake(20, 138, 60, 15) ];
			pageLabel.textAlignment =  UITextAlignmentCenter;
			pageLabel.textColor = [UIColor whiteColor];
			pageLabel.backgroundColor = [UIColor clearColor];
			pageLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(20.0)];
			NSString *titlelabel = [NSString stringWithFormat:@"%i",page];
			[pageLabel setText:titlelabel]; 
			[self.view addSubview:pageLabel];
			[pageLabel release];
		}else {
			//Iphone
			UILabel *pageLabel = [[UILabel alloc ] initWithFrame:CGRectMake(6, 57, 40, 15) ];
			pageLabel.textAlignment =  UITextAlignmentCenter;
			pageLabel.textColor = [UIColor whiteColor];
			pageLabel.backgroundColor = [UIColor clearColor];
			pageLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(9.0)];
			NSString *titlelabel = [NSString stringWithFormat:@"%i",page];
			[pageLabel setText:titlelabel]; 
			[self.view addSubview:pageLabel];
			[pageLabel release];
		}	
	}
}

- (void)updateCorner{
	//not used
}

- (void)setSelected:(BOOL)selected{
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
	//[self.view removeFromSuperview];
	[super dealloc];
}


@end
