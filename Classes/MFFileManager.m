//
//  MFFileManager.m
//  PDFReaderHD
//
//  Created by Matteo Gavagnin on 15/04/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MFFileManager.h"
#import "Document.h"
#import "Stuff.h"
#import "MainViewController.h"
#import "MFSimpleKeychainManager.h"
#import "MFScreenshotOperation.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define THUMBNAILS_FOLDER [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@".thumbnails"]

#define THUMBNAIL_CHECK_FLAG @"FLAG_THUMBNAIL_CREATION_FAILED"

@implementation MFFileManager
@synthesize documentsList, managedObjectContext, delegate, rootDocumentsList, visibleDocumentsList;
@synthesize docWatcher;
@synthesize canReloadDocuments;

-(id)initWithManagedContext:(NSManagedObjectContext *)context{
	managedObjectContext = context;
	//documentsList = [[NSMutableArray alloc] init];
	
	NSMutableArray * anArray = [[NSMutableArray alloc]init];
	[self setDocumentsList:anArray];
	[anArray release];

	NSMutableArray * anotherArray = [[NSMutableArray alloc]init];
	[self setRootDocumentsList:anotherArray];
	[anotherArray release];
	
	NSMutableArray * lastArray = [[NSMutableArray alloc]init];
	[self setVisibleDocumentsList:lastArray];
	[lastArray release];

	self.canReloadDocuments = YES;
	
	// start monitoring the document directory…
    // self.docWatcher = [DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory] delegate:self];
    
    // scan for existing documents
    // [self directoryDidChange:self.docWatcher];
	
	[self readFilesFromDisk:self];
	return self;	
}

#pragma mark -
#pragma mark File system support

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	if(DEBUG)
		NSLog(@"DirectoryDidChage");

	/*
	[self.documentURLs removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator])
		{
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		
		BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
		
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory && [curFileName isEqualToString: @"Inbox"]))
			{
            [self.documentURLs addObject:fileURL];
			}
		}
	
	[self.tableView reloadData];
	*/
	
	if (canReloadDocuments){
		[delegate redrawTableAfterForeground];	
	} else {
		[self performSelector:@selector(updateTableAfterLock:) withObject:nil afterDelay:2.0];
	}
}

-(void)updateTableAfterLock:(id)sender{
	if (DEBUG)
		NSLog(@"UpdateTableAfterLock");
	if(canReloadDocuments){
		[delegate redrawTableAfterForeground];
	} else {
		[self performSelector:@selector(updateTableAfterLock:) withObject:nil afterDelay:2.0];
	}
}

-(void)readFilesFromDisk:(id)sender{
	if (DEBUG)
		NSLog(@"Reread Files From Disk");
	
	
	// In ogni momento deve esserci corrispondenza tra core data e files su hd: leggo i files su hd, controllo che ci sia l'equivalente in Core Data e al massimo lo creo.
	
	// Ogni file deve avere una controparte in un Document core data, questo avrà titolo (corrispondente a quello del file su hard disk), posizione (per l'ordinamento della tabella) e dimensione (per evitare di avere due files con stesso nome in momenti diversi e far casino con i preferiti). Inoltre deve esserci il riferimento al thumbnails.png creato con il nome del thumbnail stesso. Quanto un file viene eliminato, oppure non torna la dimensione del file. Viene eliminato anche il relativo oggetto CoreData, il thumbnail e tutti i segnalibri collegati. I thumbnails e il database CoreData andranno sistemati non nella cartella documents, ma nella cartella Library in modo che non risultino visibili da parte dell'utente da iTunes. Va creato un file manager che permetta di avere una lista aggiornata dei files presenti e non che ogni controller debba andare a cercare che files ci sono.
	
	
	//	NSPredicate * documentsPredicate = [NSPredicate predicateWithFormat:@"name = %@", [[delegate pdfDataManager] fileName]];
	//	[documentsReq setPredicate:documentsPredicate];
	
	NSError *error;
	NSMutableArray *fileList = (NSMutableArray *) [[[[NSFileManager defaultManager] contentsOfDirectoryAtPath:DOCUMENTS_FOLDER error:&error]
													pathsMatchingExtensions:[NSArray arrayWithObjects:@"PDF", @"pdf", nil]] retain];
	
	
	
	// Fetch all documents
	NSFetchRequest * documentsReq = [[NSFetchRequest alloc] init];
	NSEntityDescription * documentsEntity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext];
	[documentsReq setEntity:documentsEntity];
	
	NSError * documentsError = nil;
	
	// Local reference: set it and release at the end of the processing (go to the bottom of the function)
	NSMutableArray * aDocumentList = [[managedObjectContext executeFetchRequest:documentsReq error:&documentsError] mutableCopy];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[aDocumentList sortUsingDescriptors:sortDescriptors];
	
	if (!documentsError) {			
		// Cerco se ci sono documenti su core data che non hanno più il file su hd
		for (unsigned i = 0; i < [aDocumentList count]; i++) {				
			NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"SELF == %@", [[aDocumentList objectAtIndex:i] name]];
			// Array degli oggetti che hanno lo stesso nome
			NSArray *sameName = [fileList filteredArrayUsingPredicate:aPredicate];
			if ([sameName count] == 0 && [[[aDocumentList objectAtIndex:i] folder] boolValue] != YES) {
				if (DEBUG){
					NSLog(@"Nessun oggetto su HD corrispondente all'oggetto core data --> Elimino oggetto CD");
					NSLog(@"Vecchio file: %@", [[aDocumentList objectAtIndex:i] name]);
				}
				// Delete CD file and every related Bookmark
				[managedObjectContext deleteObject:[aDocumentList objectAtIndex:i]];

				
				NSError *deleteError;
				if ([[[aDocumentList objectAtIndex:i] thumbnail] length] > 0 && [[NSFileManager defaultManager] removeItemAtPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:[[aDocumentList objectAtIndex:i] thumbnail]] error:&deleteError]) {
						NSLog(@"Thumbnail deleted");
				}else{
					if (DEBUG)
						NSLog(@"Thumbnail NOT deleted");
				}
			} else if ([sameName count] == 1) {
				// if (DEBUG)
				// NSLog(@"Un solo oggetto su HD corrispondente all'oggetto core data --> OK");
				if ([[[[NSFileManager defaultManager] fileAttributesAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:[sameName objectAtIndex:0]] traverseLink:NO] objectForKey:NSFileSize] intValue] != [[[aDocumentList objectAtIndex:i] bytes] intValue]) {
					// CD e HD hanno dimensioni diverse e quindi devo eliminare l'oggetto e crearne uno nuovo perché si tratta di un file differente 
					// Elimino vecchio Documento CD
					[managedObjectContext deleteObject:[aDocumentList objectAtIndex:i]];
					
					// Creo nuovo documento CD
					Document *document = (Document *)[NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:managedObjectContext];
					[document setName:[sameName objectAtIndex:0]];
					[document setOrderposition:[NSNumber numberWithInt:0]];
					[document setThumbnail:@""];
					[document setBytes:[[[NSFileManager defaultManager] fileAttributesAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:[sameName objectAtIndex:0]] traverseLink:NO] objectForKey:NSFileSize]];
					NSError *deleteError;
					if ([[[aDocumentList objectAtIndex:i] thumbnail] length] > 0 && [[NSFileManager defaultManager] removeItemAtPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:[sameName objectAtIndex:0]] error:&deleteError]) {
						if (DEBUG)
							NSLog(@"Thumbnail deleted");
					}else{
						if (DEBUG)
							NSLog(@"Thumbnail NOT deleted");
					}
					
					if (DEBUG) {
						NSLog(@"Differences between HD and CD dimensions");
					}
					[self createThumbnailForDocumentNamed:[sameName objectAtIndex:0]];
				} else if (![[aDocumentList objectAtIndex:i] folder]) {
					// Migrazione, se il campo folder == nil lo rendo = 0
					if (DEBUG)
						NSLog(@"Elemento con campo folder nullo");
					[[aDocumentList objectAtIndex:i] setFolder:[NSNumber numberWithInt:0]];
				
				}
			} else {
				if (DEBUG)
					NSLog(@"Più oggetti su CD con lo stesso nome --> Impossibile a meno che non siano cartelle");
			}
		}
		
		// Cerco se ci sono file su hd che non hanno il corrispettivo su core data
		for (unsigned i = 0; i < [fileList count]; i++) {				
			NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"name == %@", [fileList objectAtIndex:i]];
			// Array degli oggetti che hanno lo stesso nome
			NSArray *sameName = [aDocumentList filteredArrayUsingPredicate:aPredicate];
			if ([sameName count] == 0) {
				if (DEBUG){
					NSLog(@"Nessun oggetto su CD corrispondente all'oggetto su hd --> Creo oggetto CD");						
					NSLog(@"Nuovo file: %@", [fileList objectAtIndex:i]);						
				}
				Document *document = (Document *)[NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:managedObjectContext];
				[document setName:[fileList objectAtIndex:i]];
				[document setOrderposition:[NSNumber numberWithInt:-1]];
				[document setThumbnail:@""];
				
				[self createThumbnailForDocumentNamed:[fileList objectAtIndex:i]];
				 
				[document setBytes:[[[NSFileManager defaultManager] fileAttributesAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:[fileList objectAtIndex:i]] traverseLink:NO] objectForKey:NSFileSize]];
			} else if ([sameName count] == 1) {
				// Controllo se l'oggetto CD ha il thumbnail settato, altrimenti glielo faccio creare
				if([[[sameName objectAtIndex:0] thumbnail] isEqualToString:@""])
					[self createThumbnailForDocumentNamed:[fileList objectAtIndex:i]];
				
			} else {
				if (DEBUG)
					NSLog(@"Più oggetti su HD con lo stesso nome --> Impossibile :(");
			}
		}
	}	
	
	[sortDescriptor release];
	[sortDescriptors release];
	[documentsReq release];
	[fileList release];
	
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
//		if (DEBUG)
//			NSLog(@"Core Data synchronized");
	}
	[self setDocumentsList:aDocumentList];
	[aDocumentList release];

	[self reorderDocumentsArray];
	[self createRootDocumentsAndFolders];
	// [self reloadCoreDataDocuments:self];
	
	// [self getVisibleDocumentsWithOpenedFolder:nil withBooksInRow:5.0];
	// [[delegate tableView] reloadData];
	// [delegate redrawTableAfterForeground];
}

-(void)createRootDocumentsAndFolders{
	
	NSMutableArray * rootDocList = nil;
	
	NSFetchRequest * documentsReq = [[NSFetchRequest alloc] init];
	NSEntityDescription * documentsEntity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext];
	[documentsReq setEntity:documentsEntity];
	NSPredicate * documentsPredicate = [NSPredicate predicateWithFormat:@"infolder.@count == 0 AND folder == NO OR folder == YES"];
	[documentsReq setPredicate:documentsPredicate];
	NSError * documentsError = nil;
	rootDocList = [[managedObjectContext executeFetchRequest:documentsReq error:&documentsError] mutableCopy];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[rootDocList sortUsingDescriptors:sortDescriptors];
	
	[self setRootDocumentsList:rootDocList];
	
	// Cleanup
	[rootDocList release];
	[sortDescriptors release];
	[sortDescriptor release];
	[documentsReq release];
	
}


-(void)reloadCoreDataDocuments:(id)sender{
	
	if ([documentsList count] > 0) {
		
		NSMutableArray * docList = nil;
		
		NSFetchRequest * documentsReq = [[NSFetchRequest alloc] init];
		NSEntityDescription * documentsEntity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext];
		[documentsReq setEntity:documentsEntity];
		
		NSError * documentsError = nil;
		
		docList = [[managedObjectContext executeFetchRequest:documentsReq error:&documentsError] mutableCopy];
		
		if(!docList) {
			if(DEBUG){
				NSLog(@"%@ - error loading core data objects at reload",NSStringFromClass([self class]));
			}
		}
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[docList sortUsingDescriptors:sortDescriptors];
		
		[self setDocumentsList:docList];
		[self createRootDocumentsAndFolders];
		
		[sortDescriptors release];
		[sortDescriptor release];
		[documentsReq release];
		[docList release];
		
	}
	
	// [delegate redrawTableAfterForeground];
	// TODO: piazzare un delegate in modo da ricaricare l'interfaccia...
}

-(void)deleteFileAtIndex:(NSUInteger)_index{
	if(DEBUG)
		NSLog(@"Trying to delete a file");
	NSMutableString * mutableFileName = [NSMutableString stringWithString:[[documentsList objectAtIndex:_index] name]];
	NSMutableString * mutableThumbnailName = [NSMutableString stringWithString:[[documentsList objectAtIndex:_index] thumbnail]];
	NSError *error;
	if ([[NSFileManager defaultManager] removeItemAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:mutableFileName] error:&error]) {
		if ([mutableThumbnailName length] > 0 && [[NSFileManager defaultManager] removeItemAtPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:mutableThumbnailName] error:&error]) {
			if (DEBUG)
				NSLog(@"Thumbnail deleted");
		} else{
			if (DEBUG)
				NSLog(@"Thumbnail NOT deleted");
		}

		[managedObjectContext deleteObject:[documentsList objectAtIndex:_index]];
		[documentsList removeObjectAtIndex:_index];
		
		NSError *commitError;
		if (![managedObjectContext save:&commitError]) {
			if (DEBUG)
				NSLog(@"Error updating Core Data");
		}
		else {
//			if (DEBUG)
//				NSLog(@"Core Data synchronized");
		}		
		if (DEBUG)
			NSLog(@"File deleted");		
	} else {
		NSLog(@"Error deleting file");
	}

}


-(void)deleteFolderAndIncludedDocuments:(Document *)document{
	// Elimino il documento dall'array dei documenti
	[documentsList removeObject:document];
	
	if ([document isMemberOfClass:[Document class]] && [[document folder] boolValue]) {
		
		// Folder here.
		
		NSMutableArray *documents = [self getOnlyDocumentsInFolder:document];
		for (Document *aDocument in documents) {
			[self deleteDocument:aDocument];
		}
		[managedObjectContext deleteObject:document];
		NSError *commitError;
		if (![managedObjectContext save:&commitError]) {
			if (DEBUG)
				NSLog(@"Error updating Core Data");
		}
		else {
//			if (DEBUG)
//				NSLog(@"Core Data synchronized");
		}
	} else if ([document isMemberOfClass:[Document class]]) {
		
		// Simple document.
		
		NSMutableString * mutableFileName = [NSMutableString stringWithString:[document name]];
		NSMutableString * mutableThumbnailName = [NSMutableString stringWithString:[document thumbnail]];
		NSError *error;
		if ([[NSFileManager defaultManager] removeItemAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:mutableFileName] error:&error]) {
			if ([mutableThumbnailName length] > 0 && [[NSFileManager defaultManager] removeItemAtPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:mutableThumbnailName] error:&error]) {
				if (DEBUG)
					NSLog(@"Thumbnail deleted");
			} else{
				if (DEBUG)
					NSLog(@"Thumbnail NOT deleted");
			}
			
			// Delete the password, if any.
			[MFSimpleKeychainManager deletePasswordForItem:[[document name]stringByDeletingPathExtension]];
			
			// Delete the object from core data.
			[managedObjectContext deleteObject:document];
			
			NSError *commitError;
			if (![managedObjectContext save:&commitError]) {
				if (DEBUG)
					NSLog(@"Error updating Core Data");
			}
			else {
				if (DEBUG)
					NSLog(@"Core Data synchronized");
			}		
			if (DEBUG)
				NSLog(@"File deleted");		
		} else {
			NSLog(@"Error deleting file");
		}
	}
	[self createRootDocumentsAndFolders];
}

-(void)deleteDocument:(Document *)document{
	// Elimino il documento dall'array dei documenti
	[documentsList removeObject:document];
	
	if ([document isMemberOfClass:[Document class]] && [[document folder] boolValue]) {
		
		// Folder here.
		
		NSMutableArray *documents = [self getOnlyDocumentsInFolder:document];
		for (Document *aDocument in documents) {
			[self moveOutsideFolderDocument:aDocument];
		}
		[managedObjectContext deleteObject:document];
		NSError *commitError;
		if (![managedObjectContext save:&commitError]) {
			if (DEBUG)
				NSLog(@"Error updating Core Data");
		}
		else {
			//			if (DEBUG)
			//				NSLog(@"Core Data synchronized");
		}
	} else if ([document isMemberOfClass:[Document class]]) {
		
		// Simple document.
		
		NSMutableString * mutableFileName = [NSMutableString stringWithString:[document name]];
		NSMutableString * mutableThumbnailName = [NSMutableString stringWithString:[document thumbnail]];
		NSError *error;
		if ([[NSFileManager defaultManager] removeItemAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:mutableFileName] error:&error]) {
			if ([mutableThumbnailName length] > 0 && [[NSFileManager defaultManager] removeItemAtPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:mutableThumbnailName] error:&error]) {
				if (DEBUG)
					NSLog(@"Thumbnail deleted");
			} else{
				if (DEBUG)
					NSLog(@"Thumbnail NOT deleted");
			}
			
			// Delete the password, if any.
			[MFSimpleKeychainManager deletePasswordForItem:[[document name]stringByDeletingPathExtension]];
			
			// Delete the object from core data.
			[managedObjectContext deleteObject:document];
			
			NSError *commitError;
			if (![managedObjectContext save:&commitError]) {
				if (DEBUG)
					NSLog(@"Error updating Core Data");
			}
			else {
				if (DEBUG)
					NSLog(@"Core Data synchronized");
			}		
			if (DEBUG)
				NSLog(@"File deleted");		
		} else {
			NSLog(@"Error deleting file");
		}
	}
	[self createRootDocumentsAndFolders];
}

-(NSArray *)deleteFolderAndGetDocuments:(Document *)document{
	// Elimino il documento dall'array dei documenti
	[documentsList removeObject:document];

	NSMutableArray *documents = [self getOnlyDocumentsInFolder:document];
	for (Document *aDocument in documents) {
		[self moveOutsideFolderDocument:aDocument];
	}
	[managedObjectContext deleteObject:document];
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
	//	if (DEBUG)
	//		NSLog(@"Core Data synchronized");
	}
	return [NSArray arrayWithArray:documents];
	[self createRootDocumentsAndFolders];
}

-(void)justDeleteFolder:(Document *)document{
	if ([document isMemberOfClass:[Document class]]) {
		
		[managedObjectContext deleteObject:document];
		
		NSError *commitError;
		if (![managedObjectContext save:&commitError]) {
			if (DEBUG)
				NSLog(@"Error updating Core Data");
		}
		else {
			if (DEBUG)
				NSLog(@"Core Data synchronized");
		}		
	}
	[self createRootDocumentsAndFolders];
}

-(BOOL)renameDocument:(Document *)doc withName:(NSString *)_name{
	NSString *oldName = [doc name];
	NSString *oldThumbnail = [doc thumbnail];
	if([[doc folder]boolValue]) {
		
		[doc setName:_name];
		
		NSError *commitError = nil;
		
		if (![managedObjectContext save:&commitError]) {
			if (DEBUG)
				NSLog(@"Error updating Core Data");
			// [self reloadCoreDataDocuments:self];
			
		}
		else {
			// All fine
		}
		return YES;
	}
	
	// Document
	NSString * originalFileName = [NSString stringWithString:oldName];
	NSError *error;
	int confirm = 0;
	if (![originalFileName isEqualToString:[NSString stringWithFormat:@"%@.pdf",_name]] && [[NSFileManager defaultManager] moveItemAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:originalFileName] toPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",_name]] error:&error]){
		[doc setName:[NSString stringWithFormat:@"%@.pdf",_name]];
		confirm += 1;
	}
	NSMutableString * originalThumbnailName = [NSMutableString stringWithString:oldThumbnail];
	NSError *thumbError;
	if(![originalThumbnailName isEqualToString:[NSString stringWithFormat:@"%@.png",_name]] && [[NSFileManager defaultManager] moveItemAtPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:originalThumbnailName] toPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_name]] error:&thumbError]){
		[doc setThumbnail:[NSString stringWithFormat:@"%@.png",_name]];
		confirm += 1;
	}
	
	if (confirm == 2) {
		NSError *commitError;
		if (![managedObjectContext save:&commitError]) {
			if (DEBUG)
				NSLog(@"Error updating Core Data");
		}
		else {
			//			if (DEBUG)
			//				NSLog(@"Core Data synchronized");
		}		
		
		
		// Get the newly named document
		return YES;
		
		if (DEBUG)
			NSLog(@"File renamed");
	} else {
		if (DEBUG)
			NSLog(@"Error renaming file");
		
		return NO;
	}
}

-(BOOL)canRenameFile:(NSUInteger)_index withNewName:(NSString *)_name{
	NSMutableString *path = (NSMutableString *)[DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", _name]];
	if (DEBUG)
		NSLog(@"path: %@", path);	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
			return NO;			
	}
	else 
		return YES;
}

-(void)renameFileAtIndex:(NSUInteger)_index withName:(NSString *)_name{
	
	Document *doc = [documentsList objectAtIndex:_index];
	
	if([[doc folder]boolValue]) {
		
		[doc setName:_name];
		
		NSError *commitError = nil;
		
		if (![managedObjectContext save:&commitError]) {
			if (DEBUG)
				NSLog(@"Error updating Core Data");
			[self reloadCoreDataDocuments:self];
			
		}
		else {
			// All fine
		}
		return;
	}
	
	// Document
	NSString * originalFileName = [NSString stringWithString:[[documentsList objectAtIndex:_index] name]];
	NSError *error;
	int confirm = 0;
	if (![originalFileName isEqualToString:[NSString stringWithFormat:@"%@.pdf",_name]] && [[NSFileManager defaultManager] moveItemAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:originalFileName] toPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",_name]] error:&error]){
		[doc setName:[NSString stringWithFormat:@"%@.pdf",_name]];
		confirm += 1;
	}
	NSMutableString * originalThumbnailName = [NSMutableString stringWithString:[[documentsList objectAtIndex:_index] thumbnail]];
	NSError *thumbError;
	if(![originalThumbnailName isEqualToString:[NSString stringWithFormat:@"%@.png",_name]] && [[NSFileManager defaultManager] moveItemAtPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:originalThumbnailName] toPath:[THUMBNAILS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_name]] error:&thumbError]){
		[doc setThumbnail:[NSString stringWithFormat:@"%@.png",_name]];
		confirm += 1;
	}
		
	if (confirm == 2) {
		NSError *commitError;
		if (![managedObjectContext save:&commitError]) {
			if (DEBUG)
				NSLog(@"Error updating Core Data");
		}
		else {
//			if (DEBUG)
//				NSLog(@"Core Data synchronized");
		}		
		
		[self reloadCoreDataDocuments:self];

		if (DEBUG)
			NSLog(@"File renamed");
	} else {
		if (DEBUG)
			NSLog(@"Error renaming file");
	}
}

-(void)flagThumbnailForDocumentOfName:(NSString *)name {
	
	if (DEBUG)
		NSLog(@"Flagging Thumbnail For Document Of Name");
	[self reloadCoreDataDocuments:self];
	
	for(Document * document in documentsList) {
		
		// Iterate over the documents until the match is found, update the thumbnail property then break
		if([[document name]isEqualToString:name]) {
			
			[document setThumbnail:THUMBNAIL_CHECK_FLAG];
		
			break;
		}
	}
	
	// Save the managed object ctx
	NSError * error;
	if(![managedObjectContext save:&error]) {
		if(DEBUG){
			NSLog(@"%@ - could not flag document", NSStringFromClass([self class]));
		}
	}
	/*
	if (canReloadDocuments){
		[delegate redrawTableAfterForeground];	
	} else {
		[self performSelector:@selector(updateTableAfterLock:) withObject:nil afterDelay:2.0];
	}
	 */
}

-(void)updateThumbnailForDocumentOfName:(NSString *)name {
	
	
	if (DEBUG)
		NSLog(@"Update Thumbnail For Document Of Name: %@", name);
	[self reloadCoreDataDocuments:self];
	
	NSString * documentName = name;
	NSString * thumbnailName = [name stringByDeletingPathExtension];
	
	for(Document * document in documentsList) {
		
		// Iterate over the documents until the match is found, update the thumbnail property then break
		if([[document name] isEqualToString:documentName]) {
			
			
			thumbnailName = [thumbnailName stringByAppendingPathExtension:@"png"];
			[document setThumbnail:thumbnailName];
			// [document setLauncherItem:[self getImagePathForDocument:document]];
			
			if(DEBUG)
				NSLog(@"%@ update document with thumbnail %@",NSStringFromClass([self class]),thumbnailName);
			
			break;
			
		}
	}
	
	// Save the managed object ctx
	NSError * error;
	if(![managedObjectContext save:&error]) {
		if(DEBUG){
			NSLog(@"%@ - could not update thumbnail for document, but file should have been written successfully", NSStringFromClass([self class]));
		}
	}
	
	//Aggiornare la tabella dei documenti, possibilmente solo il documento di cui è stato creato lo screenshot ovviamente...
	
	// [[delegate sortController] setDocuments:documentsList];
	[[delegate sortController] updateImage:[UIImage imageWithContentsOfFile:[THUMBNAILS_FOLDER stringByAppendingPathComponent:thumbnailName]] forDocumentNamed:name];
	
	// [[delegate tableView] reloadData];
	
	canReloadDocuments = YES;
}

-(void)createThumbnailForDocumentNamed:(NSString *)name{
	canReloadDocuments = NO;
	
	
	id appdelegate = nil;
	NSOperationQueue * operationQueue = nil;
	MFScreenshotOperation * op = nil;
	
	op = [[MFScreenshotOperation alloc]init];
	[op setName:name];
	if ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[op setSize:CGSizeMake(145, 145)];
	} else {
		
		CGFloat scale = 1.0;
		
		if([[UIScreen mainScreen]respondsToSelector:@selector(scale)]) {
			scale = (CGFloat)[[UIScreen mainScreen]scale];
		}
		
		// On iPhone scale is 2.0, on other device is 1.0
		if(scale >= 1.5) {
			[op setSize:CGSizeMake(172, 172)];	
		} else {
			[op setSize:CGSizeMake(86, 86)];	
		}
	}
	
	
	[op setManager:self]; // For the callback
	
	appdelegate = (id)[[UIApplication sharedApplication]delegate];
	operationQueue = [appdelegate operationQueue];
	[operationQueue addOperation:op];
	
	[op release];
}

-(void)manualSetThumbnailForDocument:(Document *)document withImage:(UIImage *)image{
	if(DEBUG)
		NSLog(@"Manual Set Thumbnail For Document");
	
	//save image
	
	NSData * data = UIImagePNGRepresentation(image);
	NSFileManager * fileManager = [[NSFileManager alloc]init]; // Thread safe
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
	NSString * libPath = [paths objectAtIndex:0];
	// NSString * thumbnailsPath = [libPath stringByAppendingPathComponent:@".thumbnails"];
	NSString * thumbnailsPath = [NSString stringWithString:THUMBNAILS_FOLDER];
	NSString * filePath = [thumbnailsPath stringByAppendingPathComponent:[[document.name stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
	
	if(![fileManager fileExistsAtPath:thumbnailsPath]) {
		
		NSError * error;
		if(![fileManager createDirectoryAtPath:thumbnailsPath withIntermediateDirectories:YES attributes:nil error:&error]) {
			
			// Just abort, let someone else let handle the missing file when necessary
			
			if(DEBUG)
				NSLog(@"%@ - unable to create thumbnails folder",NSStringFromClass([self class]));
			
			return;
		}
	}
	
	if([fileManager createFileAtPath:filePath contents:data attributes:nil]) {
		// File created, callback
		
	} else {	
		if(DEBUG)
			NSLog(@"%@ - unable to save file",NSStringFromClass([self class]));
		
	}
	
	[fileManager release];
	
	
	// TODO: save CD informations
	
	[document setThumbnail:[[document.name stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
	
	NSError * error;
	if(![managedObjectContext save:&error]) {
		if(DEBUG){
			NSLog(@"%@ - could not update thumbnail for document, but file should have been written successfully", NSStringFromClass([self class]));
		}
	}
	
}

-(void)manualSetThumbnailForDocument:(Document *)document withString:(NSString *)image{
	[document setThumbnail:image];
	
	NSError * error;
	if(![managedObjectContext save:&error]) {
		if(DEBUG){
			NSLog(@"%@ - could not update thumbnail for document, but file should have been written successfully", NSStringFromClass([self class]));
		}
	}
}


-(void)createCoreDataForFileAtIndex:(NSUInteger)_integer{
	
}

-(void)deleteCoreDataForFileAtIndex:(NSUInteger)_integer{
	
}

-(NSNumber *)getFileSizeForFileAtIndex:(NSUInteger)_index{
	return [[documentsList objectAtIndex:_index] bytes];
}

-(void)reorderDocumentsArray{
	[self reloadCoreDataDocuments:self];
	int count = [documentsList count];
	for (unsigned i = 0; i < count; i++) {
		[[documentsList objectAtIndex:i] setOrderposition:[NSNumber numberWithInt:i*2]];
	}
	
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
//		if (DEBUG)
//			NSLog(@"Core Data synchronized");
	}	
	[self reloadCoreDataDocuments:self];
}

-(void)setPosition:(NSUInteger)_position forFileAtIndex:(NSUInteger)_index{
	if (DEBUG)
		NSLog(@"File %i, Destination %i", _index, _position);
	
	// Reordering array
	// La posizione è differente nel caso l'indice sia maggiore o minore della destinazione perché si scala di uno
	
	Document *movedDocument = [[documentsList objectAtIndex:_index] retain];
	[documentsList removeObjectAtIndex:_index];
	// [movedDocument setOrderposition:[NSNumber numberWithInt:_position]];
	[documentsList insertObject:movedDocument atIndex:_position];
	[movedDocument release];
	
	// Now update CD position value
	int count = [documentsList count];
	for (unsigned i = 0; i < count; i++) {
		[[documentsList objectAtIndex:i] setOrderposition:[NSNumber numberWithInt:i]];
	}
	
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
//		if (DEBUG)
//			NSLog(@"Core Data synchronized");
	}	
	// [[delegate tableView] reloadData];
	// [self reloadCoreDataDocuments:self];
}

-(void)setPosition:(NSUInteger)_position forDocument:(Document *)document{
	
	// Reordering array
	// La posizione è differente nel caso l'indice sia maggiore o minore della destinazione perché si scala di uno
	
	//[document retain];
	// [documentsList removeObject:document];
	// Qui c'è il problema
	// FIXME: la posizione in documentsList considera anche tutti gli elementi all'interno delle cartelle, per cui settare la posizione per un elemento in base a quella di tutti gli altri è errato.
	// [documentsList insertObject:document atIndex:_position];
	// [document release];
	
	[document setOrderposition:[NSNumber numberWithInt:_position]];
	if(DEBUG)
		NSLog(@"Position for %@: %i", [document name], _position);
	
	
	// FIXME: in questo modo però avrò due elementi nella stessa posizione con buona probabilità perché non shifto tutti quelli dopo.
	
	/*
	// Now update CD position value
	int count = [documentsList count];
	for (unsigned i = 0; i < count; i++) {
		if(DEBUG)
			NSLog(@"Position for %@: %i", [[documentsList objectAtIndex:i] name], i);
		[[documentsList objectAtIndex:i] setOrderposition:[NSNumber numberWithInt:i]];
	}
	*/
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
		if (DEBUG)
			NSLog(@"Core Data synchronized");
	}
	
	// [[delegate tableView] reloadData];
	// [self reloadCoreDataDocuments:self];
}

-(void)setPositionsForDocuments:(NSArray *)documents{
	
	 // Now update CD position value
	 int count = [documents count];
	 for (unsigned i = 0; i < count; i++) {
		 //if(DEBUG)
		 //	 NSLog(@"Position for %@: %i", [[documents objectAtIndex:i] name], i);
		 [[documents objectAtIndex:i] setOrderposition:[NSNumber numberWithInt:i]];
	 }
	
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
		if (DEBUG)
			NSLog(@"Core Data synchronized");
	}
	
	// [[delegate tableView] reloadData];
	// [self reloadCoreDataDocuments:self];
}


-(NSNumber *)getDocumentIndexFromName:(NSString *)_name{
	int retVal = -1;
	for (unsigned i = 0; i < [documentsList count]; i++) {
		if ([[[documentsList objectAtIndex:i] name] isEqualToString:_name]) {
			retVal = i;
		}
	}
	if (retVal >= 0) {
		if(DEBUG)
			NSLog(@"Found document");
	} else {
		if(DEBUG)		
			NSLog(@"Document not Found");
	}
	return [NSNumber numberWithInt:retVal];
}

-(Document *)getDocumentFromName:(NSString *)_name{
	NSFetchRequest * documentsReq = [[NSFetchRequest alloc] init];
	NSEntityDescription * documentsEntity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext];
	[documentsReq setEntity:documentsEntity];
	NSPredicate * documentsPredicate = [NSPredicate predicateWithFormat:@"name = %@", _name];
	[documentsReq setPredicate:documentsPredicate];
	NSError * documentsError = nil;
	NSMutableArray *aDocumentsList = [[managedObjectContext executeFetchRequest:documentsReq error:&documentsError] mutableCopy];
	
	[documentsReq release];
	
	if ([aDocumentsList count] > 0) {
		if (DEBUG)
			NSLog(@"Document name: %@", [[aDocumentsList objectAtIndex:0] name]);
		return [aDocumentsList objectAtIndex:0];
	} else {
		return nil;
	}
}

-(NSString *)getPasswordForDocumentWithName:(NSString *)name{
	
	NSString *password = [MFSimpleKeychainManager retrievePasswordForItem:[name stringByDeletingPathExtension]];
	
	if(password == nil) {
		password = @"";
	}
	
	return password;
	
	/*
	BOOL found = NO;
	NSString * retVal;
	for (unsigned i = 0; i < [documentsList count]; i++) {
		if ([[documentsList objectAtIndex:i] isMemberOfClass:[Document class]] && [[[documentsList objectAtIndex:i] name] isEqualToString:_name]) {
			found = YES;
			if (![[documentsList objectAtIndex:i] psw] || [[[documentsList objectAtIndex:i] psw] isEqualToString:@"ZZZUNKNOWNZZZ"]) {
				retVal = @"";
			} else {
				retVal = [[documentsList objectAtIndex:i] psw];
			}
		}
	}
	if (!found) {
		retVal = @"";
	}
	return retVal;
	 */
}

-(void)setPassword:(NSString *)password forDocumentWithName:(NSString *)name{
	
	[MFSimpleKeychainManager setPassword:password forItem:[name stringByDeletingPathExtension]];
	
	/*
	for (unsigned i = 0; i < [documentsList count]; i++) {
		if ([[[documentsList objectAtIndex:i] name] isEqualToString:_name]) {
			[[documentsList objectAtIndex:i] setPsw:password];
		}
	}
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
//		if (DEBUG)
//			NSLog(@"Core Data synchronized");
	}	
	*/
}

-(NSString *)firstAvailableFileNameForName:(NSString *)name{
	NSMutableString * originalFileName = [NSMutableString stringWithString:name];
	if (DEBUG){
		NSLog(@"File name: %@", originalFileName);
		
	}
	[originalFileName replaceOccurrencesOfString:@".pdf" withString:@"" options:1 range:(NSRange){0,[originalFileName length]}];
	[originalFileName replaceOccurrencesOfString:@".PDF" withString:@"" options:1 range:(NSRange){0,[originalFileName length]}];
	if (DEBUG)
		NSLog(@"%@", originalFileName);			
	
	NSMutableString *path = (NSMutableString *)[DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", originalFileName]];
	if (DEBUG)
		NSLog(@"path: %@", path);
	NSMutableString *newFileName = originalFileName;
	int i = 1;
	
	while ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		newFileName = [NSString stringWithFormat:@"%@_%i",originalFileName,i];
		path = (NSMutableString *)[DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", newFileName]];
		if (DEBUG)
			NSLog(@"New Filename: %@", newFileName);
		i++;
	}
	return([NSString stringWithFormat:@"%@.pdf", newFileName]);
}

-(BOOL)existsTodaysDocument{
	BOOL retval = NO;
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateFormat:@"dd-MM-yyyy"];
	
	NSString * todayName = [NSString  stringWithFormat:@"il Fatto %@.pdf", [dateFormatter stringFromDate:[NSDate date]]];
	for (unsigned i=0; i < [documentsList count]; i++) {
		if ([[[documentsList objectAtIndex:i] name] isEqualToString:todayName]) {
			retval = YES;
		}
	}
	return retval;
}

-(Document *)createParentFolderForDocument:(Document *)document{
	Document *folder = (Document *)[NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:managedObjectContext];
	[folder setFolder:[NSNumber numberWithBool:YES]];
	[folder setOrderposition:document.orderposition];
	[folder setName:@"Folder"];
	[self insertDocument:document inFolder:folder];
	[folder retain];
	return folder;
}

-(void)insertDocument:(Document *)document inFolder:(Document *)folder{
	// Prima devo controllare se folder è una cartella, altrimenti devo farla diventare tale
	if(![folder.folder boolValue]){
		Document *newFolder = (Document *)[NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:managedObjectContext];
		[newFolder setFolder:[NSNumber numberWithBool:YES]];
		[newFolder setOrderposition:folder.orderposition];
		[newFolder setName:@"Folder"];
		[self insertDocument:folder inFolder:newFolder];
		[newFolder retain];
		folder = newFolder;
	}

	[document setValue:[NSSet setWithObject:folder] forKey:@"infolder"];
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
//		if (DEBUG)
//			NSLog(@"Core Data synchronized");
	}	
}


-(void)insertFolder:(Document *)document inFolder:(Document *)folder{	
	NSMutableArray * documents = [self getDocumentsInFolder:document];
	for(Document *doc in documents){
		[doc setValue:[NSSet setWithObject:folder] forKey:@"infolder"];
	}
	
	[self deleteDocument:document];
	
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
		//		if (DEBUG)
		//			NSLog(@"Core Data synchronized");
	}	
}

-(BOOL)documentAtIndexIsFake:(NSUInteger)index{
	if ([visibleDocumentsList count] > index && [[visibleDocumentsList objectAtIndex:index]isMemberOfClass:[Document class]]) {
		return NO;
	} else {
		return YES;
	}

}

-(Document *)getDocumentAtIndex:(NSUInteger)index{
	if ([visibleDocumentsList count] >= index) {
		return [visibleDocumentsList objectAtIndex:index];		
	} else {
		return [visibleDocumentsList objectAtIndex:0];
	}
}

-(NSMutableArray *)getDocumentsInFolder:(Document *)folder{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	NSMutableArray * documents = [NSMutableArray arrayWithArray:[[[folder valueForKeyPath:@"infolder"] allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
		
	[sortDescriptor release];
	[sortDescriptors release];
	
	
	for (unsigned i = 0; i < [documents count]; i++) {
		[[documents objectAtIndex:i] setLauncherItem:[self getImagePathForDocument:[documents objectAtIndex:i]]];
	}
	
	return documents;
}

-(NSMutableArray *)getOnlyDocumentsInFolder:(Document *)folder{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	NSMutableArray * documents = [NSMutableArray arrayWithArray:[[[folder valueForKeyPath:@"infolder"] allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
	
	[sortDescriptor release];
	[sortDescriptors release];
	
	return documents;
}


-(int)getNumberOfDocumentsInFolder:(Document *)folder{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	NSMutableArray * documents = [NSMutableArray arrayWithArray:[[[folder valueForKeyPath:@"infolder"] allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
	
	[sortDescriptor release];
	[sortDescriptors release];
	return [documents count];
}

-(float)getRowsForFolder:(Document *)folder withBooksInRow:(float)books{
	return (float)ceil([[folder valueForKeyPath:@"infolder"] count]/books);
}

-(UIImage *)getImageForDocument:(Document *)document{
	
	UIImage * thumb = nil;
	
	if([document isMemberOfClass:[Document class]]) {
		
		// Check if it's a folder
		if ([[document folder] boolValue]) {
			if([document.thumbnail length] == 0){
				NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
				NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
				
				NSMutableArray * documents = [NSMutableArray arrayWithArray:[[[document valueForKeyPath:@"infolder"] allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
				
				if ([documents count] > 0) {
					thumb = [UIImage imageWithContentsOfFile:[THUMBNAILS_FOLDER stringByAppendingPathComponent:[[documents objectAtIndex:0] thumbnail]]];
				}
				
				[sortDescriptor release];
				[sortDescriptors release];
			} else {
				thumb = [UIImage imageWithContentsOfFile:[THUMBNAILS_FOLDER stringByAppendingPathComponent:[document thumbnail]]];
			}
		} else { // else is a simple document
			
			NSString * documentThumb = [document thumbnail];
			
			if ([documentThumb isEqualToString:@"default"]) {
				if ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {	
					thumb = [UIImage imageNamed:@"cover-Pad.png"];					
				} else {
					thumb = [UIImage imageNamed:@"cover.png"];					
				}

			} else if ([documentThumb isEqualToString:THUMBNAIL_CHECK_FLAG]) {
				
				[document setThumbnail:@"default"];
				
				NSError *error;
				
				if (![managedObjectContext save:&error]) {
					
					if (DEBUG)
						NSLog(@"Error updating Core Data at thumbnail flag check");
					
				} else {
					
					// All good
					
				}
				
				if ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {	
					thumb = [UIImage imageNamed:@"cover-Pad.png"];					
				} else {
					thumb = [UIImage imageNamed:@"cover.png"];					
				}
				
				
			} else if ([documentThumb length] > 0) {
				thumb = [UIImage imageWithContentsOfFile:[THUMBNAILS_FOLDER stringByAppendingPathComponent:[document thumbnail]]];
			}
			
		}	
	}
		
	if(!thumb) {
		
		// If a valid thumbnail has not been set yet, use the default one
		
		if ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {	
			thumb = [UIImage imageNamed:@"cover-Pad.png"];					
		} else {
			thumb = [UIImage imageNamed:@"cover.png"];					
		}
	}
	
	return thumb;
}

-(NSString *)getImagePathForDocument:(Document *)document{
	
	NSString * thumb = nil;
	
	if([document isMemberOfClass:[Document class]]) {
		
		// Check if it's a folder
		if ([[document folder] boolValue]) {
			if([document.thumbnail length] == 0){			
				NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
				NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
				
				NSMutableArray * documents = [NSMutableArray arrayWithArray:[[[document valueForKeyPath:@"infolder"] allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
				
				if ([documents count] > 0) {
					// thumb = [UIImage imageWithContentsOfFile:[THUMBNAILS_FOLDER stringByAppendingPathComponent:[[documents objectAtIndex:0] thumbnail]]];
					thumb = [THUMBNAILS_FOLDER stringByAppendingPathComponent:[[documents objectAtIndex:0] thumbnail]];
				}
				
				[sortDescriptor release];
				[sortDescriptors release];
			} else {
					thumb = [THUMBNAILS_FOLDER stringByAppendingPathComponent:[document thumbnail]];				
			}
		} else { // else is a simple document
			
			NSString * documentThumb = [document thumbnail];
			
			if ([documentThumb isEqualToString:@"default"]) {
				
				if ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {	
//					thumb = [UIImage imageNamed:@"cover-Pad.png"];					
					thumb = [NSString stringWithFormat:@"bundle://cover-pad.png"];					
				} else {
// 					thumb = [UIImage imageNamed:@"cover.png"];
					thumb = [NSString stringWithFormat:@"bundle://cover.png"];
				}
				
			} else if ([documentThumb isEqualToString:THUMBNAIL_CHECK_FLAG]) {
				
				[document setThumbnail:@"default"];
				
				NSError *error;
				
				if (![managedObjectContext save:&error]) {
					
					if (DEBUG)
						NSLog(@"Error updating Core Data at thumbnail flag check");
					
				} else {
					
					// All good
					
				}
				thumb = [NSString stringWithFormat:@"bundle://cover.png"];
				if ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {	
					thumb = [NSString stringWithFormat:@"bundle://cover-pad.png"];
				} else {
					thumb = [NSString stringWithFormat:@"bundle://cover.png"];			
				}				
				
				
			} else if ([documentThumb length] > 0) {
				thumb = [THUMBNAILS_FOLDER stringByAppendingPathComponent:[document thumbnail]];
			}
			
		}	
	}
	
	if(!thumb) {
		
		// If a valid thumbnail has not been set yet, use the default one
		
		if ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {	
			thumb = [NSString stringWithFormat:@"bundle://cover-pad.png"];
		} else {
			thumb = [NSString stringWithFormat:@"bundle://cover.png"];			
		}		
	}
	
	return thumb;
}


-(BOOL)document:(Document *)document isMemberOfFolder:(Document *)folder{
	BOOL retVal = NO;
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	NSMutableArray * documents = [NSMutableArray arrayWithArray:[[[document valueForKeyPath:@"infolder"] allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
	
	if ([documents count] > 0 && [documents objectAtIndex:0] == folder) {
		retVal = YES;
	}
	
	[sortDescriptor release];
	[sortDescriptors release];
	// [documents release];
	return retVal;
}

-(id)getParentFolderForDocument:(Document *)document{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	NSMutableArray * documents = [NSMutableArray arrayWithArray:[[[document valueForKeyPath:@"infolder"] allObjects] sortedArrayUsingDescriptors:sortDescriptors]];

	[sortDescriptor release];
	[sortDescriptors release];

	if ([documents count] > 0) {
		return [documents objectAtIndex:0];
	} else {
		//return [NSString stringWithFormat:@""];
		return nil; // nil ritorna 0 se gli si chiede count, invece di crashare come fa una stringa...
	}
}

-(Document *)getDocumentInFolder:(Document *)folder atIndex:(NSUInteger)index{
	Document * retVal;
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	NSMutableArray * documents = [NSMutableArray arrayWithArray:[[[folder valueForKeyPath:@"infolder"] allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
	
	if ([documents count] >= index ) {
		retVal = [documents objectAtIndex:index];
	}
	
	[sortDescriptor release];
	[sortDescriptors release];
	return retVal;
}


// populate an array with documents at the right position with opened and closed folder
// il problema è relativo alla necessità di passare che cartella è aperta e mettere i documenti alla posizione giusta contando anche la 
-(NSMutableArray *)getVisibleDocumentsWithOpenedFolder:(Document *)_folder withBooksInRow:(float)books{
	[self readFilesFromDisk:self];
	
	// Document * folder;
	// if (_folder)	
	//	folder = (Document *)[managedObjectContext objectWithID:_folder.objectID];
	
	NSMutableArray *docList = nil;
	NSFetchRequest * documentsReq = [[NSFetchRequest alloc] init];
	NSEntityDescription * documentsEntity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext];
	[documentsReq setEntity:documentsEntity];
	NSPredicate * documentsPredicate = [NSPredicate predicateWithFormat:@"infolder.@count == 0 AND folder == NO OR folder == YES"];
	[documentsReq setPredicate:documentsPredicate];
	NSError * documentsError = nil;
	
	docList = [[managedObjectContext executeFetchRequest:documentsReq error:&documentsError] mutableCopy];
	self.visibleDocumentsList = docList;
	[docList release];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderposition" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[self.visibleDocumentsList sortUsingDescriptors:sortDescriptors];
	
	for (unsigned i = 0; i < [self.visibleDocumentsList count]; i++) {
		NSString *path = [[self getImagePathForDocument:[self.visibleDocumentsList objectAtIndex:i]]retain];
		[[self.visibleDocumentsList objectAtIndex:i] setLauncherItem:path];
		[path release];
	}
	
	if (DEBUG)
		NSLog(@"Numero di documenti: %i", [self.visibleDocumentsList count]);
	
	[sortDescriptors release];
	[sortDescriptor release];
	[documentsReq release];
	
	return self.visibleDocumentsList;
}

-(void)moveOutsideFolderDocument:(Document *)document{
	Document * folder = [self getParentFolderForDocument:document];
	if([self getNumberOfDocumentsInFolder:folder] == 1){
		// Devo anche eliminare la cartella
		[self justDeleteFolder:folder];
	}
	
	[document setValue:[NSSet set] forKey:@"infolder"];
	[document setValue:[NSNumber numberWithInt:99999999] forKey:@"orderposition"];
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
//		if (DEBUG)
//			NSLog(@"Core Data synchronized");
	}
}

-(void)moveDocument:(Document *)document before:(Document *)target{
	[document setOrderposition:[NSNumber numberWithInt:[[target orderposition] intValue] - 1]];
	NSError *commitError;
	if (![managedObjectContext save:&commitError]) {
		if (DEBUG)
			NSLog(@"Error updating Core Data");
	}
	else {
//		if (DEBUG)
//			NSLog(@"Core Data synchronized");
	}
	[self reorderDocumentsArray];
}

-(int)getIndexOfDocument:(Document *)document{
	int retVal = 0;
	for (unsigned i = 0; i < [visibleDocumentsList count]; i++) {
		if ([visibleDocumentsList objectAtIndex:i] == document)
			retVal = i;
		
	}
	return retVal;
}

-(void)dealloc{
	[documentsList release];
	[rootDocumentsList release];
	[visibleDocumentsList release];
	[super dealloc];
}

@end
