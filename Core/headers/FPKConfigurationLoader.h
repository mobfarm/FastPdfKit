//
//  FPKConfigurationJSONLoader.h
//  FastPdfKitLibrary
//
//  Created by Nicolo' on 13/06/14.
//
//

#import <Foundation/Foundation.h>

@interface FPKConfigurationLoader : NSObject

+(NSDictionary *)configurationDictionaryWithJSONFile:(NSString *)path;
+(NSDictionary *)configurationDictionaryWithXMLFile:(NSString *)path;
+(NSDictionary *)configurationDictionaryWithPlistFile:(NSString *)path;

@end
