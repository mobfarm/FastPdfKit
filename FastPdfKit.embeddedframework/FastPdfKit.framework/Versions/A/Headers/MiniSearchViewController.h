//
//  MiniSearchViewController.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 31/10/13.
//
//

#import <UIKit/UIKit.h>
#import "MiniSearchViewControllerDelegate.h"
#import "SearchManager.h"
#import "MFTextItem.h"
#import "SearchResultView.h"

@interface MiniSearchViewController : UIViewController

@property (nonatomic,weak) UIButton *nextButton;
@property (nonatomic,weak) UIButton *prevButton;
@property (nonatomic,weak) UIButton *cancelButton;
@property (nonatomic,weak) UIButton *fullButton;

@property (nonatomic,weak) id<MiniSearchViewControllerDelegate> documentDelegate;
@property (nonatomic,weak) SearchManager *dataSource;

@property (nonatomic,weak) UILabel *pageLabel;

@property (weak, nonatomic) IBOutlet UIToolbar * toolbar;
@property (weak, nonatomic) IBOutlet UILabel * snippetLabel;

@property (nonatomic,strong) SearchResultView *searchResultView;

-(void)reloadData;
-(void)setCurrentResultIndex:(NSUInteger)index;
-(void)setCurrentTextItem:(MFTextItem *)item;
-(void)actionNext:(id)sender;
-(void)actionPrev:(id)sender;
-(void)moveToPrevResult;
-(void)moveToNextResult;

@end
