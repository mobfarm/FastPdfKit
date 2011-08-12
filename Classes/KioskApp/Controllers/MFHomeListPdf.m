//
//  MFHomeListPdf.m
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import "MFHomeListPdf.h"
#import "MenuViewController_Kiosk.h"
#import "ZipArchive.h"

#define TITLE_DOWNLOAD @"Download"
#define TITLE_OPEN @"Open"
#define TITLE_REMOVE @"Remove"
#define TITLE_RESUME @"Resume"

@implementation MFHomeListPdf
@synthesize object, temp, dataSource ,corner,documentNumber;
@synthesize menuViewController;
@synthesize page,titleOfPdf;
@synthesize removeButton,openButton,openButtonFromImage;
@synthesize progressDownload;
// @synthesize yProgressBar,xBtnRemove,yBtnRemove,xBtnOpen,yBtnOpen,widthButton,heightButton;
@synthesize thumbImage;
@synthesize downloadUrl;
@synthesize httpRequest;
@synthesize thumbName;
@synthesize isPdfLink;
@synthesize downloadPdfStopped;
// Load the view and initialize the pageNumber ivar.

- (id)initWithName:(NSString *)Page andTitoloPdf:(NSString *)titlePdf andLinkPdf:(NSString *)linkpdf andnumOfDoc:(int)numDoc andImage:(NSString *)_image andSize:(CGSize)_size{

	size = _size;
	self.downloadUrl = linkpdf;
	self.thumbName = _image;
	self.page=Page;
    self.titleOfPdf = titlePdf;
	
    [self downloadImage:self withUrl:thumbName andName:Page];
    
	documentNumber = numDoc;
	temp = NO;
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view
- (void)viewDidLoad {
	
	UIButton * aButton = nil;
	
	UILabel * aLabel = nil;
	NSString * aLabelTitle = nil;
	
	UIImageView * anImageView = nil;
	
	UIProgressView * aProgressView = nil;
	
	NSArray * paths = nil;
	NSString * documentsDirectory = nil;
	NSString * cacheDirectory = nil;
	NSString * thumbPath = nil;
	NSString * pdfPath = nil;
	
	NSFileManager * fileManager = nil;
	
    NSString * pdfPathTempForResume = nil;
    
	BOOL fileAlreadyExists = NO;
	
	// Calculate sizes and offsets.
	
	CGFloat progressBarVOffset;
	CGFloat removeButtonHOffset;
	CGFloat removeButtonVOffset;
	CGFloat openButtonHOffset;
	CGFloat openButtonVOffset;
	CGFloat buttonWidth;
	CGFloat buttonHeight;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // iPad.
		
		progressBarVOffset=485; //set y position of the progress bar
		removeButtonHOffset=120; // set x position of btn remove 
		removeButtonVOffset=590; //set y position of btn remove 
		openButtonHOffset=120; //set x position of btn remove
		openButtonVOffset=530; // set y position of btn Open/Downlaod
		buttonWidth=140; // width of the button 
		buttonHeight=44; // height of the button
		
	} else {		// iPhone.
		
		//iphone
		progressBarVOffset=215;
		removeButtonHOffset=40;
		removeButtonVOffset=215;
		openButtonHOffset=40;
		openButtonVOffset=190;
		buttonWidth=70;
		buttonHeight=22;
	}
    
    
	[super viewDidLoad];
	
	[self.view setBackgroundColor:[UIColor clearColor]];
	
	// Paths to the cover and the document.
	
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];	
	pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.pdf",page,page]];
	
	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	cacheDirectory = [paths objectAtIndex:0];
	thumbPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",page]];
	
	fileManager = [[NSFileManager alloc]init];
    
    //create the temp directory used for the resume of pdf.
    
    pdfPathTempForResume = [documentsDirectory stringByAppendingPathComponent:@"temp"];
	
	[fileManager createDirectoryAtPath:pdfPathTempForResume withIntermediateDirectories:YES attributes:nil error:nil];
	
	if ([fileManager fileExistsAtPath:pdfPath]) {
		fileAlreadyExists = YES;
	}else {
		fileAlreadyExists = NO;
	}
	
	// Cover image. We add a background and the overlaying cover image directly onto the controller's view.
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		// Background.
		
		anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, size.width-10, size.height-10)];
		[anImageView setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"backThumb",@"png")]];
		[[self view] addSubview:anImageView];
		[anImageView release];

		// Cover.
		
		anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 17, size.width-24, size.height-24)];
		[anImageView setImage:[UIImage imageWithContentsOfFile:thumbPath]];
		[anImageView setUserInteractionEnabled:YES];
		[anImageView setTag:documentNumber];
		[[self view] addSubview:anImageView];
		self.thumbImage = anImageView;
		[anImageView release];
		
	} else {
		
		// Background.
		
		anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, size.width-10, size.height-10)];
		[anImageView setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"backThumb_iphone",@"png")]];
		[[self view] addSubview:anImageView];
		[anImageView release];

		// Cover.
		
		anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 12, size.width-14, size.height-14)];
		[anImageView setImage:[UIImage imageWithContentsOfFile:thumbPath]];
		[anImageView setUserInteractionEnabled:YES];
		[anImageView setTag:documentNumber];
		[[self view] addSubview:anImageView];
		self.thumbImage = anImageView;
		[anImageView release];
	}
	
	// Open button.
	
	aButton= [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setFrame:CGRectMake(20, 15, size.width-20, size.height-20)];
	[aButton setTag:documentNumber];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	
	// Open or download action, depend if the file is already present or not.
	
	if (!fileAlreadyExists) {
		[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	[[self view] addSubview:aButton];
	self.openButtonFromImage = aButton;
	
	
	// Progress bar for the download operation.

	aProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(21, progressBarVOffset, size.width-24, size.height-10)];
	aProgressView.progressViewStyle = UIActivityIndicatorViewStyleGray;
	aProgressView.progress= 0.0;
	aProgressView.hidden = TRUE;
	[[self view] addSubview:aProgressView];
	self.progressDownload = aProgressView;
	[aProgressView release];
	
	
	// Open/download button.
	
	aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setFrame:CGRectMake(openButtonHOffset, openButtonVOffset, buttonWidth, buttonHeight)];
	[aButton setTag:documentNumber];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	[[aButton titleLabel]setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)]];
	
	if (!fileAlreadyExists) {
        
        if ([fileManager fileExistsAtPath:[pdfPathTempForResume stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",page]]]) {
			// Resume.
			
			[aButton setTitle:TITLE_RESUME forState:UIControlStateNormal];
			[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"resume",@"png")] forState:UIControlStateNormal];
            
		}else {
		
            // Download.
		
            [aButton setTitle:TITLE_DOWNLOAD forState:UIControlStateNormal];
            [aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"download",@"png")] forState:UIControlStateNormal];
        }
        [aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		
		// Open.
		
		[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"view",@"png")] forState:UIControlStateNormal];
		[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	[[self view] addSubview:aButton];
	self.openButton = aButton;
	
	
	// Remove button.
	
	aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setFrame:CGRectMake(removeButtonHOffset, removeButtonVOffset, buttonWidth, buttonHeight)];
	[aButton setTitle:TITLE_REMOVE forState:UIControlStateNormal];
	[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"remove",@"png")] forState:UIControlStateNormal];
	[aButton setTag:documentNumber];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	[aButton addTarget:self action:@selector(actionremovePdf:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)]];
	
	// If pdf already exist show the button.
	
	[aButton setHidden:(!fileAlreadyExists)];
	[[self view] addSubview:aButton];
	self.removeButton = aButton;
	
	
	// Title label.
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		aLabel = [[UILabel alloc ] initWithFrame:CGRectMake(45, 495, 300, 30) ];
		aLabel.textAlignment =  UITextAlignmentCenter;
		aLabel.textColor = [UIColor blackColor];
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(25.0)];
	
    }else {
		
		aLabel = [[UILabel alloc ] initWithFrame:CGRectMake(20, 170, 105, 20) ];
		aLabel.textAlignment =  UITextAlignmentCenter;
		aLabel.textColor = [UIColor blackColor];
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
	}
	
	aLabelTitle = [NSString stringWithFormat:@"%@",self.titleOfPdf];
	[aLabel setText:aLabelTitle]; 
	[[self view] addSubview:aLabel];
	[aLabel release];
    [fileManager release];
	
}

-(void)actionremovePdf:(id)sender{
	
	// Basically, we get the UI elements and change their behaviour.
	
	UIButton * aButton = nil; /* Will reuse to reference different buttons */
	
	NSFileManager *filemanager = nil;
	
	NSArray *paths = nil; 
	NSString *documentsDirectory = nil;
	NSString *pdfPath = nil; 
	
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];
	pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",page]];
	
	// Remove the file form disk (ignore the error).
	
	filemanager = [[NSFileManager alloc]init];
	[filemanager removeItemAtPath:pdfPath error:NULL];
	[filemanager release];
	
	// Hide the remove button.
	aButton = [menuViewController.buttonRemoveDict objectForKey:page];
	aButton.hidden = YES;

	// Change the open/download button to download.
	
	aButton = [menuViewController.openButtons objectForKey:page];
	[aButton setTitle:TITLE_DOWNLOAD forState:UIControlStateNormal];
	[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"download",@"png")] forState:UIControlStateNormal];
	[aButton setTag:documentNumber];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	[aButton removeTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Change the action on the cover from open to download.
	
	aButton = [menuViewController.imgDict objectForKey:page];
	[aButton removeTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
}
							   
-(void)visualizzaButtonRemove{
	//show btnRemove
	UIButton *btnRemoveSel = [menuViewController.buttonRemoveDict objectForKey:page];
	btnRemoveSel.hidden = NO;
}

-(void)actionOpenPdf:(id)sender {
	//Open Pdf
	//senderButton = sender;
	//NSString * [NSString stringWithFormat:@"%@", page];
	//[mvc setDocumentName:pdfToDownload];
	[menuViewController actionOpenPlainDocument:page];
}

-(void)actionStopPdf:(id)sender {
	
    UIButton * aButton = nil; 
    
    downloadPdfStopped = YES;
	[self.httpRequest cancel];
    
	aButton = [menuViewController.openButtons objectForKey:page];
	[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"resume",@"png")] forState:UIControlStateNormal];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Cover button.
	
	aButton = [menuViewController.imgDict objectForKey:page];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)actionDownloadPdf:(id)sender {
	
	if(pdfInDownload)
		return;
	
	//senderButton = sender;
	//self.pdfToDownload=[NSString stringWithFormat:@"%@", page];
	[self downloadPDF:self withUrl:downloadUrl andName:page];
}


-(void)downloadPDF:(id)sender withUrl:(NSString *)sourceURL andName:(NSString *)destinationFilePath{
	
	NSURL *url = nil;
	ASIHTTPRequest * request = nil;
	
	NSArray * paths = nil;
	NSString * documentsDirectory = nil;
	NSString * pdfPath = nil;
	
	UIProgressView * progressView = nil;
    NSString *pathContainPdf = nil;
    NSFileManager *filemanager = nil;
    NSError *error = nil;
    NSString *pdfPathTempForResume = nil;
    
    //check if the download url is a link to a pdf file or pfk file.
    isPdfLink = [self checkIfPDfLink:sourceURL];
	
	// Filename path.
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];

    pathContainPdf = [NSString stringWithString:[NSString stringWithFormat:@"/%@/",destinationFilePath]];
	pathContainPdf = [documentsDirectory stringByAppendingString:pathContainPdf];
	
	filemanager = [[NSFileManager alloc]init];
	[filemanager createDirectoryAtPath:pathContainPdf withIntermediateDirectories:YES attributes:nil error:&error];
    [filemanager release];

    if (isPdfLink) {
        pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.pdf",destinationFilePath,destinationFilePath]];
    }else{
        pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.fpk",destinationFilePath,destinationFilePath]];
    }

    //This Directory Contains the temp file in download . it's used when resume is supported.
    pdfPathTempForResume = [documentsDirectory stringByAppendingPathComponent:@"temp"];
	
	if (isPdfLink) {
		pdfPathTempForResume = [pdfPathTempForResume stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",destinationFilePath]];
	}else {
		pdfPathTempForResume = [pdfPathTempForResume stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.fpk",destinationFilePath]];
		
	}
	
	url = [NSURL URLWithString:sourceURL];
    //url = [NSURL URLWithString:@"http://hbsflip.chalco.net/aspx/doc.pdf?path=8Ka9CXdfH8fai6qI2wRdz-8JoPDJfvqz0"];
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	
	[request setUseKeychainPersistence:YES];
	[request setDownloadDestinationPath:pdfPath];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	
	// Get the progressview from the mainviewcontroller and set it as the progress delegate.
	
	progressView = [menuViewController.progressViewDict objectForKey:page];
	[request setDownloadProgressDelegate:progressView];
	
	[request setShouldPresentAuthenticationDialog:YES];
	[request setDownloadDestinationPath:pdfPath];
    [request setAllowResumeForFileDownloads:YES]; //set YEs if resume is supported 
	[request setTemporaryFileDownloadPath:pdfPathTempForResume]; // if resume is supported set the temporary Path
	
	self.httpRequest = request;
	
	[request startAsynchronous];
}

-(void)downloadImage:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf{
	
	//Download Image for the thumb of the pdf
	
	NSURL *url = [NSURL URLWithString:_url];
	
	NSArray * paths = nil;
	NSString * documentsDirectory = nil;
	NSString * imgSavedPath = nil;
	NSString * pdfPath = nil;
	
	NSFileManager * fileManager = nil;
	
	ASIHTTPRequest * aRequest = nil;
	
	// Filename path.
	
	fileManager = [[NSFileManager alloc]init];
	
	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];
	imgSavedPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",page]];
	
	if(![fileManager fileExistsAtPath: imgSavedPath]) {
	
		pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",nomefilepdf]];
		
		aRequest = [ASIHTTPRequest requestWithURL:url];
		
		[aRequest setDelegate:self];
		[aRequest setDidStartSelector:@selector(requestStartedDownloadImg:)];
		[aRequest setDidFinishSelector:@selector(requestFinishedDownloadImg:)];
		[aRequest setDidFailSelector:@selector(requestFailedDownloadImg:)];
		[aRequest setUseKeychainPersistence:YES];
		[aRequest setDownloadDestinationPath:pdfPath];
		
		self.httpRequest = aRequest;
		
		[aRequest startSynchronous];
		
	}
	
	[fileManager release];
}

-(void)requestStarted:(ASIHTTPRequest *)request{
	
    UIButton *aButton = nil;
    UIProgressView *progressView = nil;
    
	pdfInDownload = YES;
	
	progressView = [menuViewController.progressViewDict objectForKey:page];
	progressView.hidden = NO;
    
    aButton =[menuViewController.openButtons objectForKey:page];
	[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
	[aButton removeTarget:self action:@selector(actionDownloadPDF:) forControlEvents:UIControlEventTouchUpInside];
	[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"pause",@"png")] forState:UIControlStateNormal];
	[aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Cover button.
	
	aButton = [menuViewController.imgDict objectForKey:page];
	[aButton removeTarget:self action:@selector(actionDownloadPDF:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
    
    //[aButton release];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
	
    UIProgressView * aProgressView = nil;
	UIButton * aButton = nil; /* Will reuse this to reference different buttons */
	
	pdfInDownload = NO;
	
	// Update the UI elements from download status to pen status. We get the buttons from the main view controller
	// and update them to the new status.
	
	// Download/open button.
	
	aButton =[menuViewController.openButtons objectForKey:page];
	[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"view",@"png")] forState:UIControlStateNormal];
	[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Cover button.
	
	aButton = [menuViewController.imgDict objectForKey:page];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	[self performSelector:@selector(visualizzaButtonRemove) withObject:nil afterDelay:0.1]; /* This will show the remove button */
	
	// Hide the progress view.
	
	aProgressView = [menuViewController.progressViewDict objectForKey:page];
	aProgressView.hidden = YES;
    
    if (!isPdfLink) {
        
        ZipArchive * zipFile = nil;
        NSArray * dirContents = nil;
        
        NSString * oldPath = nil;
        NSString * newPath = nil;
        
        //set the directory for the Unzip and use ZipArchive library to unzip the file and the multimedia file
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *unzippedDestination = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/",page]];
		NSString *saveLocation = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.fpk",page,page]];
		
		zipFile = [[ZipArchive alloc] init];
		[zipFile UnzipOpenFile:saveLocation];
		[zipFile UnzipFileTo:unzippedDestination overWrite:YES];
		[zipFile UnzipCloseFile];
		[zipFile release];
		
		// rename the file pdf ( only one must be exists in the fpk folder ) correctly 
        // With this rename of the pdf we are sure that the pdf name is correct.  
		
		dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzippedDestination error:nil];
        
		for (NSString *tString in dirContents) {
            
			if ([tString hasSuffix:@".pdf"]) {
				
                oldPath =[unzippedDestination stringByAppendingString:tString];
				newPath = [unzippedDestination stringByAppendingString:[NSString stringWithFormat:@"%@.pdf",page]];
                
				[[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];				
			}
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request{
	
    UIButton * aButton = nil;
    UIProgressView * aProgressView = nil;
    
	pdfInDownload = NO;
	
	aProgressView = [menuViewController.progressViewDict objectForKey:page];
	aProgressView.hidden = !downloadPdfStopped;
    
    aButton = [menuViewController.openButtons objectForKey:page];
    [aButton setTitle:TITLE_RESUME forState:UIControlStateNormal];
    [aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"resume",@"png")] forState:UIControlStateNormal];
    [aButton removeTarget:self action:@selector(actionStopPDF:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPDF:) forControlEvents:UIControlEventTouchUpInside];
	
    aButton = [menuViewController.imgDict objectForKey:page];
	[aButton removeTarget:self action:@selector(actionDownloadPDF:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
    
	if (downloadPdfStopped) {
		downloadPdfStopped=NO;
	}
}

-(BOOL)checkIfPDfLink:(NSString *)url{
	
	//url example in xml
	//link pdf:  <link>http://go.mobfarm.eu/pdf/Aperture.pdf</link>
    //link fpk:  <link>http://go.mobfarm.eu/pdf/Aperture.fpk</link>
	
	NSArray *listItems = [url componentsSeparatedByString:@"."];
	NSString *doctype = [listItems objectAtIndex:listItems.count-1];
	
	if ([doctype isEqualToString:@"pdf"]) {
		NSLog(@"Is Pdf");
		return YES;
	}else{
		NSLog(@"Is fpk");
		return NO;
	}
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
	[httpRequest release];
	[thumbName release];
	[page release];
	[downloadUrl release];
	
	[thumbName release];
	[removeButton release];
	[openButton release];
	[thumbImage release];
	[openButtonFromImage release];
	[progressDownload release];
	
	[super dealloc];
}


@end
