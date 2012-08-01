//
//  TVThumbnailView.m
//  ThumbnailView
//
//  Created by Nicolò Tosi on 10/14/11.
//  Copyright (c) 2011 MobFarm S.a.s.. All rights reserved.
//

#import "TVThumbnailScrollView.h"

@interface TVThumbnailScrollView()

@property (nonatomic,retain) NSDictionary * pendingRequests;
@property (nonatomic,retain) UIScrollView * scrollView;
@property (nonatomic,retain) NSArray * thumbnailViews;
@property (nonatomic,retain) UIView * scrollContainerView;

@property (readwrite) NSInteger startingPosition;
@property (nonatomic, readwrite) NSInteger offset;
@property (readwrite) NSInteger currentPosition;
@property (retain) NSFileManager * fileManager;

-(NSUInteger)pageForPosition:(NSInteger)position;
-(NSInteger)positionForPage:(NSUInteger)page;

+(NSString *)thumbnailNameForPage:(NSUInteger)page;
+(NSString *)thumbnailFolderPathForPath:(NSString *)documentId;
+(NSString *)thumbnailImagePathForPage:(NSUInteger)page cacheFolderPath:(NSString *)documentId;

-(void)checkForThumbnail;

@end

@implementation TVThumbnailScrollView

@synthesize scrollView, thumbnailViews;
@synthesize thumbnailSize, padding;
@synthesize pagesCount;
@synthesize pendingRequests;
@synthesize startingPosition, offset, currentPosition;
@synthesize scrollContainerView;
@synthesize delegate;
@synthesize document;
@synthesize cacheFolderPath;
@synthesize fileManager;

NSString * kTVThumbnailName = @"key_tv_thumbnail_name";
NSString * kTVThumbnailReadyNotification = @"tv_thumbnail_ready_notification";

-(NSUInteger)pageForPosition:(NSInteger)position {
    return position+1;
}

-(NSInteger)positionForPage:(NSUInteger)pageNr {
    return pageNr-1;
}

+(NSString *)thumbnailNameForPage:(NSUInteger)page {
    return [NSString stringWithFormat:@"thumb_%6d.tmb",page];
}

+(NSString *)thumbnailFolderPathForPath:(NSString *)docId {
    
    if(docId) {
        return docId;
    }
    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}

+(NSString *)thumbnailImagePathForPage:(NSUInteger)page cacheFolderPath:(NSString *)documentId {
    
    NSString * tmbName = [[self class]thumbnailNameForPage:page];
    NSString * tmbFolder = [[self class]thumbnailFolderPathForPath:documentId];
    
    return [tmbFolder stringByAppendingPathComponent:tmbName];
}

int nextOffset(int offset) {
    
    if(offset > 0) {
        return offset * (-1);
    } else if (offset < 0) {
        return (offset * (-1))+1;
    } else {
        return 1;
    }
}

-(void)generateThumbnailOrSkip:(id)something {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    if(!fileManager) {
        fileManager = [[NSFileManager alloc]init];
    }
    
    NSUInteger pageNr = [self pageForPosition:currentPosition];
    NSString * path = [[self class]thumbnailImagePathForPage:pageNr cacheFolderPath:cacheFolderPath];
    
    if([fileManager fileExistsAtPath:path]) {
        
        [self performSelectorOnMainThread:@selector(checkForThumbnail) withObject:nil waitUntilDone:NO];
        
    } else {
        
        CGFloat scale = 1.0;
        
        // Check if it's a Retina Display
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            scale = [[UIScreen mainScreen] scale];
        }
        
        // Thumbnail rendering here.
        CGImageRef image = [document createImageForThumbnailOfPageNumber:pageNr ofSize:thumbnailSize andScale:scale];
        UIImage * img = [[UIImage alloc]initWithCGImage:image];
        NSData * data = UIImagePNGRepresentation(img);
        
        [fileManager createFileAtPath:path contents:data attributes:nil];
        
        CGImageRelease(image);         // You are responsible for release the CGImageRef.
        
        [self performSelectorOnMainThread:@selector(handleThumbDone:) withObject:img waitUntilDone:NO];
        
        [img autorelease];
    }
    
    [pool release];
}

-(void)handleThumbDone:(UIImage *)image {
    
    NSUInteger page;
    
    
    TVThumbnailView * view = [thumbnailViews objectAtIndex:currentPosition%[thumbnailViews count]];
    
    if(view.position==currentPosition) {
        [view reloadImage:image];
    }
    
    [self checkForThumbnail];
}

-(void)checkForThumbnail {
    
    if(!shouldContinueBackgrounWork) {
        backgroundWorkStillGoingOn = NO;
        return;
    } else {
        backgroundWorkStillGoingOn = YES;
    }
    
    if(startingPosition!=currentThumbnailPosition) {
        
        startingPosition = currentThumbnailPosition;
        offset = 0;
    }
    
    int position = startingPosition+offset;
    offset = nextOffset(offset);
    int retry = 2;
    while((position < 0 || position >= pagesCount) && retry > 0) {
        position = startingPosition+offset;
        offset = nextOffset(offset);
        retry--;
    }
    
    if(retry > 0) {
        self.currentPosition = position;
        
        [self performSelectorInBackground:@selector(generateThumbnailOrSkip:) withObject:nil];    
    } else {
        backgroundWorkStillGoingOn = NO;
    }
}



+(NSNotification *)thumbnailReadyNotification:(NSString *)thumbnail {
    
    NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:thumbnail,kTVThumbnailName, nil];
    
    return [NSNotification notificationWithName:kTVThumbnailReadyNotification object:nil userInfo:info];
}

CGFloat thumbnailOffset(int position, CGFloat thumbWidth, CGFloat padding, CGFloat viewportWidth) {
    
    return ((viewportWidth - thumbWidth) * 0.5) + position * thumbWidth;
}

CGFloat contentWidth (CGFloat thumbWidth, CGFloat padding, int count, CGFloat viewportWidth) {
    
    return  viewportWidth + (count - 1) * thumbWidth;
}

CGFloat contentOffset(int position, CGFloat thumbWidth, CGFloat padding, CGFloat viewportWidth) {
    
    
    return thumbWidth * position;
}

NSUInteger thumbnailPositionForOffset(CGFloat offset, CGFloat thumbWidth, CGFloat padding, CGFloat viewportWidth) {
    
    
    return (offset + (thumbWidth * 0.5)) / thumbWidth;
}

CGFloat rightOffsetForThumbnailPosition(int position, CGFloat thumbWidth, CGFloat padding, CGFloat viewportWidth) {
    
    return thumbWidth * position;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self setAutoresizesSubviews:YES];
        
        UIView * aScrollContainerView = [[UIView alloc]initWithCoder:aDecoder];
        [aScrollContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [aScrollContainerView setAutoresizesSubviews:YES];
        
        UIScrollView * aScrollView = [[UIScrollView alloc]initWithCoder:aDecoder];
        aScrollView.delegate = self;
        self.scrollView = aScrollView;
        
        currentThumbnailPosition = 0;
        thumbnailSize = CGSizeMake(90, 120);
        padding = 20;

        [aScrollContainerView addSubview:aScrollView];
        [self addSubview:aScrollContainerView];
        [aScrollView release];
        [aScrollContainerView release];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    
        [self setAutoresizesSubviews:YES];
        
        UIView * aScrollContainerView = [[UIView alloc]initWithFrame:frame];
        [aScrollContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [aScrollContainerView setAutoresizesSubviews:YES];
        
        UIScrollView * aScrollView = [[UIScrollView alloc]initWithFrame:frame];
        [aScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [aScrollView setDelegate:self];
        [aScrollView setShowsVerticalScrollIndicator:NO];
        [aScrollView setShowsHorizontalScrollIndicator:NO];
        
        self.scrollView = aScrollView;
    
        currentThumbnailPosition = 0;
        thumbnailSize = CGSizeMake(90, 120);
        padding = 0.0;
        
        [aScrollContainerView addSubview:aScrollView];
        [self addSubview:aScrollContainerView];
        [aScrollView release];
        [aScrollContainerView release];
    }
    
    return self;
}

-(void)setPage:(NSUInteger)pageNr animated:(BOOL)animated {
    
    NSInteger position = [self positionForPage:pageNr];
    CGFloat contentOffset = rightOffsetForThumbnailPosition(position, thumbnailSize.width, padding, self.bounds.size.width);
    
    [scrollView setContentOffset:CGPointMake(contentOffset, 0) animated:animated];
}

-(NSUInteger)page {
    
    return [self pageForPosition:currentThumbnailPosition];
}

-(void)alignToThumbnail {
    
    int position = thumbnailPositionForOffset(scrollView.contentOffset.x, thumbnailSize.width, padding, self.bounds.size.width);
    
    CGFloat contentOffset = rightOffsetForThumbnailPosition(position, thumbnailSize.width, padding, self.bounds.size.width);
    
    [scrollView setContentOffset:CGPointMake(contentOffset, 0) animated:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self alignToThumbnail];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if(!decelerate) {
        [self alignToThumbnail];
    }
}


BOOL isViewOutsideRange(int viewPosition, int currentPosition, int count) {
    
    return (abs(viewPosition-currentPosition) > (count/2));
}

-(void)thumbTapped:(NSInteger)position withObject:(id)obj {
    [delegate thumbnailScrollView:self didSelectPage:[self pageForPosition:position]];
    //[self setPage:[self pageForPosition:position] animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    // NSLog(@"didScroll");
    
    int thumbPosition = thumbnailPositionForOffset(scrollView.contentOffset.x, thumbnailSize.width, padding, self.bounds.size.width);
    
    if(currentThumbnailPosition != thumbPosition) {
     
        currentThumbnailPosition = thumbPosition;
        
        int position;
        int count = [thumbnailViews count];
        int pageNr;
        
        for(TVThumbnailView * view in thumbnailViews) {
            
            position = view.position;
            BOOL done = NO;
            
            while (isViewOutsideRange(position, thumbPosition, count) && (!done)) {
                
                if(position < thumbPosition) {
                    
                    position += count; 
                    
                    if(position >= pagesCount) {
                        position-=count;
                        done = YES;
                    }
                    
                } else if (position > thumbPosition) {
                    
                    position -= count;
                    
                    if(position < 0) {
                        position+=count;
                        done = YES;
                    }
                }
            }
            
            if(view.position!=position) {
             
                view.position = position;

                CGRect frame = view.frame;
                frame.origin.x = thumbnailOffset(position, thumbnailSize.width, padding, self.bounds.size.width);
                view.frame = frame;
                pageNr = [self pageForPosition:position];                
                view.pageNumber = [NSNumber numberWithUnsignedInt:pageNr];
                view.thumbnailImagePath = [[self class]thumbnailImagePathForPage:pageNr cacheFolderPath:cacheFolderPath];
            }
        }
    }
}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
        //NSLog(@"willBeginDecelerating");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //NSLog(@"willBeginDragging");
}

-(void)setPagesCount:(NSUInteger)newPagesCount {
    
    if(newPagesCount!=pagesCount) {
        pagesCount = newPagesCount;
        [self setNeedsLayout];
        //[self setNeedsDisplay];
    }
}

-(void)setThumbnailSize:(CGSize)newThumbnailSize {
    if(!CGSizeEqualToSize(thumbnailSize, newThumbnailSize)) {
        thumbnailSize = newThumbnailSize;
        [self setNeedsLayout];
    }
}

-(void)setPadding:(CGFloat)newPadding {
    if(padding!=newPadding) {
        padding = newPadding;
        [self setNeedsLayout];
    }
}

int numberOfThumbnails(CGFloat viewportWidth, CGFloat thumbWidth, CGFloat padding) {
    int count = ceilf(viewportWidth/(thumbWidth + padding))+1;
    if(count%2 == 0)
        count++;
    return count;
}

-(void)start {
    
    if(backgroundWorkStillGoingOn) {
        return;
    } else {
        shouldContinueBackgrounWork = YES;
        [self checkForThumbnail];
    }
}

-(void)stop {
    
    shouldContinueBackgrounWork = NO;
}

-(void)layoutSubviews {
    
    CGRect bounds = self.bounds;
    
    int maxNumberOfThumbnails = numberOfThumbnails(bounds.size.width,thumbnailSize.width,padding);
    
    int newThumbnailCount = maxNumberOfThumbnails < pagesCount ? maxNumberOfThumbnails : pagesCount;
    
    if(newThumbnailCount != thumbnailCount) {
        
        for(UIView * thumbnailView in thumbnailViews) {
            [thumbnailView removeFromSuperview];
        }
        
        NSMutableArray * thumbnailArray = [[NSMutableArray alloc]initWithCapacity:newThumbnailCount];
        
        int i;
        for(i = 0; i < newThumbnailCount; i++) {
            
            TVThumbnailView * thumbnailView = [[TVThumbnailView alloc]initWithFrame:CGRectZero]; // Will be layed out later.
            thumbnailView.position = i;
            thumbnailView.delegate = self;
            [thumbnailArray addObject:thumbnailView];
            [scrollView addSubview:thumbnailView];
            [thumbnailView release];
        }
        
        self.thumbnailViews = thumbnailArray;
        
        [thumbnailArray release];
    }
    
    thumbnailCount = newThumbnailCount;
    
    for(TVThumbnailView * view in thumbnailViews) {
        
        int position = view.position;
        BOOL done = NO;
        
        while (isViewOutsideRange(position, currentThumbnailPosition, thumbnailCount) && (!done)) {
            
            if(position < currentThumbnailPosition) {
                
                position += thumbnailCount; 
                
                if(position >= pagesCount) {
                    position-=thumbnailCount;
                    done = YES;
                }
                
            } else if (position > currentThumbnailPosition) {
                
                position -= thumbnailCount;
                
                if(position < 0) {
                    position+=thumbnailCount;
                    done = YES;
                }
            }
        }

        CGRect frame = CGRectMake(thumbnailOffset(position, thumbnailSize.width, padding, bounds.size.width), (bounds.size.height - thumbnailSize.height) * 0.5, thumbnailSize.width, thumbnailSize.height);
        view.frame = frame;
        view.pageNumber = [NSNumber numberWithUnsignedInt:[self pageForPosition:position]];
        view.thumbnailImagePath = [[self class]thumbnailImagePathForPage:[self pageForPosition:position] cacheFolderPath:cacheFolderPath];
    }
    
    //scrollContainerView.frame = self.bounds;
    //scrollView.frame = self.bounds;
    scrollView.contentSize = CGSizeMake(contentWidth(thumbnailSize.width, padding, pagesCount, bounds.size.width), bounds.size.height);
    
    CGFloat contentOffset = rightOffsetForThumbnailPosition(currentThumbnailPosition, thumbnailSize.width, padding, bounds.size.width);   
    [scrollView setContentOffset:CGPointMake(contentOffset, 0) animated:NO];
}

-(void)dealloc {
    
    [cacheFolderPath release];
    [thumbnailViews release];

    scrollView.delegate = nil, [scrollView release], scrollView = nil;
    
    [scrollContainerView release];
    
    delegate = nil;
    
    [fileManager release],fileManager = nil;
    
    [document release];
    
    [super dealloc];
}

@end
