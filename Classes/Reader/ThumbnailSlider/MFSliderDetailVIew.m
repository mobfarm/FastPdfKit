//
//  MFSliderDetailVIew.m
//  FastPdfKit Sample
//
//  Created by Nicolò Tosi on 7/7/11.
//  Copyright 2011 MobFarm S.r.L. All rights reserved.
//

#import "MFSliderDetailVIew.h"


@implementation MFSliderDetailVIew

@synthesize pageNumberLabel, pageNumber;
@synthesize thumbnailImagePath, thumbnailView;
@synthesize delegate;
@synthesize activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        
        UIActivityIndicatorView * anActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        anActivityIndicatorView.frame = CGRectMake(frame.size.width * 0.5 - anActivityIndicatorView.frame.size.width * 0.5, frame.size.height * 0.5 - anActivityIndicatorView.frame.size.height * 0.5, anActivityIndicatorView.frame.size.width, anActivityIndicatorView.frame.size.height);
        anActivityIndicatorView.hidesWhenStopped = YES;
        
        [self addSubview:anActivityIndicatorView];
        [anActivityIndicatorView startAnimating];
        
        self.activityIndicator = anActivityIndicatorView;
        [anActivityIndicatorView release];
        
    }
    return self;
}

-(void)layoutPageNumberLabel {
    
    CGRect bounds = self.bounds;
    
    if(pageNumber) {
        
        NSString *labelText = [NSString stringWithFormat:@"%i",[pageNumber intValue]];
        
        if(!pageNumberLabel) {
            
            UILabel *aLabel = nil;
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // Pad.
                
                aLabel = [[UILabel alloc ] initWithFrame:CGRectMake(20, 138, 60, 15) ];
                aLabel.textAlignment =  UITextAlignmentCenter;
                aLabel.textColor = [UIColor whiteColor];
                aLabel.backgroundColor = [UIColor clearColor];
                aLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(20.0)];
                
            } else { // Phone.
                
                aLabel = [[UILabel alloc ] initWithFrame:CGRectMake(6, 57, 40, 15) ];
                aLabel.textAlignment =  UITextAlignmentCenter;
                aLabel.textColor = [UIColor whiteColor];
                aLabel.backgroundColor = [UIColor clearColor];
                aLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(9.0)];
                
            }	
            
            self.pageNumberLabel = aLabel;
            [self addSubview:aLabel];
            [aLabel release];
        }
     
        pageNumberLabel.text = labelText;
        pageNumberLabel.hidden = NO;
        
    } else {
        
        pageNumberLabel.hidden = YES;
        
    }

}

-(void)layoutSubviews {
    
    CGRect bounds = self.bounds;
    
    // If there's a path, present the label and the image view, otherwise present the spinner.
    
    if(thumbnailImagePath) {
        
        activityIndicator.hidden = YES;
        
        // Calculate the image view frame and get the image that will act as content.
        
        CGRect imageViewRect = CGRectMake(5, 3, bounds.size.width-10, bounds.size.height-6);
        UIImage * imageViewImage = [UIImage imageWithContentsOfFile:thumbnailImagePath];
        
        if(!thumbnailView) { // Prepare the subview if it does not exist yet.
            
            UIImageView * anImageView = [[UIImageView alloc]initWithFrame:imageViewRect];
            anImageView.backgroundColor = [UIColor clearColor];
            anImageView.userInteractionEnabled = YES;
            
            self.thumbnailView = anImageView;
            
            [self addSubview:anImageView];
            
            [anImageView release];
        }
        
        // Set the image view frame and content, then show it (ignored if already shown).
        
        thumbnailView.image = imageViewImage;
        thumbnailView.frame = imageViewRect;
        thumbnailView.hidden = NO;
        
        // Layout the page number label.
        
        [self layoutPageNumberLabel];
              
        
    } else {
        
        thumbnailView.hidden = YES;
        
        [self layoutPageNumberLabel];
        
        CGRect spinnerRect = CGRectMake(bounds.size.width * 0.5 - activityIndicator.frame.size.width * 0.5, bounds.size.height * 0.5 - activityIndicator.frame.size.height * 0.5, activityIndicator.frame.size.width, activityIndicator.frame.size.height);
        self.activityIndicator.frame = spinnerRect;
        [activityIndicator startAnimating];
        
    }
}

-(void)setPageNumber:(NSNumber *)newPageNumber {
    
    if(newPageNumber!=pageNumber) {
        
        [pageNumber release];
        pageNumber = [newPageNumber retain];
        
        [self setNeedsLayout];
    }
}

-(void)setThumbnailImagePath:(NSString *)newThumbnailImagePath {
    
    if(thumbnailImagePath!=newThumbnailImagePath) {
        
        [thumbnailImagePath release];
        thumbnailImagePath = [newThumbnailImagePath copy];
        
        [self setNeedsLayout];
    }
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
                    [self.delegate thumbTapped:[pageNumber intValue] withObject:self];
                    //[self setSelected:YES];
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    delegate = nil;
    
    [thumbnailImagePath release];
    [thumbnailView release];
    
    [activityIndicator release];
    
    [pageNumberLabel release];
    [pageNumber release];
    
    [super dealloc];
}

@end
