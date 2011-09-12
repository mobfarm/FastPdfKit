//
//  MFSearchResult.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/25/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MFSearchResult : NSObject {

	@private
	NSUInteger page;
	NSArray *searchItems;
	
}

/**
 Returns the number of items in the result.
 */
-(NSUInteger)size;

/**
 The page that generated this result.
 */
@property (readonly) NSUInteger page;

/**
 An array of MFTextItem.
 */
@property (readonly) NSArray *searchItems;

/**
 Default constructor. The array will be copied.
 */
-(id)initWithSearchItems:(NSArray *)someItems forPage:(NSUInteger)aPage;

@end
