//
//  OutlineViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutlineViewControllerDelegate.h"

@class DocumentViewController;

@interface OutlineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

	NSMutableArray *outlineEntries;
	NSMutableArray *openOutlineEntries;
	
	NSObject<OutlineViewControllerDelegate> *delegate;
	
	IBOutlet UITableView *outlineTableView;
}

-(IBAction)actionBack:(id)sender;

@property (nonatomic, retain) NSArray *outlineEntries;
@property (nonatomic, retain) NSArray *openOutlineEntries;
@property (nonatomic, retain) IBOutlet UITableView *outlineTableView;
@property (assign) NSObject<OutlineViewControllerDelegate> *delegate;
@end
