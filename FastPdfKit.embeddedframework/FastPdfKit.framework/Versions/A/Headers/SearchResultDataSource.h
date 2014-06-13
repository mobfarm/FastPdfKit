//
//  SearchResultDataSource.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/27/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SearchResultDataSource

-(NSArray *)searchItemsForPage:(NSUInteger)page;

@end
