//
//  BookmarkViewController.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarkViewControllerDelegate.h"

#define STATUS_NORMAL 0
#define STATUS_EDITING 1

@class DocumentViewController;

@interface BookmarkViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(IBAction)actionToggleMode:(id)sender;
-(IBAction)actionAddBookmark:(id)sender;
-(IBAction)actionDone:(id)sender;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UITableView *bookmarksTableView;

@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (nonatomic, weak) id<BookmarkViewControllerDelegate>delegate;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@end
