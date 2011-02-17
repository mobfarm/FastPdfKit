    //
//  BookmarkViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "BookmarkViewController.h"
#import "DocumentViewController.h"

@implementation BookmarkViewController
@synthesize editButton, bookmarksTableView;
@synthesize delegate;
@synthesize bookmarks;

-(IBAction)actionDone:(id)sender {
	
	//[[self delegate]actionBookmarks:self];
	[[self delegate]dismissAllPopoversFrom:self];
}

-(IBAction)actionToggleMode:(id)sender {

	if(status == STATUS_NORMAL) {
		
		[editButton setStyle:UIBarButtonSystemItemBookmarks];
		[bookmarksTableView setEditing:YES];
		
	} else if (status == STATUS_EDITING) {
		
		
		[editButton setStyle:UIBarButtonSystemItemEdit];
		[bookmarksTableView setEditing:NO];
		
	}
	
}

-(IBAction)actionAddBookmark:(id)sender {
	
	NSUInteger currentPage = [delegate page];
	
	[bookmarks addObject:[NSNumber numberWithUnsignedInt:currentPage]];
	
	[bookmarksTableView reloadData];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		status = STATUS_NORMAL;
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//
//	Here we recover the bookmarks from the userdefaults. While this is fine for an application with a single 
//	pdf document, you probably want to store them in coredata or some other way and bind them to a specific document
//	by setting or passing to this viewcontroller an identifier for the document or tell a delegate to load/save
//	them for us.
	
	NSMutableArray *aBookmarksArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"bookmarks"];
	if(nil == aBookmarksArray) {
		aBookmarksArray = [[NSMutableArray alloc]init];
		[[NSUserDefaults standardUserDefaults]setObject:aBookmarksArray forKey:@"bookmarks"];
	}
	[self setBookmarks:aBookmarksArray];
	
	[bookmarksTableView reloadData];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// 
//	Get the right page number from the array
	NSUInteger index = indexPath.row;
	NSNumber *pageNumber = [bookmarks objectAtIndex:index];
	NSUInteger page = [pageNumber unsignedIntValue];

	//
//	Dismiss this modal view controller and tell the delegate to show the requested page number. Consider
// implementing a documentDelegate interface that handle such kind of request
	[delegate setPage:page];
	[[self parentViewController]dismissModalViewControllerAnimated:YES];
	
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger index = indexPath.row;
		[bookmarks removeObjectAtIndex:index];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	
	NSInteger count = [bookmarks count];
	return count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"bookmarkCell";
	
	NSNumber *pageNumber = [bookmarks objectAtIndex:[indexPath row]];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId]autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	[[cell textLabel]setText:[NSString stringWithFormat:@"Page %u",[pageNumber unsignedIntValue]]];
	
	return cell;
	
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {

	[bookmarksTableView release];
	[editButton release];
	
	[bookmarks release];
	
    [super dealloc];
}


@end
