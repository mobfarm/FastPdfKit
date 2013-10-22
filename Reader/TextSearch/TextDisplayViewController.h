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
	
	NSObject<TextDisplayViewControllerDelegate> *__weak delegate;
	
	NSString *text;
	
	MFDocumentManager *documentManager;
}

-(IBAction)actionBack:(id)sender;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) MFDocumentManager *documentManager;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,weak) NSObject<TextDisplayViewControllerDelegate> *delegate;
-(void)clearText;
-(void)updateWithTextOfPage:(NSUInteger)page;

@end
