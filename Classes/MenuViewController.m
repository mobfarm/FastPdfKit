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
#include <stdio.h>
#include <stdlib.h>

#define TEXT_PLAIN @"The following button will open a plain PDF. The MFDocumentManager instance can be immediately used to create a DocumentViewController to push onto the stack. Look for the details in the MenuViewController class"
#define TEXT_ENCRYPTED @"The following button will open a password protected PDF. You will be asked to insert a password. The program will use the password to try to unlock the PDF and the DocumentViewController will be created only once the document has been succesfully unlocked. The password is 12345"

#define TITLE_PLAIN @"Open"
#define TITLE_ENCRYPTED @"Open"

#define DOC_PLAIN @"gitmanual"
#define DOC_ENCRYPTED @"gitmanualcrypt"

#define NUM_PDFTOSHOW 9

@implementation MenuViewController

@synthesize referenceButton, manualButton, referenceTextView, manualTextView;
@synthesize document;
@synthesize passwordAlertView;
@synthesize downloadProgressView;
@synthesize DownloadProgress;

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
	
	NSLog(@"PAth : %@", paths);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSLog(@"documentsDirectory : %@", documentsDirectory);
	
	
	
	NSString *pdfPath = [documentsDirectory stringByAppendingString:@"/"];
	pdfPath = [pdfPath stringByAppendingString:nomePdfDaAprire];
	
	NSLog(@"pdfpath :%@",pdfPath);
	//pdfPath = [pdfPath stringByAppendingString:@"/"];
	//pdfPath = [pdfPath stringByAppendingString:nomefilepdf];
	//pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	
	NSURL *documentUrl = [NSURL fileURLWithPath:pdfPath];
	
	
	
	
	//
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class (a wrapper) and use
	// it to initialize an MFDocumentViewController subclass 	
	MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
	
	DocumentViewController *aDocViewController = [[DocumentViewController alloc]initWithDocumentManager:aDocManager];
	aDocViewController.nomefile=DOC_PLAIN;
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
	
	nomePdfDaAprire  = @"pdf1.pdf";
	
	UIFont *smallSystemFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	
	[referenceTextView setText:TEXT_PLAIN];
	[referenceTextView setFont:smallSystemFont];
	[manualTextView setText:TEXT_ENCRYPTED];
	[manualTextView setFont:smallSystemFont];
	
	[referenceButton setTitle:TITLE_PLAIN forState:UIControlStateNormal];
	[manualButton setTitle:TITLE_ENCRYPTED forState:UIControlStateNormal];
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		NSMutableArray *arrayPdf = [NSMutableArray arrayWithCapacity:NUM_PDFTOSHOW];
		
		
		for (int i=0; i<= NUM_PDFTOSHOW-1 ; i++) {
			NSString *myString = [NSString stringWithFormat:@"%d",i+1];
			[arrayPdf addObject:[@"pdf" stringByAppendingString:myString]];
		}
		
		//[appDelegate.nameArray addObject:playerName];
	
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 130, 768, 900)];
		scrollView.backgroundColor = [UIColor lightGrayColor];
		scrollView.contentSize = CGSizeMake(768, 590 * ((NUM_PDFTOSHOW/2)+1));
			
	
				for (int i=1; i<= NUM_PDFTOSHOW ; i++) {
					MFHomeListPdf *ViewPdf = [[MFHomeListPdf alloc] initWithName:[arrayPdf objectAtIndex:i-1] andnumOfDoc:i andImage:@"icon144.png" andSize:CGSizeMake(350, 450)];
					//MFHomeListPdf *ViewPdf = [[MFHomeListPdf alloc] initWithPageNumber:i andImage:@"icon144.png" andSize:CGSizeMake(350, 450)];
					CGRect frame = self.view.frame;
					if ((i%2)==0) {
						frame.origin.y = 580 * ( (i-1) / 2 );
						frame.origin.x = 380;
						frame.size.width = 350;
					}else {
						frame.origin.x = 20;
						frame.origin.y = 290 *(i-1);
						frame.size.width = 350;
					}
					
					ViewPdf.view.frame = frame;
					ViewPdf.mvc=self;
					[scrollView addSubview:ViewPdf.view];
				}
		[self.view addSubview:scrollView];
		
		DownloadProgress = [[UIView alloc ] initWithFrame:CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width, 200)];
		DownloadProgress.backgroundColor = [UIColor lightGrayColor];
		downloadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 40, DownloadProgress.frame.size.width-30, 20)];
		downloadProgressView.progress= 1.0;
		UILabel *labelDownload  = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, DownloadProgress.frame.size.width-30, 20)];
		labelDownload.backgroundColor = [UIColor clearColor];
		labelDownload.text = @"DOWNLOAD IN CORSO ... ATTENDERE" ;
		[DownloadProgress addSubview:downloadProgressView];
		[DownloadProgress addSubview:labelDownload];
		DownloadProgress.hidden = YES;
		[self.view addSubview:DownloadProgress];
		
	}
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
    return YES;
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
}


- (void)dealloc {
    [super dealloc];
}


@end
