//
//  MenuViewController.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 8/26/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFDocumentManager;

@interface MenuViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *referenceButton;
@property (nonatomic, weak) IBOutlet UIButton *manualButton;
@property (nonatomic, weak) IBOutlet UITextView *referenceTextView;
@property (nonatomic, weak) IBOutlet UITextView *manualTextView;

@property (nonatomic, strong) MFDocumentManager *document;


@end
