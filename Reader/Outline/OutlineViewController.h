//
//  OutlineViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutlineViewControllerDelegate.h"

@interface OutlineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

	NSMutableArray *outlineEntries;
	NSMutableArray *openOutlineEntries;
	
	NSObject<OutlineViewControllerDelegate> *__weak delegate;
	
	IBOutlet UITableView *outlineTableView;
}

-(IBAction)actionBack:(id)sender;

@property (nonatomic, strong) NSArray *outlineEntries;
@property (nonatomic, strong) NSArray *openOutlineEntries;
@property (nonatomic, strong) IBOutlet UITableView *outlineTableView;
@property (weak) NSObject<OutlineViewControllerDelegate> *delegate;
@end
