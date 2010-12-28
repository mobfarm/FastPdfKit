//
//  TextDisplayViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentViewController;
@interface TextDisplayViewController : UIViewController {

	IBOutlet UIActivityIndicatorView *activityIndicatorView;
	IBOutlet UITextView *textView;
	
	DocumentViewController *delegate;
	
	NSString *text;
}

-(IBAction)actionBack:(id)sender;
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,retain) UITextView *textView;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,assign) DocumentViewController *delegate;
-(void)clearText;
-(void)updateWithTextOfPage:(NSUInteger)page;

@end
