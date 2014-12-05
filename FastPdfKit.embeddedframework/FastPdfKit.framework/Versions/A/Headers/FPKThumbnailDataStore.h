//
//  FPKThumbnailStore.h
//  FastPdfKitLibrary
//
//  Created by Nicolo' on 04/12/14.
//
//

@protocol FPKThumbnailDataStore <NSObject>

-(NSData *)loadDataForPage:(NSUInteger)page;
-(void)saveData:(NSData *)data page:(NSUInteger)page;
-(BOOL)dataAvailableForPage:(NSUInteger)page;

@end