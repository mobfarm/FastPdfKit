//
//  MFHomeListPdf.m
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import "BookItemView.h"
#import "MenuViewController_Kiosk.h"
#import "ZipArchive.h"

#define TITLE_DOWNLOAD @"Download"
#define TITLE_OPEN @"Open"
#define TITLE_REMOVE @"Remove"
#define TITLE_RESUME @"Resume"

@interface BookItemView()
@property (nonatomic, readwrite) CGSize size;
@property (nonatomic, readwrite) BOOL pdfInDownload;
@end

@implementation BookItemView

- (id)initWithName:(NSString *)page andTitoloPdf:(NSString *)titlePdf andLinkPdf:(NSString *)linkpdf andnumOfDoc:(int)numDoc andImage:(NSString *)image andSize:(CGSize)size{

	self.size = size;
	self.downloadUrl = linkpdf;
	self.thumbName = image;
	self.page = page;
    self.titleOfPdf = titlePdf;
	
    [self downloadImage:self withUrl:self.thumbName andName:page];
    
	self.documentNumber = numDoc;
	self.temp = NO;
    
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
	
	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];	
	pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.pdf",self.page,self.page]];
	
	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	cacheDirectory = [paths objectAtIndex:0];
	thumbPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.page]];
	
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
		
		anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, self.size.width-10, self.size.height-10)];
		[anImageView setImage:[UIImage imageNamed:@"Kiosk/backThumb" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
		[[self view] addSubview:anImageView];

		// Cover.
		
		anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 17, self.size.width-24, self.size.height-24)];
		[anImageView setImage:[UIImage imageWithContentsOfFile:thumbPath]];
		[anImageView setUserInteractionEnabled:YES];
		[anImageView setTag: self.documentNumber];
		[[self view] addSubview:anImageView];
		self.thumbImage = anImageView;
		
	} else {
		
		// Background.
		
		anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, self.size.width-10, self.size.height-10)];
		[anImageView setImage:[UIImage imageNamed:@"Kiosk/backThumb_phone" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
		[[self view] addSubview:anImageView];

		// Cover.
		
		anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 12, self.size.width-14, self.size.height-14)];
		[anImageView setImage:[UIImage imageWithContentsOfFile:thumbPath]];
		[anImageView setUserInteractionEnabled:YES];
		[anImageView setTag: self.documentNumber];
		[[self view] addSubview:anImageView];
		self.thumbImage = anImageView;
	}
	
	// Open button.
	
	aButton= [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setFrame:CGRectMake(20, 15, self.size.width-20, self.size.height-20)];
	[aButton setTag: self.documentNumber];
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

	aProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(21, progressBarVOffset, self.size.width-24, self.size.height-10)];
	aProgressView.progressViewStyle = UIProgressViewStyleDefault; // FIXME: it was UIActivityIndicatorViewStyleGray. 
	aProgressView.progress= 0.0;
	aProgressView.hidden = TRUE;
	[[self view] addSubview:aProgressView];
	self.progressDownload = aProgressView;
    
	// Open/download button.
	
	aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setFrame:CGRectMake(openButtonHOffset, openButtonVOffset, buttonWidth, buttonHeight)];
	[aButton setTag:self.documentNumber];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	[[aButton titleLabel]setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)]];
	
	if (!fileAlreadyExists) {
        
        if ([fileManager fileExistsAtPath:[pdfPathTempForResume stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", self.page]]]) {
			// Resume.
			
			[aButton setTitle:TITLE_RESUME forState:UIControlStateNormal];
			[aButton setImage:[UIImage imageNamed:@"Kiosk/resume" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            
		}else {
		
            // Download.
		
            [aButton setTitle:TITLE_DOWNLOAD forState:UIControlStateNormal];
            [aButton setImage:[UIImage imageNamed:@"Kiosk/download" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        }
        [aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		
		// Open.
		
		[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageNamed:@"Kiosk/view" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
		[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	[[self view] addSubview:aButton];
	self.openButton = aButton;
	
	
	// Remove button.
	
	aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setFrame:CGRectMake(removeButtonHOffset, removeButtonVOffset, buttonWidth, buttonHeight)];
	[aButton setTitle:TITLE_REMOVE forState:UIControlStateNormal];
	[aButton setImage:[UIImage imageNamed:@"Kiosk/remove" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
	[aButton setTag: self.documentNumber];
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
		aLabel.textAlignment =  NSTextAlignmentCenter;
		aLabel.textColor = [UIColor blackColor];
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(25.0)];
	
    }else {
		
		aLabel = [[UILabel alloc ] initWithFrame:CGRectMake(20, 170, 105, 20) ];
		aLabel.textAlignment =  NSTextAlignmentCenter;
		aLabel.textColor = [UIColor blackColor];
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
	}
	
	aLabelTitle = [NSString stringWithFormat:@"%@",self.titleOfPdf];
	[aLabel setText:aLabelTitle]; 
	[[self view] addSubview:aLabel];
}

-(void)actionremovePdf:(id)sender{
	
	// Basically, we get the UI elements and change their behaviour.
	
	UIButton * aButton = nil; /* Will reuse to reference different buttons */
	
	NSArray *paths = nil;
	NSString *documentsDirectory = nil;
	NSString *pdfPath = nil; 
	
	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];
	pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.page]];
	
	// Remove the file form disk (ignore the error).
	[[NSFileManager defaultManager] removeItemAtPath:pdfPath error:NULL];
	
	// Hide the remove button.
	aButton = [self.menuViewController.buttonRemoveDict objectForKey:self.page];
	aButton.hidden = YES;

	// Change the open/download button to download.
	
	aButton = [self.menuViewController.openButtons objectForKey:self.page];
	[aButton setTitle:TITLE_DOWNLOAD forState:UIControlStateNormal];
	[aButton setImage:[UIImage imageNamed:@"Kiosk/download" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
	[aButton setTag: self.documentNumber];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	[aButton removeTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Change the action on the cover from open to download.
	
	aButton = [self.menuViewController.imgDict objectForKey:self.page];
	[aButton removeTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
}
							   
-(void)visualizzaButtonRemove{
	//show btnRemove
	UIButton *btnRemoveSel = [self.menuViewController.buttonRemoveDict objectForKey:self.page];
	btnRemoveSel.hidden = NO;
}

-(void)actionOpenPdf:(id)sender {
	
    [self.menuViewController actionOpenPlainDocument:self.page];
}

-(void)actionStopPdf:(id)sender {
	
    UIButton * aButton = nil;
    // C'è Newsstand
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([app respondsToSelector:@selector(setNewsstandIconImage:)] && YES){
        
        NKLibrary *library = [NKLibrary sharedLibrary];
        if ([library issueWithName:self.page]) {
            [library removeIssue:[library issueWithName:self.page]];
        }
        self.pdfInDownload=NO;
        
    }else{
    
        
    }
    
    [self.httpRequest cancel];
    
    self.downloadPdfStopped = YES;
	
    
	aButton = [self.menuViewController.openButtons objectForKey:self.page];
	[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton setImage:[UIImage imageNamed:@"Kiosk/resume" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Cover button.
	
	aButton = [self.menuViewController.imgDict objectForKey:self.page];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)actionDownloadPdf:(id)sender {
	
    if(self.pdfInDownload) {
		return;
    }
	
	[self downloadPDF:self withUrl:self.downloadUrl andName:self.page];
}


-(void)downloadPDF:(id)sender withUrl:(NSString *)sourceURL andName:(NSString *)namePdf{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelDownload:) name:@"cancel_Download_taped" object:nil];        
    
    NSURL *url = [NSURL URLWithString:sourceURL];
    
    // C'è Newsstand
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",@"FastPdfKit_Kiosk-Info"]];
    
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    BOOL status1 = [[plistDict objectForKey:@"UINewsstandApp"]boolValue];
    
    BOOL status2 = [app respondsToSelector:@selector(setNewsstandIconImage:)];
    
    
    if (status2 && status1){
        
        NKLibrary *library = [NKLibrary sharedLibrary];
        if ([library issueWithName:namePdf]) {               
            [library removeIssue:[library issueWithName:namePdf]];
        }
        NKIssue *issue = [library addIssueWithName:namePdf date:[NSDate date]];
        NSURLRequest * request = nil;
        request = [[NSURLRequest alloc ]initWithURL:url];
        NKAssetDownload *asset = [issue addAssetWithRequest:request];
        [asset setUserInfo:[NSDictionary dictionaryWithObject:namePdf forKey:@"filename"]];
        [asset downloadWithDelegate:self];
        
        [self updateBtnDownload];
        
    } else {
        
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
        self.isPdfLink = [self checkIfPDfLink:sourceURL];
        
        // Filename path.
        paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        
        pathContainPdf = [NSString stringWithString:[NSString stringWithFormat:@"/%@/",namePdf]];
        pathContainPdf = [documentsDirectory stringByAppendingString:pathContainPdf];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:pathContainPdf withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (self.isPdfLink) {
            pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.pdf",namePdf,namePdf]];
        }else{
            pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.fpk",namePdf,namePdf]];
        }
        
        //This Directory Contains the temp file in download . it's used when resume is supported.
        pdfPathTempForResume = [documentsDirectory stringByAppendingPathComponent:@"temp"];
        
        if (self.isPdfLink) {
        
            pdfPathTempForResume = [pdfPathTempForResume stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",namePdf]];
        
        }else {
            
            pdfPathTempForResume = [pdfPathTempForResume stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.fpk",namePdf]];
        }
        
        url = [NSURL URLWithString:sourceURL];
        
        request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        
        [request setUseKeychainPersistence:YES];
        [request setDownloadDestinationPath:pdfPath];
        [request setDidFinishSelector:@selector(requestFinished:)];
        [request setDidFailSelector:@selector(requestFailed:)];
        
        // Get the progressview from the mainviewcontroller and set it as the progress delegate.
        
        progressView = [self.menuViewController.progressViewDict objectForKey:self.page];
        [request setDownloadProgressDelegate:progressView];
        
        [request setShouldPresentAuthenticationDialog:YES];
        [request setDownloadDestinationPath:pdfPath];
        [request setAllowResumeForFileDownloads:YES]; //set YEs if resume is supported 
        [request setTemporaryFileDownloadPath:pdfPathTempForResume]; // if resume is supported set the temporary Path
        
        self.httpRequest = request;
        
        [request startAsynchronous];
    }
}


#pragma mark -
#pragma mark Newsstand download progress


-(void)updateBtnDownload{

    UIButton *aButton = nil;
    UIProgressView *progressView = nil;
    
    self.pdfInDownload = YES;
    
    progressView = [self.menuViewController.progressViewDict objectForKey:self.page];
    progressView.hidden = NO;
    
    aButton =[self.menuViewController.openButtons objectForKey:self.page];
    [aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
    [aButton removeTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
    [aButton setImage:[UIImage imageNamed:@"Kiosk/pause" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
    
    // Cover button.
    
    aButton = [self.menuViewController.imgDict objectForKey:self.page];
    [aButton removeTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
}





- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes{
    
    self.progressDownload.hidden = NO;
    
    float progress = (float)totalBytesWritten/(float)expectedTotalBytes;
    
    [self.progressDownload setProgress:progress animated:YES];
    
    /*NSArray *tempArray = [NSArray arrayWithObjects:page, [NSNumber numberWithInt:[page intValue]], [NSNumber numberWithFloat:(float)totalBytesWritten/(float)expectedTotalBytes], nil];   
     */
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_Progress" object:tempArray];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_Error" object:nil];
    
    UIButton * aButton = nil;
    UIProgressView * aProgressView = nil;
    
	self.pdfInDownload = NO;
	
	aProgressView = [self.menuViewController.progressViewDict objectForKey:self.page];
	aProgressView.hidden = !self.downloadPdfStopped;
    
    aButton = [self.menuViewController.openButtons objectForKey:self.page];
    [aButton setTitle:TITLE_RESUME forState:UIControlStateNormal];
    [aButton setImage:[UIImage imageNamed:@"Kiosk/resume" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [aButton removeTarget:self action:@selector(actionStopPDF:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
    aButton = [self.menuViewController.imgDict objectForKey:self.page];
	[aButton removeTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
    
	if (self.downloadPdfStopped) {
		self.downloadPdfStopped=NO;
	}
    
    
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    
    
    self.progressDownload.hidden =YES;
    
	UIButton * aButton = nil; /* Will reuse this to reference different buttons */
	
	self.pdfInDownload = NO;
	
	// Update the UI elements from download status to pen status. We get the buttons from the main view controller
	// and update them to the new status.
	
	// Download/open button.
	
	aButton = [self.menuViewController.openButtons objectForKey:self.page];
	[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton setImage:[UIImage imageNamed:@"Kiosk/view" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
	[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Cover button.
	
	aButton = [self.menuViewController.imgDict objectForKey:self.page];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	[self performSelector:@selector(visualizzaButtonRemove) withObject:nil afterDelay:0.1];
    
    
    //write pdf
    
    
    NSArray *tempArray = [NSArray arrayWithObjects:self.page, [NSNumber numberWithInt:[self.page intValue]], nil];
    NKAssetDownload *asset = [connection newsstandAssetDownload];
    NSString *filename = [[asset userInfo] objectForKey:@"filename"];
    NSString *suffix = nil;
    NSString *path = nil;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    [path stringByAppendingPathComponent:filename];
    
    
    if([[destinationURL absoluteString] hasSuffix:@"fpk"]) {
        suffix = @"fpk";
        
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",filename,suffix]];
        [[NSFileManager defaultManager] copyItemAtPath:[destinationURL path] toPath:path error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[destinationURL path] error:nil];
        if ([self handleFPKFile]) [[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_OK" object:tempArray];
        else [[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_Error" object:nil];
        
    } else {    
        suffix = @"pdf";
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",filename,suffix]];
        
        NSError *error = nil;    
        [[NSFileManager defaultManager] copyItemAtPath:[destinationURL path] toPath:path error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:[destinationURL path] error:&error];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_OK" object:tempArray];
    }
    
}



- (BOOL)handleFPKFile {
    
    BOOL zipStatus = NO;
    
    ZipArchive * zipFile = nil;
    NSArray * dirContents = nil;
    
    NSString * oldPath = nil;
    NSString * newPath = nil;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *unzippedDestination = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/", self.page]];
    NSString *saveLocation = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.fpk",self.page,self.page]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:unzippedDestination withIntermediateDirectories:YES attributes:nil error:nil];        
    
    zipFile = [[ZipArchive alloc] init];
    [zipFile UnzipOpenFile:saveLocation];
    zipStatus = [zipFile UnzipFileTo:unzippedDestination overWrite:YES];    
    [zipFile UnzipCloseFile];
    
    dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzippedDestination error:nil];
    
    
    BOOL pdfStatus = NO;
    for (NSString *tString in dirContents) {
        
        if ([tString hasSuffix:@".pdf"]) {
            
            oldPath =[unzippedDestination stringByAppendingString:tString];
            newPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.pdf",self.page,self.page]];
            
            [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];				
            pdfStatus = YES;
        }
    }
    
    //[[NSFileManager defaultManager] removeItemAtPath:saveLocation error:nil];
    
    return zipStatus && pdfStatus;
}




-(void)downloadImage:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf{
	
	//Download Image for the thumb of the pdf
	
	NSURL *url = [NSURL URLWithString:_url];
	
	NSArray * paths = nil;
	NSString * documentsDirectory = nil;
	NSString * imgSavedPath = nil;
	NSString * pdfPath = nil;
    
	ASIHTTPRequest * aRequest = nil;
	
	// Filename path.
	
    NSFileManager * fileManager = [NSFileManager defaultManager];
	
	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];
	imgSavedPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.page]];
	
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
}

-(void)requestStarted:(ASIHTTPRequest *)request{
	
    UIButton *aButton = nil;
    UIProgressView *progressView = nil;
    
	self.pdfInDownload = YES;
	
	progressView = [self.menuViewController.progressViewDict objectForKey:self.page];
	progressView.hidden = NO;
    
    aButton =[self.menuViewController.openButtons objectForKey:self.page];
	[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
	[aButton removeTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton setImage:[UIImage imageNamed:@"Kiosk/pause" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
	[aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Cover button.
	
	aButton = [self.menuViewController.imgDict objectForKey:self.page];
	[aButton removeTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
	
    UIProgressView * aProgressView = nil;
	UIButton * aButton = nil; /* Will reuse this to reference different buttons */
	
	self.pdfInDownload = NO;
	
	// Update the UI elements from download status to pen status. We get the buttons from the main view controller
	// and update them to the new status.
	
	// Download/open button.
	
	aButton =[self.menuViewController.openButtons objectForKey:self.page];
	[aButton setTitle:TITLE_OPEN forState:UIControlStateNormal];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton setImage:[UIImage imageNamed:@"Kiosk/view" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
	[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	// Cover button.
	
	aButton = [self.menuViewController.imgDict objectForKey:self.page];
	[aButton removeTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionOpenPdf:) forControlEvents:UIControlEventTouchUpInside];
	
	[self performSelector:@selector(visualizzaButtonRemove) withObject:nil afterDelay:0.1]; /* This will show the remove button */
	
	// Hide the progress view.
	
	aProgressView = [self.menuViewController.progressViewDict objectForKey:self.page];
	aProgressView.hidden = YES;
    
    if (!self.isPdfLink) {
        
        ZipArchive * zipFile = nil;
        NSArray * dirContents = nil;
        
        NSString * oldPath = nil;
        NSString * newPath = nil;
        
        //set the directory for the Unzip and use ZipArchive library to unzip the file and the multimedia file
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *unzippedDestination = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/",self.page]];
		NSString *saveLocation = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.fpk",self.page,self.page]];
		
		zipFile = [[ZipArchive alloc] init];
		[zipFile UnzipOpenFile:saveLocation];
		[zipFile UnzipFileTo:unzippedDestination overWrite:YES];
		[zipFile UnzipCloseFile];
        
		// rename the file pdf ( only one must be exists in the fpk folder ) correctly 
        // With this rename of the pdf we are sure that the pdf name is correct.  
		
		dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzippedDestination error:nil];
        
		for (NSString *tString in dirContents) {
            
			if ([tString hasSuffix:@".pdf"]) {
				
                oldPath =[unzippedDestination stringByAppendingString:tString];
				newPath = [unzippedDestination stringByAppendingString:[NSString stringWithFormat:@"%@.pdf",self.page]];
                
				[[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];				
			}
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request{
	
    UIButton * aButton = nil;
    UIProgressView * aProgressView = nil;
    
	self.pdfInDownload = NO;
	
	aProgressView = [self.menuViewController.progressViewDict objectForKey:self.page];
	aProgressView.hidden = !self.downloadPdfStopped;
    
    aButton = [self.menuViewController.openButtons objectForKey:self.page];
    [aButton setTitle:TITLE_RESUME forState:UIControlStateNormal];
    [aButton setImage:[UIImage imageNamed:@"Kiosk/resume" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [aButton removeTarget:self action:@selector(actionStopPDF:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	
    aButton = [self.menuViewController.imgDict objectForKey:self.page];
	[aButton removeTarget:self action:@selector(actionDownloadPdf:) forControlEvents:UIControlEventTouchUpInside];
	[aButton addTarget:self action:@selector(actionStopPdf:) forControlEvents:UIControlEventTouchUpInside];
    
	if (self.downloadPdfStopped) {
		self.downloadPdfStopped=NO;
	}
}

-(BOOL)checkIfPDfLink:(NSString *)url{
	
	//url example in xml
	//link pdf:  <link>http://go.mobfarm.eu/pdf/Aperture.pdf</link>
    //link fpk:  <link>http://go.mobfarm.eu/pdf/Aperture.fpk</link>
	
	NSArray *listItems = [url componentsSeparatedByString:@"."];
	NSString *doctype = [listItems objectAtIndex:listItems.count-1];
	
	if ([doctype isEqualToString:@"pdf"]) {
		// NSLog(@"Is Pdf");
		return YES;
	}else{
		// NSLog(@"Is fpk");
		return NO;
	}
}

- (void)updateCorner{
	//Not used
}

- (void)setSelected:(BOOL)selected{
 
}

@end
