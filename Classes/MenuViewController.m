    //
//  MenuViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/26/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MenuViewController.h"
#import "MFDocumentManager.h"
#import "DocumentViewController.h"
#import "MFHomeListPdf.h"
#import "XMLParser.h"
#include <stdio.h>
#include <stdlib.h>

#define TEXT_PLAIN @"The following button will open a plain PDF. The MFDocumentManager instance can be immediately used to create a DocumentViewController to push onto the stack. Look for the details in the MenuViewController class"
#define TEXT_ENCRYPTED @"The following button will open a password protected PDF. You will be asked to insert a password. The program will use the password to try to unlock the PDF and the DocumentViewController will be created only once the document has been succesfully unlocked. The password is 12345"

#define TITLE_PLAIN @"Open"
#define TITLE_ENCRYPTED @"Open"

#define DOC_PLAIN @"gitmanual"
#define DOC_ENCRYPTED @"gitmanualcrypt"

#define NUM_PDFTOSHOW 5

@implementation MenuViewController

@synthesize referenceButton, manualButton, referenceTextView, manualTextView;
@synthesize document;
@synthesize passwordAlertView;
@synthesize downloadProgressView;
@synthesize DownloadProgress;
@synthesize nomePdfDaAprire;
@synthesize buttonRemoveDict;
@synthesize buttonOpenDict;
@synthesize progressViewDict,imgDict;
@synthesize pdfHome;
@synthesize widthThumb,heightThumb,widthButton,heightButton,widthScrollView,heightScrollView,heightViewDetail,xSxThumb,xDxThumb,heightFrame,yScrollView;

-(IBAction)actionOpenPlainDocument:(id)sender {
    //
	//	We are using NSBundle to lookup the file for us, but if you store the pdf somewhere else than the application
	//	bundle, you should use the NSFileManager instead or be able to provide the right file path for the file.
	
	NSString *documentPath = [[NSBundle mainBundle]pathForResource:DOC_PLAIN ofType:@"pdf"];
	NSURL *documentUrl = [NSURL fileURLWithPath:documentPath];
	
	//
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class (a wrapper) and use
	// it to initialize an MFDocumentViewController subclass 	
	MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
	
	DocumentViewController *aDocViewController = [[DocumentViewController alloc]initWithDocumentManager:aDocManager];
	aDocViewController.nomefile=DOC_PLAIN;
	[aDocViewController initNumberOfPageToolbar];
	//
	//	In this example we use a navigation controller to present the document view controller but you can present it
	//	as a modal viewcontroller or just show a single PDF right from the beginning
	// [self presentModalViewController:aDocViewController animated:YES]; 
	
	[[self navigationController]pushViewController:aDocViewController animated:YES];
	
	[aDocViewController release];
	[aDocManager release];
	
}


-(IBAction)actionOpenPlainDocumentFromNewMain:(id)sender {
	
	//NSString *documentPath = [[NSBundle mainBundle]pathForResource:DOC_PLAIN ofType:@"pdf"];
	//NSURL *documentUrl = [NSURL fileURLWithPath:documentPath];
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	//NSLog(@"PAth : %@", paths);
	NSString *documentsDirectory = [paths objectAtIndex:0];
		
	NSString *pdfPath = [documentsDirectory stringByAppendingString:@"/"];
	pdfPath = [pdfPath stringByAppendingString:nomePdfDaAprire];
	pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	
	//NSLog(@"pdfpath :%@",pdfPath);
	//pdfPath = [pdfPath stringByAppendingString:@"/"];
	//pdfPath = [pdfPath stringByAppendingString:nomefilepdf];
	//pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	
	NSURL *documentUrl = [NSURL fileURLWithPath:pdfPath];
	
	
	
	
	//
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class (a wrapper) and use
	// it to initialize an MFDocumentViewController subclass 	
	MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
	
	DocumentViewController *aDocViewController = [[DocumentViewController alloc]initWithDocumentManager:aDocManager];
	aDocViewController.nomefile=nomePdfDaAprire;
	[aDocViewController initNumberOfPageToolbar];
	//
	//	In this example we use a navigation controller to present the document view controller but you can present it
	//	as a modal viewcontroller or just show a single PDF right from the beginning
	// [self presentModalViewController:aDocViewController animated:YES]; 
	
	[[self navigationController]pushViewController:aDocViewController animated:YES];
	
	[aDocViewController release];
	[aDocManager release];


}

-(IBAction)actionOpenEncryptedDocument:(id)sender {
	
	//
	// Create the MFDocumentManager using the encrypted file URL like we did for the plain one
	
	NSString *documentPath = [[NSBundle mainBundle]pathForResource:DOC_ENCRYPTED ofType:@"pdf"];
	NSURL *documentUrl = [NSURL fileURLWithPath:documentPath];
	
	MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
	
	// 
	//	Now we can check if the document is encrypted or not. If it is, we can store it and display a prompt
	//	to the user, asking for the password. Then we try to unlock the document in the alert callback
	
	if([aDocManager isLocked]) {
		
		[self setDocument:aDocManager];
		
		// 
		//	Create and alert a reference (assign) to it
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Insert Password" message:[NSString stringWithFormat:@"This get covered"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
		[self setPasswordAlertView:alert];
		
		//
		// Let's add a password field to the alert
		
		UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
		[passwordField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[passwordField setSecureTextEntry:YES];
		passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[passwordField setKeyboardType:UIKeyboardTypeASCIICapable];
		[passwordField setSecureTextEntry:YES];
		[passwordField setKeyboardAppearance:UIKeyboardAppearanceAlert];
		[passwordField setBackgroundColor:[UIColor whiteColor]];
		
		//
		// Now show it
		[alert addSubview:passwordField];
		[alert show];
		[alert release];
		
	} else {
		
		// This is not our case :)
		
	}
	
}


-(void)tryOpenPendingDocumentWithPassword:(NSString *)password {
	
	//
	//	The selector tryUnlockWithPassword will attemp to unlock the encrypted document and will
	//	return YES on success
	
	if([document tryUnlockWithPassword:password]) {
		
		//
		//		It works, the document is unlocked. Now you can create the DocumentViewController and push
		//		it onto the stack for display. If you want to store the password for the document, you can use
		//		core data, the settings or the keychain
		
		DocumentViewController *aDocViewController = [[DocumentViewController alloc]initWithDocumentManager:document];
		[[self navigationController]pushViewController:aDocViewController animated:YES];
		aDocViewController.nomefile=DOC_PLAIN;
		[aDocViewController release];
		
	} else {
		
		//
		//	The password is wrong. Display an error alert to let the user know
		
		UIAlertView * anAlertView = [[UIAlertView alloc]initWithTitle:@"Wrong Password" message:@"The password is wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[anAlertView show];
		[anAlertView release];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	//
//	Since we are displaying multiple alert, first check if the alertView is the password one. Once
//	we are sure of that, we can try to get the content of the password text field and use it
//	to attemp to unlock the document by calling the appropriate method
	
	if (alertView==passwordAlertView)	{
		
		if(buttonIndex == 1) {
			
			UITextField *passwordField = (UITextField *)[alertView viewWithTag:TAG_PASSWORDFIELD]; 
			NSString * password = [passwordField text];
			if(password == nil) {
				password = @"";
			}
			
			[self tryOpenPendingDocumentWithPassword:password];
		}
	}	
}





/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIFont *smallSystemFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	
	[referenceTextView setText:TEXT_PLAIN];
	[referenceTextView setFont:smallSystemFont];
	[manualTextView setText:TEXT_ENCRYPTED];
	[manualTextView setFont:smallSystemFont];
	
	[referenceButton setTitle:TITLE_PLAIN forState:UIControlStateNormal];
	[manualButton setTitle:TITLE_ENCRYPTED forState:UIControlStateNormal];
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		widthThumb=350;
		heightThumb=480;
		xSxThumb = 20;
		xDxThumb = 380;
		heightFrame = 325;
		widthScrollView=771;
		heightScrollView=875;
		heightViewDetail=665;
		yScrollView=130;
	
	}else {
		widthThumb=125;
		heightThumb=170;
		xSxThumb = 10;
		xDxThumb = 160;
		heightFrame = 115;
		widthScrollView=323;
		heightScrollView=404;
		heightViewDetail=240;
		yScrollView=60;
	}

		XMLParser *parser = [[XMLParser alloc] init];
		
		parser.mvc = self;
		
		[parser parseXMLFileAtURL:@"http://go.mobfarm.eu/pdf/xmldaparsare.xml"];
	
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yScrollView, widthScrollView, heightScrollView)];
		scrollView.backgroundColor = [UIColor whiteColor];
		scrollView.contentSize = CGSizeMake(widthScrollView, heightViewDetail * ((NUM_PDFTOSHOW/2)+1));
		
		buttonRemoveDict = [[NSMutableDictionary alloc] init];
		buttonOpenDict = [[NSMutableDictionary alloc] init];
		progressViewDict = [[NSMutableDictionary alloc] init];
	    imgDict = [[NSMutableDictionary alloc] init];
	
				for (int i=1; i<= NUM_PDFTOSHOW ; i++) {
					//NSLog(@"prova %@",[[pdfHome objectAtIndex: i-1] objectForKey: @"titolo"]);
					NSString *titoloPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"titolo"];
					NSString *linkPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"link"];
					NSString *copertinaPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"copertina"];
					MFHomeListPdf *viewPdf = [[MFHomeListPdf alloc] initWithName:titoloPdf andLinkPdf:linkPdf andnumOfDoc:i andImage:copertinaPdf andSize:CGSizeMake(widthThumb, heightThumb)];
					//MFHomeListPdf *viewPdf = [[MFHomeListPdf alloc] initWithName:titoloPdf andnumOfDoc:i andImage:copertinaPdf andSize:CGSizeMake(350, 480)];
					CGRect frame = self.view.frame;
					if ((i%2)==0) {
						frame.origin.y = (heightFrame * 2 ) * ( (i-1) / 2 );
						frame.origin.x = xDxThumb;
						frame.size.width = widthThumb;
						frame.size.height = heightViewDetail;
					}else {
						frame.origin.y = heightFrame *(i-1);
						frame.origin.x = xSxThumb;
						frame.size.width = widthThumb;
						frame.size.height = heightViewDetail;
					}
					
					viewPdf.view.frame = frame;
					viewPdf.mvc=self;
					[scrollView addSubview:viewPdf.view];
					[imgDict setValue:viewPdf.openButtonFromImage forKey:titoloPdf];
					[buttonOpenDict setValue:viewPdf.openButton forKey:titoloPdf];
					[buttonRemoveDict setValue:viewPdf.removeButton forKey:titoloPdf];
					[progressViewDict setValue:viewPdf.progressDownload forKey:titoloPdf];

				}
		[self.view addSubview:scrollView];
		
		UIImageView *border = [[UIImageView alloc] initWithFrame:CGRectMake(0, yScrollView-3, widthScrollView, 40)]; 
		[border setImage:[UIImage imageNamed:@"border.png"]];
		[self.view addSubview:border];
		[border release];
	//}
}

-(void)showViewDownload{
	//if (DownloadProgress.frame.origin.y >= self.view.bounds.size.height) {
		//toolbar.hidden = NO;
	DownloadProgress.hidden = NO;
		[UIView beginAnimations:@"show" context:NULL];
		[UIView setAnimationDuration:0.10];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		//[toolbar setFrame:CGRectMake(0, 0, toolbar.frame.size.width, 44)];
		[DownloadProgress setFrame:CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width, 200)];
		[UIView commitAnimations];
		//DownloadProgress = YES;
	//}
}

-(void)hideViewDownload{
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	//[toolbar setFrame:CGRectMake(0, -44, toolbar.frame.size.width, 44)];
	[DownloadProgress setFrame:CGRectMake(0, DownloadProgress.frame.origin.y+DownloadProgress.frame.size.height, DownloadProgress.frame.size.width, DownloadProgress.frame.size.height)];
	[UIView commitAnimations];
	//thumbsViewVisible = NO;
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if(interfaceOrientation == UIDeviceOrientationPortrait){
		return YES;
	}else {
		return NO;
	}
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[self setManualButton:nil];
	[self setManualTextView:nil];
	[self setReferenceButton:nil];
	[self setReferenceTextView:nil];
	[buttonRemoveDict dealloc];
	[buttonOpenDict dealloc];
	[progressViewDict dealloc];
	[imgDict dealloc];
}


- (void)dealloc {
    [super dealloc];
}

@end
