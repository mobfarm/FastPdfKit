//
//  MFFileManager.h
//  PDFReaderHD
//
//  Created by Matteo Gavagnin on 15/04/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Document.h"
#import "DirectoryWatcher.h"

@interface MFFileManager : NSObject <DirectoryWatcherDelegate> {
	NSMutableArray *documentsList;
	NSMutableArray *rootDocumentsList;
	NSMutableArray *visibleDocumentsList;
	NSManagedObjectContext *managedObjectContext;
	id delegate;
	DirectoryWatcher *docWatcher;
	BOOL canReloadDocuments;
}
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) NSMutableArray *documentsList;
@property(nonatomic, retain) NSMutableArray *rootDocumentsList;
@property(nonatomic, retain) NSMutableArray *visibleDocumentsList;
@property(assign) id delegate;
@property (nonatomic, retain) DirectoryWatcher *docWatcher;
@property (nonatomic) BOOL canReloadDocuments;

-(id)initWithManagedContext:(NSManagedObjectContext *)context;
-(void)readFilesFromDisk:(id)sender;
-(void)reloadCoreDataDocuments:(id)sender;
-(void)deleteFileAtIndex:(NSUInteger)_index;
-(void)createThumbnailForDocumentNamed:(NSString *)name;
-(void)updateThumbnailForDocumentOfName:(NSString *)name;
-(void)createCoreDataForFileAtIndex:(NSUInteger)_index;
-(void)deleteCoreDataForFileAtIndex:(NSUInteger)_index;

-(NSNumber *)getFileSizeForFileAtIndex:(NSUInteger)_index;

-(NSNumber *)getDocumentIndexFromName:(NSString *)_name;
-(Document *)getDocumentFromName:(NSString *)_name;
-(void)reorderDocumentsArray;
-(NSString *)getPasswordForDocumentWithName:(NSString *)_name;
-(void)setPassword:(NSString *)password forDocumentWithName:(NSString *)_name;
-(NSString *)firstAvailableFileNameForName:(NSString *)name;
-(BOOL)existsTodaysDocument;
-(Document *)getDocumentAtIndex:(NSUInteger)index;
-(float)getRowsForFolder:(Document *)folder withBooksInRow:(float)books;
-(void)createRootDocumentsAndFolders;
-(UIImage *)getImageForDocument:(Document *)document;
-(BOOL)document:(Document *)document isMemberOfFolder:(Document *)folder;
-(Document *)getDocumentInFolder:(Document *)folder atIndex:(NSUInteger)index;
-(NSMutableArray *)getVisibleDocumentsWithOpenedFolder:(Document *)folder withBooksInRow:(float)books;
-(BOOL)documentAtIndexIsFake:(NSUInteger)index;
-(int)getIndexOfDocument:(Document *)document;
-(id)getParentFolderForDocument:(Document *)document;

-(int)getNumberOfDocumentsInFolder:(Document *)folder;
-(NSString *)getImagePathForDocument:(Document *)document;
-(void)manualSetThumbnailForDocument:(Document *)document withImage:(UIImage *)image;
-(void)manualSetThumbnailForDocument:(Document *)document withString:(NSString *)image;
-(void)renameFileAtIndex:(NSUInteger)_index withName:(NSString *)_name;
-(BOOL)canRenameFile:(NSUInteger)_index withNewName:(NSString *)_name;


// Mi interessano per la gestione delle cartelle...
-(void)insertDocument:(Document *)object inFolder:(Document *)folder;
-(Document *)createParentFolderForDocument:(Document *)document;
-(void)setPosition:(NSUInteger)position forFileAtIndex:(NSUInteger)_index;
-(NSMutableArray *)getDocumentsInFolder:(Document *)folder;
-(void)deleteDocument:(Document *)document;
-(void)deleteFolderAndIncludedDocuments:(Document *)document;
-(NSArray *)deleteFolderAndGetDocuments:(Document *)document;
-(BOOL)renameDocument:(Document *)document withName:(NSString *)_name;
-(void)moveOutsideFolderDocument:(Document *)document;
-(void)moveDocument:(Document *)document before:(Document *)target; 

-(void)updateTableAfterLock:(id)sender;
-(NSMutableArray *)getOnlyDocumentsInFolder:(Document *)folder;
-(void)justDeleteFolder:(Document *)document;
-(void)insertFolder:(Document *)document inFolder:(Document *)folder;
-(void)setPositionsForDocuments:(NSArray *)documents;
@end
