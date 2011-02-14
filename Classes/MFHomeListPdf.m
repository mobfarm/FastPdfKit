//
//  ThumbnailViewController.m
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import "MFHomeListPdf.h"
#import "MenuViewController.h"


@implementation MFHomeListPdf
@synthesize object, temp, dataSource,senderButton ,corner,PdfToDownload,numDocumento;
@synthesize mvc;

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithName:(NSString *)Page andnumOfDoc:(int)numDoc andImage:(NSString *)_image andSize:(CGSize)_size{
	size = _size;
	thumbnail = _image;
	page = Page;
	numDocumento = numDoc;
	temp = NO;
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// NSLog(@"Did load Page %i", page);
	[self.view setBackgroundColor:[UIColor clearColor]];
	if (temp) {
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[spinner setFrame:CGRectMake(size.width/2.0 - spinner.frame.size.width/2.0, size.height/2.0 - spinner.frame.size.height/2.0, spinner.frame.size.width, spinner.frame.size.height)];
		[spinner startAnimating];
		[self.view addSubview:spinner];
		[spinner release];
		
		
		// image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, size.width-10, size.height-10)]; // Fissare dimensioni
		// [image setImage:[UIImage imageNamed:thumbnail]];
		// [image setUserInteractionEnabled:YES];
		// [self.view addSubview:image];
		// [image release];
		
	} else {
		
		UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, size.width-10, size.height-10)]; // Fissare dimensioni
		// NSLog(@"%f, %f", self.view.frame.origin.x, self.view.frame.origin.y);
		[image setImage:[UIImage imageNamed:thumbnail]];
		//[image setImage:[UIImage imageNamed:thumbnail]];
		[image setUserInteractionEnabled:YES];
		[[self view] addSubview:image];
		[image release];
		
		/*NSFileManager *filemanager = [[NSFileManager alloc]init];
		NSError *error;
		
		if((![filemanager fileExistsAtPath: fullPathToFile]) && pdfIsOpen)*/
		UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aButton setFrame:CGRectMake(10*3 + 45 * 2, 490, 120, 30)];
		[aButton setTitle:@"Download" forState:UIControlStateNormal];
		[aButton setTag:numDocumento];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
		[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
		[[aButton titleLabel]setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)]];
		[[self view] addSubview:aButton];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			UILabel *pageLabel = [[UILabel alloc ] initWithFrame:CGRectMake(45, 450, 300, 30) ];
			pageLabel.textAlignment =  UITextAlignmentCenter;
			pageLabel.textColor = [UIColor whiteColor];
			pageLabel.backgroundColor = [UIColor clearColor];
			pageLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(25.0)];
			NSString *titlelabel = [NSString stringWithFormat:@"Titolo : %@",page];
			[pageLabel setText:titlelabel]; 
			[[self view] addSubview:pageLabel];
			[pageLabel release];
			
		}else {
			
			UILabel *pageLabel = [[UILabel alloc ] initWithFrame:CGRectMake(45, 450, 300, 30) ];
			pageLabel.textAlignment =  UITextAlignmentCenter;
			pageLabel.textColor = [UIColor whiteColor];
			pageLabel.backgroundColor = [UIColor clearColor];
			pageLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
			NSString *titlelabel = [NSString stringWithFormat:@"Titolo : %@",page];
			[pageLabel setText:titlelabel]; 
			[[self view]addSubview:pageLabel];
			[pageLabel release];
		}
	}
	[super viewDidLoad];
}

-(void)actionOpenPdf:(id)sender {
	
	//NSLog(@"Nome Filesssss %@",PdfToDownload);
	//mvc.nomePdfDaAprire = PdfToDownload;
	
	//[mvc setNomePdfDaAprire:PdfToDownload];
	[mvc actionOpenPlainDocumentFromNewMain:self];
}

-(void)actionDownloadPdf:(id)sender {
	
	senderButton = sender;
	
	UIButton *btnPdfToDownload = (UIButton *)sender;
	
	//NSString *PdfToDownload1 =[NSString stringWithFormat:@"%d", btnPdfToDownload.tag];
	
	//NSLog(@"sebder...%@",sender);
	PdfToDownload=[@"pdf" stringByAppendingString: @"1"];
	
	NSString * storyLink = [@"http://go.mobfarm.eu/pdf/" stringByAppendingString:PdfToDownload] ;
	
		
	[self downloadPDF:self withUrl:storyLink andName:PdfToDownload];
	
}


-(void)downloadPDF:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf{
	
	
	//_url = @"http://gapil.truelite.it/gapil.pdf";
	
	NSURL *url = [NSURL URLWithString:_url];
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	
	// Filename Path
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:[[delegate fileManager] firstAvailableFileNameForName:_url]];
	pdfPath = [pdfPath stringByAppendingString:@"/"];
	pdfPath = [pdfPath stringByAppendingString:nomefilepdf];
	pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	[request setUseKeychainPersistence:YES];
	[request setDownloadDestinationPath:pdfPath];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request setDownloadProgressDelegate:mvc.downloadProgressView];
	[request setShouldPresentAuthenticationDialog:YES];
	[request setDownloadDestinationPath:pdfPath];
	[request startAsynchronous];
}

-(void)requestStarted:(ASIHTTPRequest *)request{
	NSLog(@"requestStarted");
	mvc.showViewDownload;
	//[downloadInProgress setHidden:NO];
	//[progressView setHidden:NO];
	//[progressView setProgress:0.0];
	pdfInDownload = YES;
}

-(void)requestFinished:(ASIHTTPRequest *)request{
	/*UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"DOWNLOAD TERMINATO" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Ok" otherButtonTitles:nil,nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];*/
	mvc.hideViewDownload;
	NSLog(@"requestFinished");
	//[mvc redrawTableAfterForeground];
	//[progressView setHidden:YES];
	//[downloadInProgress setHidden:YES];
	pdfInDownload = NO;
	UIButton *btnPdfToDownload = (UIButton *)senderButton;
	[btnPdfToDownload setTitle:@"Apri" forState:UIControlStateNormal];
	[btnPdfToDownload removeTarget:self action:@selector(downloadPDF:) forControlEvents:UIControlEventTouchUpInside];
	[btnPdfToDownload addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
	NSLog(@"requestFailed");
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"ERRORE DOWNLOAD" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil,nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];
	NSLog(@"requestFinished");
	//[mvc redrawTableAfterForeground];
	//[downloadInProgress setHidden:YES];
	//[progressView setHidden:YES];
	pdfInDownload = NO;
}

- (void)updateCorner{
	// NSLog(@"Update Corner for page %i", page);
	//NSString *name = [NSString stringWithFormat:@"%iMarkS.png", [[self dataSource] getColorForPage:page]];
	//[corner setImage:[UIImage imageNamed:name]];
}

- (void)setSelected:(BOOL)selected{
	/*
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationDelegate:self];
	if (selected && border.alpha == 0.0) {
		border.alpha = 1.0;
	} else if (!selected && border.alpha == 1.0){
		border.alpha = 0.0;
	}
    [UIView commitAnimations];
	*/  
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[corner release];
	[self.view removeFromSuperview];
	// NSLog(@"Dealloc page %i", page);
	// [[[self.view subviews] objectAtIndex:0] removeFromSuperview];
	// [image release];
    [super dealloc];
}


@end
