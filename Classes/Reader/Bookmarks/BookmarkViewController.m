    //
//  BookmarkViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "BookmarkViewController.h"
#import "DocumentViewController.h"
#import "ReaderViewController.h"

#define KEY_FROM_DOCUMENT_ID(doc_id) [NSString stringWithFormat:@"bookmarks_%@",(doc_id)]

@implementation BookmarkViewController
@synthesize editButton, bookmarksTableView;
@synthesize delegate;
@synthesize bookmarks;
@synthesize toolbar;


-(void)saveBookmarks {
	 NSString * documentId = [delegate documentId];
    [[NSUserDefaults standardUserDefaults]setObject:bookmarks forKey:KEY_FROM_DOCUMENT_ID(documentId)];

}

-(NSMutableArray *) loadBookmarks {
	
	NSString * documentId = [delegate documentId];
	NSMutableArray * bookmarksArray = nil;
	NSArray * storedBookmarks = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_FROM_DOCUMENT_ID(documentId)];
	if(storedBookmarks) {
		bookmarksArray = [[storedBookmarks mutableCopy]autorelease];
	} else {
		bookmarksArray = [NSMutableArray array];
	}
	
	return bookmarksArray;
	
}

-(void)enableEditing {
	
	NSMutableArray * items = [[toolbar items]mutableCopy];
    
	UIBarButtonItem * button = [items objectAtIndex:1];
	[button setTitle:@"Done"];
	
	[toolbar setItems:items];
	
    [bookmarksTableView setEditing:YES];
    status = STATUS_EDITING;
    [items release];
}

-(void)disableEditing {
    
	NSMutableArray * items = [[toolbar items]mutableCopy];
    
	UIBarButtonItem * button = [items objectAtIndex:1];
	[button setTitle:@"Edit"];
	
	[toolbar setItems:items];
	
    [bookmarksTableView setEditing:NO];
    status = STATUS_NORMAL;
    
    [items release];
}

-(IBAction)actionDone:(id)sender {

	if(status == STATUS_EDITING)
		[self disableEditing];
    
	[self saveBookmarks];
       
	[[self delegate]dismissBookmarkViewController:self];
}

-(IBAction)actionToggleMode:(id)sender {

	if(status == STATUS_NORMAL) {
		
		[self enableEditing];
        
	} else if (status == STATUS_EDITING) {
		[self disableEditing];
	}
}

-(IBAction)actionAddBookmark:(id)sender {
	
	NSUInteger currentPage = [delegate page];
	
	[bookmarks addObject:[NSNumber numberWithUnsignedInt:currentPage]];
	
    [self saveBookmarks];
    
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
    
	NSMutableArray *aBookmarksArray = [self loadBookmarks];
	
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
	
	[delegate bookmarkViewController:self didRequestPage:page];
	//[delegate setPage:page];
	//[delegate dismissBookmark:self];
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

	// 
    //	Get the right page number from the array
	NSUInteger index = indexPath.row;
	NSNumber *pageNumber = [bookmarks objectAtIndex:index];
	NSUInteger page = [pageNumber unsignedIntValue];
    
	//
    //	Dismiss this modal view controller and tell the delegate to show the requested page number. Consider
    // implementing a documentDelegate interface that handle such kind of request
	
	[delegate bookmarkViewController:self didRequestPage:page];
	//[delegate setPage:page];
	//[delegate dismissBookmark:self];
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
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
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

	[toolbar release], toolbar = nil;
	[bookmarksTableView release], bookmarksTableView = nil;
	[editButton release];
	
	[bookmarks release];
	
    [super dealloc];
}


@end
