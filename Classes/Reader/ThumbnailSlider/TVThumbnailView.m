//
//  TVThumbnailView.m
//  ThumbnailView
//
//  Created by Nicolò Tosi on 10/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TVThumbnailView.h"
#import "TVThumbnailScrollView.h"

@interface TVThumbnailView()

@property (nonatomic,copy) NSString * imagePath;

@end


@implementation TVThumbnailView

@synthesize position, imagePath;
@synthesize image;
@synthesize delegate;
@synthesize pendingThumbnailName;

-(void)setImage:(UIImage *)newImage {
    if(image!=newImage) {
        [image release];
        image = [newImage retain];
        [self setNeedsDisplay];
    }
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self) {
        
        UIActivityIndicatorView * anActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [anActivityIndicator hidesWhenStopped];
        self.activityIndicator = anActivityIndicator;
        [self addSubview:anActivityIndicator];
        [anActivityIndicator release];
    }
    
    return self;
}


//-(void)loadImage:(NSString *)path { 
//    
//    // Invoca questo su un thread secondario in modo che il caricamento dell'immagine da disco non blocchi il thread principale. Poi il settaggio
//    // dell'immagine finisce comunque con l'essere fatto sul main thread.
//    
//    UIImage * image = nil;
//    NSFileManager * fileManager = [[NSFileManager alloc]init];
//    
//    if([fileManager fileExistsAtPath:path]) {
//        
//        image = [[UIImage alloc]initWithContentsOfFile:path];
//        
//        [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
//        
//        [image release];
//    
//    } else {
//        
//        self.pendingThumbnailName = path;
//        
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleThumbnailReadyNotification:) name:kTVThumbnailReadyNotification object:nil];
//    
//        [self performSelectorOnMainThread:@selector(setImage:) withObject:nil waitUntilDone:NO];
//        [self performSelectorOnMainThread:@selector(askImage:) withObject:nil waitUntilDone:NO];
//    }
//    
//    [fileManager release];
//}
//
//-(void)handleThumbnailReadyNotification:(NSNotification *)notification {
//    
//    NSDictionary * info = [notification userInfo];
//    NSString * thumbnailName = [notification valueForKey:kTVThumbnailName];
//    
//    if([thumbnailName isEqualToString:pendingThumbnailName]) {
//        
//        self.pendingThumbnailName = nil;
//        
//        [[NSNotificationCenter defaultCenter]removeObserver:self name:kTVThumbnailReadyNotification object:nil];
//        
//        [self performSelectorInBackground:@selector(loadImage:) withObject:pendingThumbnailName];
//    }
//}

-(void)setPosition:(NSUInteger)newPosition {
    
    if(position!=newPosition) {
        position = newPosition;
        
        NSString * thumbnailPath = [delegate imagePathForThumbnailView:self];
        
        [self performSelectorInBackground:@selector(loadImage:) withObject:thumbnailPath];
    }
}

-(void)drawRect:(CGRect)rect {
    
    if(image) {
        
        CGFloat hRatio = rect.size.width/image.size.width;
        CGFloat vRatio = rect.size.height/image.size.height;
        CGFloat minRatio = fminf(hRatio, vRatio);
        
        CGFloat imgWidth = image.size.width * minRatio;
        CGFloat imgHeight = image.size.height * minRatio;
        
        CGFloat imgX = rect.size.width - image.size.width;
        CGFloat imgY = rect.size.height - image.size.height;
        
        CGRect imgRect = CGRectMake(imgX, imgY, imgWidth, imgHeight);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGRect clipbox = CGContextGetClipBoundingBox(ctx);
        CGContextClearRect(ctx, clipbox);
        
        [image drawInRect:imgRect];
        
    } else {
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(ctx);
        
        CGRect clipbox = CGContextGetClipBoundingBox(ctx);
        CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0); // White color
        CGContextFillRect(ctx, clipbox);
        
        CGContextRestoreGState(ctx);
    }
}

-(void)dealloc {
    
    [imagePath release], imagePath = nil;
    [image release],image = nil;
}

@end
