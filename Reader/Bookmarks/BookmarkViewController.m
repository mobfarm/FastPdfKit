    //
//  BookmarkViewController.m
//  FastPdfKit
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "BookmarkViewController.h"
#import "ReaderViewController.h"

#define KEY_FROM_DOCUMENT_ID(doc_id) [NSString stringWithFormat:@"bookmarks_%@",(doc_id)]

@interface BookmarkViewController()
@property (nonatomic, readwrite) NSInteger status;
@end

@implementation BookmarkViewController

-(void)saveBookmarks {
	 NSString * documentId = [self.delegate documentId];
    [[NSUserDefaults standardUserDefaults]setObject:self.bookmarks forKey:KEY_FROM_DOCUMENT_ID(documentId)];

}

-(NSMutableArray *) loadBookmarks {
	
	NSString * documentId = [self.delegate documentId];
	NSMutableArray * bookmarksArray = nil;
	NSArray * storedBookmarks = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_FROM_DOCUMENT_ID(documentId)];
	if(storedBookmarks) {
        bookmarksArray = [storedBookmarks mutableCopy];
	} else {
		bookmarksArray = [NSMutableArray array];
	}
	
	return bookmarksArray;
	
}

-(void)enableEditing {
	
	NSMutableArray * items = [[self.toolbar items]mutableCopy];
    
	UIBarButtonItem * button = [items objectAtIndex:1];
	[button setTitle:@"Done"];
	
	[self.toolbar setItems:items];
	
    [self.bookmarksTableView setEditing:YES];
    self.status = STATUS_EDITING;
}

-(void)disableEditing {
    
	NSMutableArray * items = [[self.toolbar items]mutableCopy];
    
	UIBarButtonItem * button = [items objectAtIndex:1];
	[button setTitle:@"Edit"];
	
	[self.toolbar setItems:items];
	
    [self.bookmarksTableView setEditing:NO];
    self.status = STATUS_NORMAL;
}

-(IBAction)actionDone:(id)sender {

	if(self.status == STATUS_EDITING)
		[self disableEditing];
    
	[self saveBookmarks];
       
	[[self delegate]dismissBookmarkViewController:self];
}

-(IBAction)actionToggleMode:(id)sender {

	if(self.status == STATUS_NORMAL) {
		
		[self enableEditing];
        
	} else if (self.status == STATUS_EDITING) {
		[self disableEditing];
	}
}

-(IBAction)actionAddBookmark:(id)sender {
	
	NSUInteger currentPage = [self.delegate page];
	
	[self.bookmarks addObject:[NSNumber numberWithUnsignedInteger:currentPage]];
	
    [self saveBookmarks];
    
	[self.bookmarksTableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    //	Get the right page number from the array.
	NSUInteger index = indexPath.row;
	NSNumber *pageNumber = [self.bookmarks objectAtIndex:index];
	NSUInteger page = [pageNumber unsignedIntValue];
	
    // Inform the delegate which page we want.
	[self.delegate bookmarkViewController:self didRequestPage:page];
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    //	Get the right page number from the array.
	NSUInteger index = indexPath.row;
	NSNumber *pageNumber = [self.bookmarks objectAtIndex:index];
	NSUInteger page = [pageNumber unsignedIntValue];
    
    // Inform the delegate which page we want.
	[self.delegate bookmarkViewController:self didRequestPage:page];
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger index = indexPath.row;
		[self.bookmarks removeObjectAtIndex:index];
		
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
	
	NSInteger count = [self.bookmarks count];
	return count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"bookmarkCell";
	
	NSNumber *pageNumber = [self.bookmarks objectAtIndex:[indexPath row]];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	}
	
	[[cell textLabel]setText:[NSString stringWithFormat:@"Page %u",[pageNumber unsignedIntValue]]];
	
	return cell;
	
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.status = STATUS_NORMAL;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.status = STATUS_NORMAL;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //	Here we recover the bookmarks from the userdefaults. While this is fine for an application with a single
    //	pdf document, you probably want to store them in coredata or some other way and bind them to a specific document
    //	by setting or passing to this viewcontroller an identifier for the document or tell a delegate to load/save
    //	them for us.
    
    NSMutableArray *aBookmarksArray = [self loadBookmarks];
    
    [self setBookmarks:aBookmarksArray];
    
    [self.bookmarksTableView reloadData];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

@end
