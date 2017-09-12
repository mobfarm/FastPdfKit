//
//  TextDisplayViewController.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 10/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextDisplayViewControllerDelegate.h"

@class DocumentViewController;
@interface TextDisplayViewController : UIViewController

-(IBAction)actionBack:(id)sender;
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,retain) UITextView *textView;
@property (nonatomic,retain) MFDocumentManager *documentManager;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,weak) id<TextDisplayViewControllerDelegate>delegate;
-(void)clearText;
-(void)updateWithTextOfPage:(NSUInteger)page;

@end
