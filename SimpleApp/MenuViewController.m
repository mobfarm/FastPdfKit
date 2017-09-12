    //
//  MenuViewController.m
//  FastPdfKit
//
//  Created by Nicolò Tosi on 8/26/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MenuViewController.h"
#import <FastPdfKit/FastPdfKit.h>
#import "OverlayManager.h"

#include <stdio.h>
#include <stdlib.h>

#define TEXT_PLAIN @"The following button will open a plain PDF. The MFDocumentManager instance can be immediately used to create a DocumentViewController to push onto the stack. Look for the details in the MenuViewController class"
#define TEXT_ENCRYPTED @"The following button will open a password protected PDF. You will be asked to insert a password. The program will use the password to try to unlock the PDF and the DocumentViewController will be created only once the document has been succesfully unlocked. The password is 12345"

#define TITLE_PLAIN @"Open"
#define TITLE_ENCRYPTED @"Open"

#define DOC_PLAIN @"Manual"
#define DOC_ENCRYPTED @"ManualCrypt"

#define TAG_ALERTVIEW 1
#define TAG_PASSWORDFIELD 2

@implementation MenuViewController

#pragma mark - Plain document

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
    
    ReaderViewController * readerViewController = [[ReaderViewController alloc]initWithDocumentManager:aDocManager];
    readerViewController.edgesForExtendedLayout = UIRectEdgeNone;
	[readerViewController setDocumentId:DOC_PLAIN];   // We use the filename as an ID. You can use whaterver you like, like the id entry in a database or the hash of the document.
	[readerViewController setDocumentDelegate:readerViewController];
    
    // We are adding an image overlay on the first page on the bottom left corner
    OverlayManager *ovManager = [[OverlayManager alloc] init];
    [readerViewController addOverlayDataSource:ovManager];

	//	In this example we use a navigation controller to present the document view controller but you can present it
	//	as a modal viewcontroller or just show a single PDF right from the beginning
	// [self presentModalViewController:aDocViewController animated:YES]; 
	// [[self navigationController]pushViewController:aDocViewController animated:YES];
	
    [self presentViewController:readerViewController animated:YES completion:nil];
}

#pragma mark - Encrypted document

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
        
        if([UIAlertController class]) { // iOS8 and above.
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Document locked" message:@"Insert the password." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.secureTextEntry = YES;
            }];
            
            id __weak this = self;
            UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"Unlock" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                UITextField * passwordTextField = alertController.textFields[0];
                NSString * password = passwordTextField.text;
                
                [this tryOpenPendingDocumentWithPassword:password];
            }];
            [alertController addAction:confirmAction];

            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Document locked" message:@"Insert the password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Unlock",nil];
            alert.tag = TAG_ALERTVIEW;
            alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
            [alert show];
        }
        
	} else {
		
		// This is not our case :)
		
	}
}

-(void)tryOpenPendingDocumentWithPassword:(NSString *)password {
	
	//	The selector tryUnlockWithPassword will attemp to unlock the encrypted document and will
	//	return YES on success
	
	if([self.document tryUnlockWithPassword:password]) {
		
		//		It works, the document is unlocked. Now you can create the DocumentViewController and push
		//		it onto the stack for display. If you want to store the password for the document, you can use
		//		core data, the settings or the keychain
		
		ReaderViewController *aDocViewController = [[ReaderViewController alloc]initWithDocumentManager:self.document];
        aDocViewController.edgesForExtendedLayout = UIRectEdgeNone;
        self.document = nil;
        
        [aDocViewController setDocumentId:DOC_ENCRYPTED]; // We know that in this sample that the file can only be this one.
		[[self navigationController]pushViewController:aDocViewController animated:YES];
		aDocViewController.documentId = DOC_ENCRYPTED;

		
	} else {
		
        //	The password is wrong. Display an error alert to let the user know
        
        if([UIAlertController class]) { // iOS 8 and above.
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Wrong password" message:@"The password is wrong!" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
            }];
            
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            
            UIAlertView * anAlertView = [[UIAlertView alloc]initWithTitle:@"Wrong Password"
                                                                  message:@"The password is wrong!"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
            [anAlertView show];
        }
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	//
//	Since we are displaying multiple alert, first check if the alertView is the password one. Once
//	we are sure of that, we can try to get the content of the password text field and use it
//	to attemp to unlock the document by calling the appropriate method
	
	if (alertView.tag == TAG_ALERTVIEW)	{
		
		if(buttonIndex == 1) {
			
            UITextField *passwordField = (UITextField *)[alertView textFieldAtIndex:0];
            NSString * password = passwordField.text ? : @""; // Use empty string if nil.
			[self tryOpenPendingDocumentWithPassword:password];
		}
	}	
}

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
		//No graphics visualization
		
		UIFont *smallSystemFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		
		[self.referenceTextView setText:TEXT_PLAIN];
		[self.referenceTextView setFont:smallSystemFont];
		[self.manualTextView setText:TEXT_ENCRYPTED];
		[self.manualTextView setFont:smallSystemFont];
		
		[self.referenceButton setTitle:TITLE_PLAIN forState:UIControlStateNormal];
		[self.manualButton setTitle:TITLE_ENCRYPTED forState:UIControlStateNormal];
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

@end
