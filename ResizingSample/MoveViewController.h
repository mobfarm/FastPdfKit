//
//  MoveViewController.h
//  ViewResizingTest
//
//  Created by Nicolò Tosi on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDocumentManager.h"
#import "MFDocumentViewController.h"

@interface MoveViewController : UIViewController {
    
    MFDocumentManager * documentManager;
    MFDocumentViewController * documentViewController;
    
    UITextView * alertTextView;
    
    NSUInteger documentPosition;
}

@property (nonatomic,retain) MFDocumentManager * documentManager;
@property (nonatomic,retain) MFDocumentViewController * documentViewController;
@property (nonatomic,retain) UITextView * alertTextView;

@end
