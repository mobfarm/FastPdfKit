//
//  MFDocumentViewControllerDelegate.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/19/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stuff.h"
#import "MFAudioPlayerViewProtocol.h"

@class MFDocumentViewController;

@protocol MFDocumentViewControllerDelegate

@optional

-(void)documentViewController:(MFDocumentViewController *)dvc didChangeDirectionTo:(MFDocumentDirection)direction;

/**
 This method will be called to notify the transition to a new page. Use this to update page number related UI's elements or synchronize selected actions.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didGoToPage:(NSUInteger)page;

/**
 This method will notify a change in the lead used to present the document.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didChangeLeadTo:(MFDocumentLead)lead;

/**
 This method will notify a change in the mode of the document, either by esplicity setting it or automatic on rotation.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didChangeModeTo:(MFDocumentMode)mode automatic:(BOOL)automatically;

/**
 This method will notify a change in the direction used to present the document.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didChangeDirectionTo:(MFDocumentDirection)direction;

/**
 This method will notify if the user has tapped the document view at a point different from a document element, like an annotation.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point;

/**
 This method will notify if the user has tapped on a annotation with a remote uri action. This is usually invoked when an external
 link is activated and an internet browser should be open to show the link's content.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didReceiveURIRequest:(NSString *)uri;

/**
 This method will notify if and where the user has tapped on a page bounds. Coordinates of the point are in document's user space. 
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnPage:(NSUInteger)page atPoint:(CGPoint)point;

/**
 This method will report the last zoom level achieved by the document detail view. You can use this callback to animate an icon
 that report the current zoom to the user.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didEndZoomingAtScale:(float)level;

/**
 This method will be called right before displaying a high definition version of the current page. Could be used to start an Activity Indicator.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc willFocusOnPage:(NSUInteger)page;

/**
 This method will be called upon the showing up of the high definition version of the current page. Could be used to stop and Activity Indicator.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didFocusOnPage:(NSUInteger)page;

/**
 This method will be called when the high definition version of the page is removed from the view.
 */
-(void)documentViewControllerDidUnfocus:(MFDocumentViewController *)dvc;

/**
 This method will be called when user double tap on an annotation.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didReceiveDoubleTapOnAnnotationRect:(CGRect)rect withUri:(NSString *)uri onPage:(NSUInteger)page;

/**
 This method will be called when an user tap on an annotation.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnAnnotationRect:(CGRect)rect withUri:(NSString *)uri onPage:(NSUInteger)page;

/**
 This method will be called to ask the delegate if the video player needs to start automatically once visible.
 */
-(BOOL)documentViewController:(MFDocumentViewController *)dvc doesHaveToAutoplayVideo:(NSString*)videoUri;

/**
 Implement this method to return whether the audio clip should play automatically once loaded.
 */
-(BOOL)documentViewController:(MFDocumentViewController *)dvc doesHaveToAutoplayAudio:(NSString*)audioUri;

/**
 This method will be invoked when the user tap on an annotation with an associated Go-To Remote action. The user can then load the file passed as third argument
 and then get the page number with MFDocumentManager's -pageNumberForDestinationNamed: and present the right page for display.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didReceiveRequestToGoToDestinationNamed:(NSString *)destinationName ofFile:(NSString *)fileName;

/**
 This method will be invoked when the user tap on an annotation with an associated Go-To Remote action. The user can then load the file passed as last argument
 and then set the page to the page number passed as second parameter.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didReceiveRequestToGoToPage:(NSUInteger)pageNumber ofFile:(NSString *)fileName;


/**
 This method will be called to provide a class of the view to use as player audio control. You can use the default class provide in the sample
 or develop your own to suit the look and feel of you application better.
 */
-(Class<MFAudioPlayerViewProtocol>)classForAudioPlayerView;

@end
