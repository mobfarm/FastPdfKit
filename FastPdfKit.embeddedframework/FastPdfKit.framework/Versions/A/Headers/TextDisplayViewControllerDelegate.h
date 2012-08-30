//
//  TextDisplayViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDocumentManager.h"

@class TextDisplayViewController;

@protocol TextDisplayViewControllerDelegate

-(MFDocumentManager	*)document;
-(void)dismissTextDisplayViewController:(TextDisplayViewController *)controller;

@end
