//
//  MoveViewController.m
//  ViewResizingTest
//
//  Created by Nicolò Tosi on 7/14/11.
//  Copyright 2011 MobFarm S.r.l.. All rights reserved.
//

#import "MoveViewController.h"

#define kDocumentFrameWidth 600
#define kDocumentFrameHeight 450

#define kDocumentFrameWidthSmall 400
#define kDocumentFrameHeightSmall 300

#define kPositionUpperLeft 0
#define kPositionUpperRight 1
#define kPositionBottomRight 2
#define kPositionBottomLeft 3

#define NextPositionFromPosition(x) (((x)+1)%4)

@interface MoveViewController()

-(void)actionMoveView;

@end

static NSString * const AlertViewText = @"This is might happen if view controller's view lifecycle messages are not forwarded properly when the MFDocumentViewController's view is added as a subview of another view. If the MFDocumentViewController is added to a navigation stack or presented modally there are no such problems. Check the -viewDidLoad and -actionMoveView methods for details.";

@implementation MoveViewController

@synthesize documentManager, documentViewController;
@synthesize alertTextView;

/**
 This method is rather simple and it simply move the document view controller across the four edges of the screen. It's just take the current
 document's view position, calculate the next position and set up both the frame and the autoresizing mask of the MFDocumentController's view 
 accordingly. The autoreszing mask is crucial, otherwise we will not get the proper behavior upon rotation.
 On the bottom left position, we also change the frame size. MFDocumentViewController is not set up to allow to change the frame esplicitely, however
 you can bypass this to wrap the change with -willRotateToInterfaceOrientation:duration: and -didRotateToInterfaceOrientation: messages. Consider them
 as aliases for hypothetical -willChangeFrameSize and -didChangeFrameSize methods. If you do not, click the button a fourth time and see what happens.
 When the MFDocumentViewController will become an FPKDocumentView things will get much streamlined.
 */
-(void)actionMoveView {
    
    
    NSUInteger nextPosition = NextPositionFromPosition(documentPosition);
    
    CGRect bounds = self.view.bounds;
    
    switch (nextPosition) {
        
        case kPositionUpperRight :
            
            alertTextView.hidden = YES;
            documentViewController.view.frame = CGRectMake(bounds.size.width - kDocumentFrameWidth - 20, 20, kDocumentFrameWidth, kDocumentFrameHeight);
            documentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
            break;
            
        case kPositionBottomRight:
            
            documentViewController.view.frame = CGRectMake(bounds.size.width - kDocumentFrameWidth - 20, bounds.size.height - kDocumentFrameHeight - 20, kDocumentFrameWidth, kDocumentFrameHeight);
            documentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
            break;
            
        case kPositionBottomLeft:
            
            // Wrap the frame size change with the rotation methods.
            
            [documentViewController willRotateToInterfaceOrientation:[[UIDevice currentDevice]orientation] duration:0.0];
            documentViewController.view.frame = CGRectMake(20, bounds.size.height - kDocumentFrameHeightSmall - 20, kDocumentFrameWidthSmall,kDocumentFrameHeightSmall);
            [documentViewController didRotateFromInterfaceOrientation:[[UIDevice currentDevice]orientation]];
            
            documentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
            
            break;
            
        case kPositionUpperLeft: // Go back the the first position.
            
            // Another resizing here. Wrapper methods are commented: uncomment them to fix the issue.
            
            // [documentViewController willRotateToInterfaceOrientation:[[UIDevice currentDevice]orientation] duration:0.0];
            alertTextView.hidden = NO;
            documentViewController.view.frame = CGRectMake(20, 20, kDocumentFrameWidth, kDocumentFrameHeight);
            documentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
            
            // [documentViewController didRotateFromInterfaceOrientation:[[UIDevice currentDevice]orientation]];
            
            break;
            
        default:
            break;
    }
    
    documentPosition = nextPosition;
}

/**
 THIS IS CRITICAL (I guess)
 Actually, I don't remember if didReceiveMemoryWarning are properly forwarded if the controller is not on a stack. Just send the message to the
 instance of MFDocumentViewController just in case. I'll check later.
 */
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [documentViewController didReceiveMemoryWarning];
}

#pragma mark - View lifecycle


/**
 We just set up a light gray view as this UIViewController's view and add a button in the middle of it. The autoresizing mask of the view
 is not important, but the autoresizeSubviews parameter is necessary to let it automatically move our subviews upon rotation or bounds
 change. Since we want the button to stay in the middle, we set its auroresizing mask to keep its size but allow to keep the position along
 both axis.
 */
- (void)loadView {

    
    UIView * aView = nil;           // This will become this UIViewController's view.
    UIButton *aButton = nil;        // Move! button.
    UITextView * aTextView = nil;   // Text view with some explanation of what is happening.
    
    aView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 768, 1004)]; // Usual size and position for a pad view with status bar at the top.
    aView.autoresizesSubviews = YES;
    aView.backgroundColor = [UIColor lightGrayColor];

    aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    aButton.frame = CGRectMake(((768-60)*0.5), ((1004-30)*0.5), 60, 30);
    [aButton setTitle:@"Move!" forState:UIControlStateNormal];
    aButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    [aButton addTarget:self action:@selector(actionMoveView) forControlEvents:UIControlEventTouchUpInside]; // The actionMoveView is just going to change the frame of the MFDocumentViewController view that will be added in the viewDidLoad method.
    
    
    aTextView = [[UITextView alloc]initWithFrame:CGRectMake(768-300-40, 1004-300-40, 300, 300)];
    aTextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    aTextView.text = AlertViewText;
    aTextView.hidden = YES;
    aTextView.backgroundColor = [UIColor clearColor];
    aTextView.font = [UIFont systemFontOfSize:[UIFont labelFontSize]]; // Larger font than standard.
    self.alertTextView = aTextView;
    
    [aView addSubview:aTextView];
    [aView addSubview:aButton];
    
    self.view = aView;
    
    [aTextView release];
    [aView release];
}



/**
 THIS IS IMPORANT!
 Here we will prepare the MFDocumentViewController and add its view as a subview of this UIViewController's view.
 Methods like viewDidLoad, viewWillAppear and viewDidApper method are required for the proper functioning of the MFDocumentViewController. However,
 those methods are not forwarded if the document view controller is not on a navigation stack or presented as a modal view controller, like in the 
 case of this simple application. Thus, you should manually notify the controller that its view is going to appear on the screen. If the main
 controller is sent back to the stack, you should also manager willDisappear method accordingly (didDisappear is not used at this time, so you can safely
 ignore it for now).
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // First, let's check if the documentviewcontroller is already there. If not, we create the document manager and set up the MFDocumentViewController
    // as always.
    
    if(!documentViewController) {
        
        MFDocumentViewController * docController;
        MFDocumentManager * docManager;
        
        docManager = [[MFDocumentManager alloc]initWithFileUrl:[[NSBundle mainBundle]URLForResource:@"FastPdfKit-1.0RC1" withExtension:@"pdf"]];
        docController = [[MFDocumentViewController alloc]initWithDocumentManager:docManager];
        [docController setAutomodeOnRotation:YES];
        
        self.documentManager = docManager;
        self.documentViewController = docController;
        
        [docManager release];
        [documentViewController release];
    }
    
    // Now set up the MFDocumentViewController's view position to the upper left.
    
    documentPosition = kPositionUpperLeft;
    documentViewController.view.frame = CGRectMake(20, 20, kDocumentFrameWidth, kDocumentFrameHeight);
    documentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    
    documentViewController.view.backgroundColor = [UIColor darkGrayColor]; // Just a background color with a little more contrast.
    

    // Here we forward the required message to the MFDocumentViewController.
    [documentViewController viewDidLoad];
    [self.view insertSubview:documentViewController.view atIndex:0];

}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [documentViewController viewWillAppear:animated]; // Forward the message.
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [documentViewController viewDidAppear:animated]; // Forward the message.    
}

-(void)viewWillDisappear:(BOOL)animated {
 
    [super viewWillDisappear:animated];
    [documentViewController viewWillDisappear:animated]; // Forward the message.
}

/**
 We will use the viewDidUnload to dismantle the documentViewController. If your controller is going in background and then back to the top of the stack,
 this method will be called if a memory warning occurs and when the view will load again the MFDocumentViewController will not work. If this is your
 case, set up a dismiss callback and call -cleanUp there rather than here.
 */
- (void)viewDidUnload {
    [super viewDidUnload];
    
    [documentViewController cleanUp];
}


/**
 In this sample, we set the -autoModeOnRotation property of the MFDocumentViewController to YES to let it auto handle rotation changes. You can also
 set it to NO and change page mode manually when required.
 */
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [documentViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [documentViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc
{
 
    [alertTextView release];
    [documentViewController release], documentViewController = nil;
    [documentManager release], documentManager = nil;
    [super dealloc];
}

@end
