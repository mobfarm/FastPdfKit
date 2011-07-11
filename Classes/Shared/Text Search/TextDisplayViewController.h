//
//  TextDisplayViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextDisplayViewControllerDelegate.h"

@class DocumentViewController;
@interface TextDisplayViewController : UIViewController {

	IBOutlet UIActivityIndicatorView *activityIndicatorView;
	IBOutlet UITextView *textView;
	
	NSObject<TextDisplayViewControllerDelegate> *delegate;
	
	NSString *text;
	
	MFDocumentManager *documentManager;
}

-(IBAction)actionBack:(id)sender;
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,retain) UITextView *textView;
@property (nonatomic,retain) MFDocumentManager *documentManager;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,assign) NSObject<TextDisplayViewControllerDelegate> *delegate;
-(void)clearText;
-(void)updateWithTextOfPage:(NSUInteger)page;

@end
