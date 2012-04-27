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
#import "OverlayManager.h"

#include <stdio.h>
#include <stdlib.h>

#define TEXT_PLAIN @"The following button will open a plain PDF. The MFDocumentManager instance can be immediately used to create a DocumentViewController to push onto the stack. Look for the details in the MenuViewController class"
#define TEXT_ENCRYPTED @"The following button will open a password protected PDF. You will be asked to insert a password. The program will use the password to try to unlock the PDF and the DocumentViewController will be created only once the document has been succesfully unlocked. The password is 12345"

#define TITLE_PLAIN @"Open"
#define TITLE_ENCRYPTED @"Open"

#define DOC_PLAIN @"Manual"
#define DOC_ENCRYPTED @"ManualCrypt"

@implementation MenuViewController

@synthesize referenceButton, manualButton, referenceTextView, manualTextView;
@synthesize passwordAlertView;
@synthesize nomePdfDaAprire;
@synthesize document;

-(IBAction)actionOpenPlainDocument:(id)sender {
    //
	//	We are using NSBundle to lookup the file for us, but if you store the pdf somewhere else than the application
	//	bundle, you should use the NSFileManager instead or be able to provide the right file path for the file.
	
    NSString *filePath = [[NSBundle mainBundle]pathForResource:DOC_PLAIN ofType:@"pdf"];
	NSURL *documentUrl = [NSURL fileURLWithPath:filePath];
	
	//
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class (a wrapper) and use
	// it to initialize an MFDocumentViewController subclass 	
	MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
    
	DocumentViewController *aDocViewController = [[DocumentViewController alloc]initWithDocumentManager:aDocManager];
	[aDocViewController setDocumentId:DOC_PLAIN];   // We use the filename as an ID. You can use whaterver you like, like the id entry in a database or the hash of the document.
	[aDocViewController setDocumentDelegate:aDocViewController];
    
    // We are adding an image overlay on the first page on the bottom left corner
    OverlayManager *ovManager = [[OverlayManager alloc] init];
    [aDocViewController addOverlayDataSource:ovManager];
    [ovManager release];
    
    // This delegate has been added just to manage the links between pdfs, skip it if you just need standard visualization
    [aDocViewController setDelegate:self];
    
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
        [aDocManager release];
        
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
		[passwordField setTag:TAG_PASSWORDFIELD];
		
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
        [aDocViewController setDocumentId:DOC_ENCRYPTED]; // We know that in this sample that the file can only be this one.
		[[self navigationController]pushViewController:aDocViewController animated:YES];
		aDocViewController.documentId = DOC_ENCRYPTED;
		[aDocViewController release];
		
	} else {
		
		//
		//	The password is wrong. Display an error alert to let the user know
		
		UIAlertView * anAlertView = [[UIAlertView alloc]initWithTitle:@"Wrong Password" message:@"The password is wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[anAlertView show];
		[anAlertView release];
	}
}


/* This method should be called from the DocumentViewController when you get a link to another document */

-(void)setLinkedDocument:(NSString *)documentName withPage:(NSUInteger)destinationPage orDestinationName:(NSString *)destinationName{
    
    NSArray *params = [NSArray arrayWithObjects:documentName,destinationName,[NSNumber numberWithInt:destinationPage], nil];
    [self performSelector:@selector(openDocumentWithParams:) withObject:params afterDelay:0.5];
}

/* This method opens a linked document after a delay to let you pop the controller */

-(void)openDocumentWithParams:(NSArray *)params{
    
    // Depending on the link format you need to manage the destination path accordingly to your own application path
    // In this example we are assuming that every document is placed in your application bundle at the same level
    NSString *filePath = [[NSBundle mainBundle]pathForResource:[[[params objectAtIndex:0] lastPathComponent] stringByDeletingPathExtension] ofType:@"pdf"];
	NSURL *documentUrl = [NSURL fileURLWithPath:filePath];    
    
	MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
    
	DocumentViewController *aDocViewController = [[DocumentViewController alloc]initWithDocumentManager:aDocManager];
	[aDocViewController setDocumentId:[params objectAtIndex:0]];
    
    int page;
    if([[params objectAtIndex:2] intValue] != -1){
        page = [[params objectAtIndex:2] intValue];
    } else {
        // We need to parse the pdf to get the correct page
        page = [aDocManager pageNumberForDestinationNamed:[params objectAtIndex:1]];
    }
    
    [aDocViewController setPage:page];
	[aDocViewController setDocumentDelegate:aDocViewController];
    [aDocViewController setDelegate:self];
    
	[[self navigationController]pushViewController:aDocViewController animated:YES];
	
	[aDocViewController release];
	[aDocManager release];
    
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
		//No graphics visualization
		
		UIFont *smallSystemFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		
		[referenceTextView setText:TEXT_PLAIN];
		[referenceTextView setFont:smallSystemFont];
		[manualTextView setText:TEXT_ENCRYPTED];
		[manualTextView setFont:smallSystemFont];
		
		[referenceButton setTitle:TITLE_PLAIN forState:UIControlStateNormal];
		[manualButton setTitle:TITLE_ENCRYPTED forState:UIControlStateNormal];
			
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
