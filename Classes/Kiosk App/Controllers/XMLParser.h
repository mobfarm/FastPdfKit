//
//  XMLParser.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMLParser : NSObject <NSXMLParserDelegate>{
	
}

-(void)parseXMLFileAtURL:(NSURL *)URL;
-(BOOL)isDone;
-(NSMutableArray *)parsedItems;

@end
