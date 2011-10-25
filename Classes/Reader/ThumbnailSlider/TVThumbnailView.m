//
//  MFSliderDetailVIew.m
//  FastPdfKit Sample
//
//  Created by Nicolò Tosi on 7/7/11.
//  Copyright 2011 MobFarm S.a.s.. All rights reserved.
//

#import "TVThumbnailView.h"


@implementation TVThumbnailView

@synthesize pageNumberLabel, pageNumber;
@synthesize thumbnailImagePath, thumbnailView;
@synthesize delegate;
@synthesize activityIndicator;
@synthesize position;
@synthesize thumbnailImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        
        UIActivityIndicatorView * anActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        anActivityIndicatorView.frame = CGRectMake((frame.size.width - anActivityIndicatorView.frame.size.width) * 0.5, (frame.size.height - anActivityIndicatorView.frame.size.height) * 0.5, anActivityIndicatorView.frame.size.width, anActivityIndicatorView.frame.size.height);
        anActivityIndicatorView.hidesWhenStopped = YES;
        
        [self addSubview:anActivityIndicatorView];
        [anActivityIndicatorView startAnimating];
        
        self.activityIndicator = anActivityIndicatorView;
        [anActivityIndicatorView release];
        
    }
    return self;
}

-(void)layoutPageNumberLabel {
    
    // CGRect bounds = self.bounds;
    
    if(pageNumber) {
        
        NSString *labelText = [NSString stringWithFormat:@"%i",[pageNumber intValue]];
        
        if(!pageNumberLabel) {
            
            UILabel *aLabel = nil;
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // Pad.
                
                aLabel = [[UILabel alloc ] initWithFrame:CGRectMake(20, 120, 60, 15) ];
                aLabel.textAlignment =  UITextAlignmentCenter;
                aLabel.textColor = [UIColor whiteColor];
                aLabel.backgroundColor = [UIColor clearColor];
                aLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(20.0)];
                
            } else { // Phone.
                
                aLabel = [[UILabel alloc ] initWithFrame:CGRectMake(6, 50, 40, 15) ];
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

+(CGRect)frameForImageView:(CGSize)size {
    
    return CGRectMake(5, 10, size.width-10, size.height-20);
}

-(void)layoutSubviews {
    
    /*
     If there's an associated image, present it as thumbnail, otherwise show the
     activity indicator. In both case, layout the label since the page number
     is always displayed at the bottom of the view.
     */
    
    CGRect bounds = self.bounds;
    CGRect imageViewFrame;
    UIImageView * anImageView = nil;
    CGRect spinnerFrame;
    
    if(thumbnailImage) {
        
        activityIndicator.hidden = YES;
        
        // Calculate the image view frame.
        
        imageViewFrame = [TVThumbnailView frameForImageView:bounds.size];
        
        if(!thumbnailView) { // Prepare the subview if it does not exist yet.
            
            anImageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
            anImageView.backgroundColor = [UIColor clearColor];
            anImageView.userInteractionEnabled = YES;
            
            self.thumbnailView = anImageView;
            
            [self addSubview:anImageView];
            
            [anImageView release];
        }
        
        // Set the image view frame and content, then show it (ignored if already shown).
        
        thumbnailView.image = thumbnailImage;
        thumbnailView.frame = imageViewFrame;
        thumbnailView.hidden = NO;
        
        [self layoutPageNumberLabel]; // Layout the page number label.
        
    } else {
        
        thumbnailView.hidden = YES;
        
        [self layoutPageNumberLabel]; // Layout the page number label.
        
        spinnerFrame = CGRectMake(bounds.size.width * 0.5 - activityIndicator.frame.size.width * 0.5, bounds.size.height * 0.5 - activityIndicator.frame.size.height * 0.5, activityIndicator.frame.size.width, activityIndicator.frame.size.height);
        self.activityIndicator.frame = spinnerFrame;
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


-(void)loadThumbImg:(NSString *)path {
    
    // Do this IO operation on background thread.
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    UIImage * image = [[UIImage alloc]initWithContentsOfFile:path];
    
    // If we got an image from the disk, set it as the current image.
    
    if(image) {
        [self performSelectorOnMainThread:@selector(setThumbnailImage:) withObject:image waitUntilDone:NO];
    }
    
    // Cleanup.
    
    [image autorelease];
    [pool release];
}

-(void)setThumbnailImage:(UIImage *)newThumbnailImage {
    if(thumbnailImage!=newThumbnailImage) {
        [thumbnailImage release];
        thumbnailImage = [newThumbnailImage retain];
        [self setNeedsLayout];
    }
}

-(void)reloadImage:(UIImage *)image {
    
    /* This will stop the background request to check and load the thumbnail 
     image and rather set the image directly */
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadThumbImg:) object:thumbnailImagePath];
    
    [self setThumbnailImage:image];
    
    // [self performSelectorInBackground:@selector(loadThumbImg:) withObject:thumbnailImagePath]; // OLD.  
}

-(void)setThumbnailImagePath:(NSString *)newThumbnailImagePath {
    
    /*
     This might seem tricky, but it is rather straightforward: if the thumbnail
     path passed as argument is different than the current one it is time to
     check for a new thumbnail image. This mean we have to set the current image
     to nil - so it won't be displayed upon redraw - and invoke the thumbnail
     loading function on a separate thread, since it will perform an IO 
     operation. The method will eventually load the image from disk and update
     */
    
    if(thumbnailImagePath!=newThumbnailImagePath) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadThumbImg:) object:thumbnailImagePath];
        
        [thumbnailImagePath release];
        thumbnailImagePath = [newThumbnailImagePath copy];
        [self setThumbnailImage:nil];
        
        // [self setNeedsLayout]; // Redundant, included in setThumbnailImage.
        
        [self performSelectorInBackground:@selector(loadThumbImg:) withObject:thumbnailImagePath];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
    
    // TODO: use gesture recognizer instead.
    
	NSSet *allTouches = [event allTouches];
	
	switch ([allTouches count]) {
		case 1: { //Single touch
			
			//Get the first touch.
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			
			switch ([touch tapCount])
            {
                case 1: {	//Single Tap.
                    [self.delegate thumbTapped:position withObject:self];
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

- (void)dealloc
{
    delegate = nil;
    
    [thumbnailImagePath release];
    [thumbnailView release];
    
    [activityIndicator release];
    
    [pageNumberLabel release];
    [pageNumber release];
    
    [thumbnailImage release];
    
    [super dealloc];
}

@end
