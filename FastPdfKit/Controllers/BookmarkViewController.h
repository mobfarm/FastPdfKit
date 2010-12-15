//
//  BookmarkViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STATUS_NORMAL 0
#define STATUS_EDITING 1

@class DocumentViewController;

@interface BookmarkViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	IBOutlet UIBarButtonItem *editButton;
	IBOutlet UITableView *bookmarksTableView;
	
	NSUInteger status;
	NSMutableArray *bookmarks;
	
	//
//	Delegate to get the current page and tell to show a certain page. It can also be used to
//	get a list of bookmarks for the current document. 
	DocumentViewController *delegate;
	
}

-(IBAction)actionToggleMode:(id)sender;
-(IBAction)actionAddBookmark:(id)sender;
-(IBAction)actionDone:(id)sender;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UITableView *bookmarksTableView;

@property (nonatomic, retain) NSMutableArray *bookmarks;
@property (nonatomic, assign) DocumentViewController *delegate;

@end
