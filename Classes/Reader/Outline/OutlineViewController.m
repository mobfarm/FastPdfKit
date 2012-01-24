    //
//  OutlineViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "OutlineViewController.h"
#import "MFPDFOutlineEntry.h"
#import "MFPDFOutlineRemoteEntry.h"
#import "ReaderViewController.h"

@implementation OutlineViewController

@synthesize outlineEntries, openOutlineEntries;
@synthesize outlineTableView;
@synthesize delegate;


-(IBAction)actionBack:(id)sender {
	
	[[self delegate]dismissOutlineViewController:self];
}

#pragma mark -
#pragma mark UITableViewDelegate & DataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [outlineEntries count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Well, this is just common cell creation depending on the items in the data source. The cell used
	// in the example is rather simple, just a default cell with an accessory button. You can probably
	// want something customized, for example a clickable button to open/hide the cildren or a touchable
	// title to go to the selected outline entry. It is really up to you.
	
	static NSString *cellId = @"outlineCellId";
	
	id entry = [outlineEntries objectAtIndex:indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
		
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId]autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
	}
    
    // Quick cleanup of the cell. There should be a table view method for this, but I'm unable to find it atm.
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [[cell imageView]setImage:nil];
    
    // In the case of MFPDFOutlineEntry we don't show the accessory if the pageNumber is 0. In the case of
    // the MFPDFOutlineRemoteEntry we don't show the accessory if there's no destination file or if both
    // the page number and destination name are missing.
    
    if([entry isKindOfClass:[MFPDFOutlineRemoteEntry class]]) { // Remote (another document) entry
        
        MFPDFOutlineRemoteEntry * outlineEntry = (MFPDFOutlineRemoteEntry *)entry;
        
        if(!(([outlineEntry file])&&(([outlineEntry pageNumber]!=0)||[outlineEntry destination]))) {
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];            
        }
        
    } else if ([entry isKindOfClass:[MFPDFOutlineEntry class]]) { // Local (this document) entry
        
        MFPDFOutlineEntry * outlineEntry = (MFPDFOutlineEntry *)entry;
        
        if([outlineEntry pageNumber] == 0) {
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
    } else {
        
        // This should never happen since the outline method of the manager only return
        // instances of the above classes.
    }

    
	if([[(MFPDFOutlineEntry *)entry bookmarks]count]> 0) { // Check if the entry has children.
        
        [[cell imageView]setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"img_outline_triangleright",@"png")]];
	}
	
	[cell setIndentationLevel:[entry indentation]];
	
	[[cell textLabel]setText:[entry title]];
	
	return cell;
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
    id entry = [outlineEntries objectAtIndex:indexPath.row];
	
	// Go to page if it is not 0. The point is that some kind of link are not supported, for example the ones
	// that refer to actions linking to other pdf files. In this case the destination page is set to be 0, and
	// it never exist. We already have a control in the cellForRowAtIndexPath: method and the setPage: method
	// does nothing if the page is 0, but better be paranoid than sorry.
	
    
    if([entry isKindOfClass:[MFPDFOutlineRemoteEntry class]]) {
        
        MFPDFOutlineRemoteEntry * outlineEntry = (MFPDFOutlineRemoteEntry *)entry;
        NSString * file = nil;
        NSString * destination = nil;
        NSUInteger pageNumber = 0;
        
        if((file = [outlineEntry file])) {
            
            if((pageNumber = [outlineEntry pageNumber])!=0) {
                
                if([delegate respondsToSelector:@selector(outlineViewController:didRequestPage:file:)])
                    [delegate outlineViewController:self didRequestPage:pageNumber file:file];
                
            } else if ((destination = [outlineEntry destination])) {
                
                if([delegate respondsToSelector:@selector(outlineViewController:didRequestDestination:file:)])
                    [delegate outlineViewController:self didRequestDestination:destination file:file];
            }
        }
        
    } else if ([entry isKindOfClass:[MFPDFOutlineEntry class]]) {
        
        
        NSUInteger pageNumber = [(MFPDFOutlineEntry *)entry pageNumber];
        if(pageNumber != 0) {
            
            if([delegate respondsToSelector:@selector(outlineViewController:didRequestPage:)])
                [delegate outlineViewController:self didRequestPage:pageNumber];
        }
        
    } else {
        
        // This should never happen!
    }

}

-(void)recursivelyAddVisibleChildrenOfEntry:(MFPDFOutlineEntry *)entry toArray:(NSMutableArray *)array {
	
	// This will return the array of item to be added/remove from the table. Since the first entry is just
	// closed and not added/removed we should take that into account. If the entry is not the array, we
	// are running the first iteration, otherwise not.
	
	if(![array containsObject:entry]) {
		
		// First iteration, just add the children, since at least them will be removed/added.
		NSArray * children = [entry bookmarks];
		[array addObjectsFromArray:children];
		
		// Now recursively call this method on the childrend just addded. Don't use array since
		// it is going to me modified and you will get an exception (array being modified while
		// being enumerated)
		for(MFPDFOutlineEntry * e in children) {
			
			[self recursivelyAddVisibleChildrenOfEntry:e toArray:array];
		}
		
	} else {
		
		// This may seem tricky at first, but it is rather straightforward: if the entry 
		// is in the openOutlineEntries, its children will be visible right under it in the list, so
		// we need to add them in the array.
		// Thus, we take the position of the entry in the array and insert its children at the right
		// positions in the array, then invoke this very same method on every children just added.
		
		if([openOutlineEntries containsObject:entry]) {
			
			NSUInteger position = [array indexOfObject:entry];
			NSMutableArray *children = [[entry bookmarks]mutableCopy];
			NSUInteger count = [children count];
			
			// NSIndexSet indexSetWithIndexesInRange: factory method is really useful :)
			[array insertObjects:children atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(position+1, count)]];
			
			for(MFPDFOutlineEntry *e in children) {
				[self recursivelyAddVisibleChildrenOfEntry:e toArray:array];
			}
			
			[children release];
			
		} else {
			
			// Well, no children to add/remove since the entry is closed and none of its children
			// is visible. Just return.
			
			return;
		}
	}
	
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// We try to replicate the outline view of adobe reader, but you can also choose to use a more
	// simpler navigation using nested table views. It probably depend on how deep the outline tree
	// is and how important is to your application: for a book is probably vital, for a catalog not
	// so much...
	
	MFPDFOutlineEntry * entry = [outlineEntries objectAtIndex:indexPath.row];
    
	// If the entry is a leaf (it doesn't have children), go to the page.
	if(![[entry bookmarks]count]>0) {
        
        // Go to page if it is not 0. The point is that some kind of link are not supported, for example the ones
        // that refer to actions linking to other pdf files. In this case the destination page is set to be 0, and
        // it never exist. We already have a control in the cellForRowAtIndexPath: method and the setPage: method
        // does nothing if the page is 0, but better be paranoid than sorry.
        
        NSUInteger pageNumber = [entry pageNumber];
        if(pageNumber != 0) {
            
            [delegate outlineViewController:self didRequestPage:pageNumber];
        }
	}
	
	// We need to add/remove a certain number of rows depending on how
	// many entries are visible in the tree branch we are going to open/close. Do do that,
	// we get the selected entry and traverse it breadth first and add the children if the node
	// result open (that is, if the entry is in the open entry list). If it is not, we can skip to its next
	// siebling.
	
	// Create and array of children with a utility method. Check of it works.
	NSMutableArray * children = [NSMutableArray array];
	[self recursivelyAddVisibleChildrenOfEntry:entry toArray:children];
	
	// Then we need an NSIndexSet to update the entry array and an array of NSIndexPath to update the table view.
	// The number of object to add/remove and the first position of them are necessary to be know. 
	NSUInteger count = [children count];						// Number of row to be removed.
	NSUInteger firstPosition = [outlineEntries indexOfObject:entry]+1;	// The position right under the selected cell.
	
	// This is the indexSet of the item to be added/removed from the outline array.
	NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstPosition, count)];
	
	// To update the table view we need an array of indexPaths. I don't know a factory method to generate them, 
	// so let's do it manually...
	NSMutableArray * indexPaths = [NSMutableArray array];				// The array.
	NSUInteger index;
	for (index = 0; index < count; index++) {
		// The cell to be removed start right under the entry selected.
		[indexPaths addObject:[NSIndexPath indexPathForRow:firstPosition+index inSection:0]];
	}
	
	// Now we will proceed differently if we are collapsing the node or not.
	
	if([openOutlineEntries containsObject:entry]) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        [[cell imageView]setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"img_outline_triangleright",@"png")]];
		
		// Remove the entry selected and all of its visible children from the outlineEntries array
		// and update the tableview by removing the cell at the corresponding indexPaths.
		
		[outlineEntries removeObjectsAtIndexes:indexSet];
		
		// Now we can update the table view.
		[outlineTableView beginUpdates];
		
		[outlineTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
		
		[outlineTableView endUpdates];
		
		// Critical: remove the entry from the open list. If you want to collapse the entire subtree, you can
		// remove the children you find to be open in the recursivelyAddVisibleChildrenOfEntry: selector.
		[openOutlineEntries removeObject:entry];
		
	} else {
		
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        UIImage *aImage = [[UIImage alloc]initWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"img_outline_triangledown",@"png")];
        
        [[cell imageView]setImage:aImage];
        
        [aImage release];
        
		// Add the visible children of the selected entry to the outlineEntries array and update
		// the tableview by addind the cell at the corresponding indexPaths
		
		// First the entries in the array.
		[outlineEntries insertObjects:children atIndexes:indexSet];
		
		// Then the table.
		[outlineTableView beginUpdates];
		
		[outlineTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
		
		[outlineTableView endUpdates];
		
		// Critical: add the entry from the open list.
		[openOutlineEntries addObject:entry];
	}
	
}

#pragma mark -
#pragma mark ViewController lifecycle

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		// Empty arrays, just in case...
		outlineEntries = [[NSMutableArray alloc]init];
		openOutlineEntries = [[NSMutableArray alloc]init];
		
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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
	[self setOutlineTableView:nil];
	
}


- (void)dealloc {
	
	[outlineEntries release];
	[openOutlineEntries release];
	
	[outlineTableView release];
	
    [super dealloc];
}


@end
