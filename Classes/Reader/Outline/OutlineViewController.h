//
//  OutlineViewController.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 8/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutlineViewControllerDelegate.h"

@interface OutlineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(IBAction)actionBack:(id)sender;

@property (nonatomic, retain) NSMutableArray *outlineEntries;
@property (nonatomic, retain) NSMutableArray *openOutlineEntries;
@property (nonatomic, retain) IBOutlet UITableView *outlineTableView;
@property (weak, nonatomic) id<OutlineViewControllerDelegate> delegate;
@end
