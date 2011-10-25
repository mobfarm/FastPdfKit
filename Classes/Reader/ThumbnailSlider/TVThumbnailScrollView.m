//
//  TVThumbnailView.m
//  ThumbnailView
//
//  Created by Nicolò Tosi on 10/14/11.
//  Copyright (c) 2011 MobFarm S.a.S.. All rights reserved.
//

#import "TVThumbnailScrollView.h"
// #import "TVThumbnailView.h"
#import "TVThumbnailView2.h"

@interface TVThumbnailScrollView()

@property (nonatomic,retain) NSDictionary * pendingRequests;
@property (nonatomic,retain) UIScrollView * scrollView;
@property (nonatomic,retain) NSArray * thumbnailViews;
@property (nonatomic,retain) UIView * scrollContainerView;

@property (readwrite) NSInteger startingPosition;
@property (nonatomic, readwrite) NSInteger offset;
@property (readwrite) NSInteger currentPosition;

-(NSUInteger)pageForPosition:(NSInteger)position;
-(NSInteger)positionForPage:(NSUInteger)page;

+(NSString *)thumbnailNameForPage:(NSUInteger)page;
+(NSString *)thumbnailFolderPathForDocumentId:(NSString *)documentId;
+(NSString *)thumbnailImagePathForPage:(NSUInteger)page documentId:(NSString *)documentId;

@end

@implementation TVThumbnailScrollView

@synthesize scrollView, thumbnailViews;
@synthesize cacheFolder;
@synthesize thumbnailSize, padding;
@synthesize thumbnailFolder;
@synthesize pagesCount;
@synthesize pendingRequests;
@synthesize startingPosition, offset, currentPosition;
@synthesize scrollContainerView;
@synthesize delegate;
@synthesize document;

NSString * kTVThumbnailName = @"key_tv_thumbnail_name";
NSString * kTVThumbnailReadyNotification = @"tv_thumbnail_ready_notification";

-(NSUInteger)pageForPosition:(NSInteger)position {
    return position+1;
}

-(NSInteger)positionForPage:(NSUInteger)pageNr {
    return pageNr-1;
}

+(NSString *)thumbnailNameForPage:(NSUInteger)page {
    return [NSString stringWithFormat:@"thumb_%d.tmb",page];
}

+(NSString *)thumbnailFolderPathForDocumentId:(NSString *)docId {
    
    NSString * libCacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    return [libCacheDir stringByAppendingPathComponent:docId];
}

+(NSString *)thumbnailImagePathForPage:(NSUInteger)page documentId:(NSString *)documentId {
    
    NSString * tmbName = [[self class]thumbnailNameForPage:page];
    NSString * tmbFolder = [[self class]thumbnailFolderPathForDocumentId:documentId];
    
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
    
    NSUInteger page = [self pageForPosition:currentPosition];
    NSString * path = [[self class]thumbnailImagePathForPage:page documentId:documentId];
    
    if([fileManager fileExistsAtPath:path]) {
        
        [self performSelectorOnMainThread:@selector(checkForThumbnail) withObject:nil waitUntilDone:NO];
        
    } else {
        
        // Thumbnail rendering here.
        
        CGImageRef image = [document createImageForThumbnailOfPageNumber:page ofSize:thumbnailSize andScale:1.0];
        UIImage * img = [[UIImage alloc]initWithCGImage:image];
        NSData * data = UIImagePNGRepresentation(img);
        
        [fileManager createFileAtPath:path contents:data attributes:nil];
        
        [img release];
        CGImageRelease(image);
        
        [self performSelectorOnMainThread:@selector(handleThumbDone) withObject:nil waitUntilDone:NO];
    }
    
    [pool release];
}

-(void)handleThumbDone {
    
    NSUInteger page;
    
    TVThumbnailView2 * view = [thumbnailViews objectAtIndex:currentPosition%[thumbnailViews count]];
    if(view.position==currentPosition) {
        [view reload];
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
    while(position < 0 || position >= pagesCount) {
        position = startingPosition+offset;
        offset = nextOffset(offset);
    }
    self.currentPosition = position;
    
    [self performSelectorInBackground:@selector(generateThumbnailOrSkip:) withObject:nil];
}



+(NSNotification *)thumbnailReadyNotification:(NSString *)thumbnail {
    
    NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:thumbnail,kTVThumbnailName, nil];
    
    return [NSNotification notificationWithName:kTVThumbnailReadyNotification object:nil userInfo:info];
}

CGFloat thumbnailOffset(int position, CGFloat thumbWidth, CGFloat padding, CGFloat viewportWidth) {
    //return ((viewportWidth - thumbWidth) * 0.5) + (position * (thumbWidth + padding));
    return ((viewportWidth - thumbWidth) * 0.5) + position * thumbWidth;
}

CGFloat contentWidth (CGFloat thumbWidth, CGFloat padding, int count, CGFloat viewportWidth) {
    //return viewportWidth + (count-1)*(thumbWidth + padding);
    return  viewportWidth + (count - 1) * thumbWidth;
}

CGFloat contentOffset(int position, CGFloat thumbWidth, CGFloat padding, CGFloat viewportWidth) {
    
    //return 0.0 + ((thumbWidth + padding) * position);
    return thumbWidth * position;
}

NSUInteger thumbnailPositionForOffset(CGFloat offset, CGFloat thumbWidth, CGFloat padding, CGFloat viewportWidth) {
    
    //return floorf((offset + ((thumbWidth + padding) * 0.5)) / (thumbWidth + padding));
    return (offset + (thumbWidth * 0.5)) / thumbWidth;
}

CGFloat rightOffsetForThumbnailPosition(int position, CGFloat thumbWidth, CGFloat padding, CGFloat viewportWidth) {
    //return (thumbWidth + padding) * (float)position;
    return thumbWidth * position;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self setAutoresizesSubviews:YES];
        [self setBackgroundColor:[UIColor blackColor]];
        
        UIView * aScrollContainerView = [[UIView alloc]initWithCoder:aDecoder];
        [aScrollContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [aScrollContainerView setAutoresizesSubviews:YES];
        
        UIScrollView * aScrollView = [[UIScrollView alloc]initWithCoder:aDecoder];
        [aScrollView setBackgroundColor:[UIColor darkGrayColor]];
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
        [self setBackgroundColor:[UIColor blackColor]];
        
        UIView * aScrollContainerView = [[UIView alloc]initWithFrame:frame];
        [aScrollContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [aScrollContainerView setAutoresizesSubviews:YES];
        
        UIScrollView * aScrollView = [[UIScrollView alloc]initWithFrame:frame];
        [aScrollView setBackgroundColor:[UIColor redColor]];
        [aScrollView setDelegate:self];
        
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

-(void)setPage:(NSUInteger)page animated:(BOOL)animated {
    
    NSInteger position = [self positionForPage:page];
    CGFloat offset = rightOffsetForThumbnailPosition(position, thumbnailSize.width, padding, self.bounds.size.width);
    
    [scrollView setContentOffset:CGPointMake(offset, 0) animated:animated];
}

-(void)page {
    
    return [self pageForPosition:currentThumbnailPosition];
}

-(void)alignToThumbnail {
    
    int position = thumbnailPositionForOffset(scrollView.contentOffset.x, thumbnailSize.width, padding, self.bounds.size.width);
    
    CGFloat offset = rightOffsetForThumbnailPosition(position, thumbnailSize.width, padding, self.bounds.size.width);
    
    [scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    [self alignToThumbnail];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if(!decelerate) {
        [self alignToThumbnail];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"didEndScrollingAnimation");
}


BOOL isViewOutsideRange(int viewPosition, int currentPosition, int count) {
    
    return (abs(viewPosition-currentPosition) > (count/2));
}

-(void)thumbTapped:(NSInteger)position withObject:(id)obj {
    [self setPage:[self pageForPosition:position] animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // NSLog(@"didScroll");
    
    int thumbPosition = thumbnailPositionForOffset(scrollView.contentOffset.x, thumbnailSize.width, padding, self.bounds.size.width);
    
    if(currentThumbnailPosition != thumbPosition) {
     
        currentThumbnailPosition = thumbPosition;
        
        int position;
        int count = [thumbnailViews count];
        
        for(TVThumbnailView2 * view in thumbnailViews) {
            
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
                
                view.pageNumber = [NSNumber numberWithUnsignedInt:[self pageForPosition:position]];
                view.thumbnailImagePath = [[self class]thumbnailImagePathForPage:[self pageForPosition:position] documentId:documentId];
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

-(NSString *)imagePathForPosition:(int)position {
    return [thumbnailFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%6d.tmb",position+1]];
}
                       
-(NSString *)imagePathForThumbnailView:(TVThumbnailView2 *)view {
    
    return [self imagePathForPosition:view.position];
}

-(void)requestImageForThumbnailView:(TVThumbnailView2 *)view {
    
    return;
    
    // NSString * path = [self imagePathForThumbnailView:view];
    // NSUInteger page = view.position+1;
    NSNumber * page;
    if([pendingRequests valueForKey:view]) {
        
        page = [pendingRequests valueForKey:view];
        [delegate cancelThumbnailForPage:[page unsignedIntValue]];
        
    } else {
        
        
        
    }
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
            
            TVThumbnailView2 * thumbnailView = [[TVThumbnailView2 alloc]initWithFrame:CGRectZero]; // Will be layed out later.
            thumbnailView.backgroundColor = [UIColor greenColor];
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
    
    for(TVThumbnailView2 * view in thumbnailViews) {
        
        int position = view.position;
        
        CGRect frame = CGRectMake(thumbnailOffset(position, thumbnailSize.width, padding, bounds.size.width), (bounds.size.height - thumbnailSize.height) * 0.5, thumbnailSize.width, thumbnailSize.height);
        view.frame = frame;
        view.pageNumber = [NSNumber numberWithUnsignedInt:[self pageForPosition:position]];
        view.thumbnailImagePath = [[self class]thumbnailImagePathForPage:[self pageForPosition:position] documentId:documentId];
    }
    
    scrollView.contentSize = CGSizeMake(contentWidth(thumbnailSize.width, padding, pagesCount, bounds.size.width), bounds.size.height);
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

-(void)dealloc {
    
    [cacheFolder release];
    [thumbnailViews release];
    
    scrollView.delegate = nil, [scrollView release];
    
    [thumbnailFolder release],thumbnailFolder = nil;
    
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
