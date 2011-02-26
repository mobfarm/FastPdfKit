//
//  MFHomeListPdf.m
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import "MFHomeListPdf.h"
#import "MenuViewController_Kiosk.h"


@implementation MFHomeListPdf
@synthesize object, temp, dataSource,senderButton ,corner,pdfToDownload,numDocumento;
@synthesize mvc;
@synthesize page;
@synthesize removeButton,openButton,openButtonFromImage;
@synthesize progressDownload;
@synthesize yProgressBar,xBtnRemove,yBtnRemove,xBtnOpen,yBtnOpen,widthButton,heightButton;
@synthesize imgThumb;
@synthesize linkDownloadPdf;


// Load the view and initialize the pageNumber ivar.

- (id)initWithName:(NSString *)Page andLinkPdf:(NSString *)linkpdf andnumOfDoc:(int)numDoc andImage:(NSString *)_image andSize:(CGSize)_size{

	size = _size;
	linkDownloadPdf = linkpdf;
	thumbnail = _image;
	self.page=Page;
	[self downloadImage:self withUrl:thumbnail andName:Page];
	numDocumento = numDoc;
	temp = NO;
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view
- (void)viewDidLoad {
		//set the width , height and position of the object present in the vew
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			//ipad
			yProgressBar=485; //set y position of the progress bar
			xBtnRemove=120; // set x position of btn remove 
			yBtnRemove=590; //set y position of btn remove 
			xBtnOpen=120; //set x position of btn remove
			yBtnOpen=530; // set y position of btn Open/Downlaod
			widthButton=140; // width of the button 
			heightButton=44; // height of the button
		}else {
			//iphone
			yProgressBar=215;
			xBtnRemove=40;
			yBtnRemove=215;
			xBtnOpen=40;
			yBtnOpen=190;
			widthButton=70;
			heightButton=22;
		}

	
		//set background
		[self.view setBackgroundColor:[UIColor clearColor]];
		
		//check pdf already downloaded;
		BOOL fileAlreadyExists= NO;
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		
		
		NSString *pdfPath = [documentsDirectory stringByAppendingString:@"/"];
		pdfPath = [pdfPath stringByAppendingString:page];
		pdfPath = [pdfPath stringByAppendingString:@".pdf"];
		
		NSFileManager *filemanager = [[NSFileManager alloc]init];
		
		if ([filemanager fileExistsAtPath:pdfPath]) {
			fileAlreadyExists = YES;
		}else {
			fileAlreadyExists = NO;
		}

		//The scrollview have a background and the thumb of pdf added
		UIImageView *backthumb = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, size.width-10, size.height-10)]; // Fissare dimensioni
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[backthumb setImage:[UIImage imageNamed:@"backThumb.png"]];
			//set the backthumv view size.width-24 because it must be inside the backthumb.
			imgThumb = [[UIImageView alloc] initWithFrame:CGRectMake(22, 17, size.width-24, size.height-24)]; // Fissare dimensioni
		}
		else {
			[backthumb setImage:[UIImage imageNamed:@"backThumb_iphone.png"]];
			imgThumb = [[UIImageView alloc] initWithFrame:CGRectMake(17, 12, size.width-14, size.height-14)]; // Fissare dimensioni
		}
		[[self view] addSubview:backthumb];
		[backthumb release];
	
		NSArray *pathsok = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *cacheDirectory = [pathsok objectAtIndex:0];
		
		//get the correct path of the pdf - chache directory
		NSString *pdfPathThumb = [cacheDirectory stringByAppendingString:@"/"];
		pdfPathThumb = [pdfPathThumb stringByAppendingString:page];
		pdfPathThumb = [pdfPathThumb stringByAppendingString:@".png"];
		
		//set Image
		[imgThumb setImage:[UIImage imageWithContentsOfFile:pdfPathThumb]];
		[imgThumb setUserInteractionEnabled:YES];
		[imgThumb setTag:numDocumento];
		[[self view] addSubview:imgThumb];
		[imgThumb release];
	
		// init the acton on click on the thumb
		openButtonFromImage= [UIButton buttonWithType:UIButtonTypeCustom];
		[openButtonFromImage setFrame:CGRectMake(20, 15, size.width-20, size.height-20)];
		[openButtonFromImage setTag:numDocumento];
		[openButtonFromImage setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
		if (!fileAlreadyExists) {
				//if pdf already exist we must open the pdf at the click ok thumb
				[openButtonFromImage addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
			}else {
				//if pdf already exist we must download the pdf at the click on thumb
				[openButtonFromImage addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
			}
	
		[[self view] addSubview:openButtonFromImage];
	
		
		//set the progressdownload
		progressDownload = [[UIProgressView alloc] initWithFrame:CGRectMake(21, yProgressBar, size.width-24, size.height-10)];
		progressDownload.progressViewStyle = UIActivityIndicatorViewStyleGray;
		progressDownload.progress= 0.0;
		progressDownload.hidden = TRUE;
		[[self view] addSubview:progressDownload];
		

		//init open button
		openButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[openButton setFrame:CGRectMake(xBtnOpen, yBtnOpen, widthButton, heightButton)];
		[openButton setTag:numDocumento];
		[openButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
		[[openButton titleLabel]setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)]];
		if (!fileAlreadyExists) {
			//if pdf not already exist we must download the pdf at the click on button and we set the correct image and action
			[openButton setTitle:@"Download" forState:UIControlStateNormal];
			[openButton setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
			[openButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
		}else {
			//if pdf already exist we must open the pdf at the click on button and we set the correct image and action
			[openButton setTitle:@"Apri" forState:UIControlStateNormal];
			[openButton setImage:[UIImage imageNamed:@"view.png"] forState:UIControlStateNormal];
			[openButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
		}
		[[self view] addSubview:openButton];
		
		//init remove button
		removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[removeButton setFrame:CGRectMake(xBtnRemove, yBtnRemove, widthButton, heightButton)];
		[removeButton setTitle:@"Remove" forState:UIControlStateNormal];
		[removeButton setImage:[UIImage imageNamed:@"remove.png"] forState:UIControlStateNormal];
		[removeButton setTag:numDocumento];
		[removeButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
		[removeButton addTarget:self action:@selector(actionremovePdf:) forControlEvents:UIControlEventTouchUpInside];
		[[removeButton titleLabel]setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)]];
		//if pdf already exist show the button
		[removeButton setHidden:(!fileAlreadyExists)];
		[[self view] addSubview:removeButton];
		
		//set the property of label initialized with title of Pdf - the title is set on xml parsed
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			UILabel *pageLabel = [[UILabel alloc ] initWithFrame:CGRectMake(45, 495, 300, 30) ];
			pageLabel.textAlignment =  UITextAlignmentCenter;
			pageLabel.textColor = [UIColor blackColor];
			pageLabel.backgroundColor = [UIColor clearColor];
			pageLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(25.0)];
			NSString *titlelabel = [NSString stringWithFormat:@"%@",page];
			[pageLabel setText:titlelabel]; 
			[[self view] addSubview:pageLabel];
			[pageLabel release];
			
		}else {
			
			UILabel *pageLabel = [[UILabel alloc ] initWithFrame:CGRectMake(20, 170, 105, 20) ];
			pageLabel.textAlignment =  UITextAlignmentCenter;
			pageLabel.textColor = [UIColor blackColor];
			pageLabel.backgroundColor = [UIColor clearColor];
			pageLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
			NSString *titlelabel = [NSString stringWithFormat:@"%@",page];
			[pageLabel setText:titlelabel]; 
			[[self view]addSubview:pageLabel];
			[pageLabel release];
		}
	[super viewDidLoad];
}

-(void)actionremovePdf:(id)sender{
	
	//remove the pdf
	//get the correct path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	NSString *pdfPath = [documentsDirectory stringByAppendingString:@"/"];
	pdfPath = [pdfPath stringByAppendingString:page];
	pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	
	NSFileManager *filemanager = [[NSFileManager alloc]init];
	
	//remove form disk
	[filemanager removeItemAtPath:pdfPath error:NULL];
	
	//get the correct btn remove form the dictionary and remove it
	UIButton *btnRemoveSel = [mvc.buttonRemoveDict objectForKey:page];
	btnRemoveSel.hidden = YES;

	//Chaneg img form opne to download
	UIButton *btnDownloadSel = [mvc.buttonOpenDict objectForKey:page];
	[btnDownloadSel setTitle:@"Download" forState:UIControlStateNormal];
	[btnDownloadSel setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
	[btnDownloadSel setTag:numDocumento];
	[btnDownloadSel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	//remove action open from button
	[btnDownloadSel removeTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	//add action download from button
	[btnDownloadSel addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *btnImage = [mvc.imgDict objectForKey:page];
	//remove action open from the button up the thumb
	[btnImage removeTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	//add action dwnload from the button up the thumb
	[btnImage addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
}
							   
-(void)visualizzaButtonRemove{
	//show btnRemove
	UIButton *btnRemoveSel = [mvc.buttonRemoveDict objectForKey:page];
	btnRemoveSel.hidden = NO;
}

-(void)actionOpenPdf:(id)sender {
	//Open Pdf
	senderButton = sender;
	self.pdfToDownload=[NSString stringWithFormat:@"%@", page];
	[mvc setNomePdfDaAprire:pdfToDownload];
	[mvc actionOpenPlainDocumentFromNewMain:self];
}

-(void)actionDownloadPdf:(id)sender {
	//Downlad Pdf
	senderButton = sender;
	self.pdfToDownload=[NSString stringWithFormat:@"%@", page];
	[self downloadPDF:self withUrl:linkDownloadPdf andName:pdfToDownload];
}


-(void)downloadPDF:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf{
	//download Pdf
	NSURL *url = [NSURL URLWithString:_url];
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	
	// Filename Path
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	NSString *pdfPath = [documentsDirectory stringByAppendingString:@"/"];
	pdfPath = [pdfPath stringByAppendingString:nomefilepdf];
	pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	[request setUseKeychainPersistence:YES];
	[request setDownloadDestinationPath:pdfPath];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	//start download asynchronous and set the correct progressbar
	UIProgressView *progressViewDownload = [mvc.progressViewDict objectForKey:page];
	[request setDownloadProgressDelegate:progressViewDownload];
	[request setShouldPresentAuthenticationDialog:YES];
	[request setDownloadDestinationPath:pdfPath];
	[request startAsynchronous];
}

-(void)downloadImage:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf{
	//Download Image for the thumb of the pdf
	NSURL *url = [NSURL URLWithString:_url];
	//NSLog(@"url %@",url);
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	
	// Filename Path
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSFileManager *fileManager = [[NSFileManager alloc]init];
	
	NSString *imgSavedPath = [documentsDirectory stringByAppendingString:@"/"];
	imgSavedPath = [imgSavedPath stringByAppendingString:page];
	imgSavedPath = [imgSavedPath stringByAppendingString:@".png"];
	NSLog(@"path img : %@",imgSavedPath);
	
	if(![fileManager fileExistsAtPath: imgSavedPath]){
		NSString *pdfPath = [documentsDirectory stringByAppendingString:@"/"];
		pdfPath = [pdfPath stringByAppendingString:nomefilepdf];
		pdfPath = [pdfPath stringByAppendingString:@".png"];
		//NSLog(@"pdfPath %@",pdfPath);
		[request setDidStartSelector:@selector(requestStartedDownloadImg:)];
		[request setDidFinishSelector:@selector(requestFinishedDownloadImg:)];
		[request setDidFailSelector:@selector(requestFailedDownloadImg:)];
		[request setUseKeychainPersistence:YES];
		[request setDownloadDestinationPath:pdfPath];
		[request startSynchronous];
	}

}

-(void)requestStarted:(ASIHTTPRequest *)request{
	UIProgressView *progressViewDownload = [mvc.progressViewDict objectForKey:page];
	progressViewDownload.hidden = NO;
	NSLog(@"requestStarted");
	//mvc.showViewDownload;
	pdfInDownload = YES;
}

-(void)requestFinishedDownloadImg:(ASIHTTPRequest *)request{
}

-(void)requestFailedDownloadImg:(ASIHTTPRequest *)request{
}

-(void)requestStartedDownloadImg:(ASIHTTPRequest *)request{
}

-(void)requestFinished:(ASIHTTPRequest *)request{
	NSLog(@"requestFinished");
	pdfInDownload = NO;
	UIButton *btnPdfToDownload =[mvc.buttonOpenDict objectForKey:page];
	[btnPdfToDownload setTitle:@"Apri" forState:UIControlStateNormal];
	[btnPdfToDownload removeTarget:self action:@selector(downloadPDF:) forControlEvents:UIControlEventTouchUpInside];
	[btnPdfToDownload setImage:[UIImage imageNamed:@"view.png"] forState:UIControlStateNormal];
	[btnPdfToDownload addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *btnImage = [mvc.imgDict objectForKey:page];
	[btnImage removeTarget:self action:@selector(downloadPDF:) forControlEvents:UIControlEventTouchUpInside];
	[btnImage addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	[self performSelector:@selector(visualizzaButtonRemove) withObject:nil afterDelay:0.1];
	UIProgressView *progressViewDownload = [mvc.progressViewDict objectForKey:page];
	progressViewDownload.hidden = YES;
}

-(void)requestFailed:(ASIHTTPRequest *)request{
	NSLog(@"requestFailed");
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"ERRORE DOWNLOAD" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil,nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];
	NSLog(@"requestFinished");
	pdfInDownload = NO;
	UIProgressView *progressViewDownload = [mvc.progressViewDict objectForKey:page];
	progressViewDownload.hidden = YES;
}

- (void)updateCorner{
	//Not used
}

- (void)setSelected:(BOOL)selected{
 
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
