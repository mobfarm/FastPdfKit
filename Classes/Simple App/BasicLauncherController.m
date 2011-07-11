    //
//  BasicLauncherController.m
//  FastPDFKit Sample
//
//  Created by Matteo Gavagnin on 21/10/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "BasicLauncherController.h"
#import "MFDocumentManager.h"
#import "DocumentViewController.h"

#define DOC_PLAIN @"gitmanual"

@implementation BasicLauncherController

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
	
	//	In this example we use a a modal viewcontroller to present the document view controller but you can present it
	//	with a navigation viewcontroller or just show a single PDF right from the beginning
	[self presentModalViewController:aDocViewController animated:YES]; 
	
	[aDocViewController release];
	[aDocManager release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Opening the pdf at launch
	[self performSelector:@selector(actionOpenPlainDocument:) withObject:nil afterDelay:0.1];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}

@end