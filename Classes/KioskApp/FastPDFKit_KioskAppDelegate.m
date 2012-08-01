//
//  FastPDFKit_KioskAppDelegate.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "FastPDFKit_KioskAppDelegate.h"
#import "MenuViewController_Kiosk.h"
#import "ZipArchive.h"



@implementation FastPDFKit_KioskAppDelegate
@synthesize window,navigationController;
@synthesize menuVC_Kiosk;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Load default settings
    
    NSString * bundlePath = [[NSBundle mainBundle]bundlePath];
    NSString * settingsBundlePath = [bundlePath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString * settingsPath = [NSBundle pathForResource:@"Root" ofType:@"plist" inDirectory:settingsBundlePath];
    
    NSDictionary * settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:settingsDictionary];
    
    //Comment the line below to disable NewsStand remote Notification
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",@"FastPdfKit_Kiosk-Info"]];
    
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    BOOL newsStandEnabled = [[plistDict objectForKey:@"UINewsstandApp"]boolValue];
    
    if(newsStandEnabled){
        // TODO: decomment this to enable multiple notifications on the same day

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
        
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeNewsstandContentAvailability];
    } else {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
    }
    
    if([launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]){
        [self application:application didReceiveRemoteNotification:[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
    }
	
    // Uncomment to print the library version.
    // NSLog(@"FastPdfKit Version: %@",[MFDocumentManager version]);
    
    MenuViewController_Kiosk *aMenuViewController = nil;
	
	BOOL isPad = NO;
	
#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	
	if(isPad) {
			aMenuViewController = [[MenuViewController_Kiosk alloc]initWithNibName:@"Kiosk_ipad" bundle:MF_BUNDLED_BUNDLE(@"FPKKioskBundle")];
	} else {
			aMenuViewController = [[MenuViewController_Kiosk alloc]initWithNibName:@"Kiosk_phone" bundle:MF_BUNDLED_BUNDLE(@"FPKKioskBundle")];
	}
    
    menuVC_Kiosk = aMenuViewController;
    
	UINavigationController *aNavController = [[UINavigationController alloc]initWithRootViewController:menuVC_Kiosk];
	[aNavController setNavigationBarHidden:YES];
	[self setNavigationController:aNavController];
	
	[window addSubview:[aNavController view]];
    [window makeKeyAndVisible];
	
	// Cleanup
	
	[aNavController release];
	[aMenuViewController release];
    [plistDict release];
	
	return YES;
}


#pragma mark -
#pragma mark NewsStand callBack

 
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    UIRemoteNotificationType type = [application enabledRemoteNotificationTypes];	
    if (type > 0) {	
        NSString *deviceTokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];

        NSLog(@"Device Token: %@", deviceTokenStr);
    }
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Did Fail To Register for remote notifications: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"Did Receive Remote Notification");
    
    NSNumber * content = [[userInfo objectForKey:@"aps"] objectForKey:@"content-available"];
    if(content && [content intValue] > 0){
        NSLog(@"Content Available: %i", [content intValue]);
        int newNKItems = [content intValue];
        
        UIApplication *app = [UIApplication sharedApplication];
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{ 
            [app endBackgroundTask:bgTask]; 
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        NSString *namePdf = @"";
        NSString *urlS = @"";
        
        /**
         In the remote notification you need to provide the pdf name and the url.
         The same of one of the document in the source xml.
         
         Something like
         
         {
            "aps": {
                "badge": 1,
                "alert": "New Issue available", 
                "content-available":1,
                "name-pdf":"License", 
                "link-pdf":"http://fastpdfkit.com/license.pdf"
            }
         }
         
        */
        
        if ([[userInfo objectForKey:@"aps"] objectForKey:@"name-pdf"]){
            namePdf = [[userInfo objectForKey:@"aps"] objectForKey:@"name-pdf"];
            NSLog(@"PDF Name: %@", namePdf);
        }
            
        if([[userInfo objectForKey:@"aps"] objectForKey:@"link-pdf"]){
            urlS = [[userInfo objectForKey:@"aps"] objectForKey:@"link-pdf"];
            NSLog(@"PDF URL: %@", urlS);
        }
            

        if(![namePdf isEqualToString:@""] && ![urlS isEqualToString:@""]){
            NSURL *url = [NSURL URLWithString:urlS];
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
            [request release];
        }        
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_Error" object:nil];
    
    NSLog(@"Download Failed");
    
    
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    //write pdf
    
    NKAssetDownload *asset = [connection newsstandAssetDownload];
    NSString *filename = [[asset userInfo] objectForKey:@"filename"];
    NSString *suffix = nil;
    NSString *path = nil;
    
    NSArray *tempArray = [NSArray arrayWithObjects:filename, [NSNumber numberWithInt:[filename intValue]], nil];  
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    [path stringByAppendingPathComponent:filename];
    
    
    if([[destinationURL absoluteString] hasSuffix:@"fpk"]) {
        suffix = @"fpk";
        
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",filename,suffix]];
        [[NSFileManager defaultManager] copyItemAtPath:[destinationURL path] toPath:path error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[destinationURL path] error:nil];
            if ([self handleFPKFile:filename]) [[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_OK" object:tempArray];
        else [[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_Error" object:nil];
        
    } else {    
        suffix = @"pdf";
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",filename,suffix]];
        NSLog(@"path %@",path);
        NSError *error = nil;    
        [[NSFileManager defaultManager] copyItemAtPath:[destinationURL path] toPath:path error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:[destinationURL path] error:&error];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"down_Doc_OK" object:tempArray];
    }
    
    //reload interface
    if (menuVC_Kiosk) {
        if (menuVC_Kiosk.interfaceLoaded) {
            [menuVC_Kiosk buildInterface];
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes{
    // You can update the loading bar
}

- (BOOL)handleFPKFile:(NSString *)namePdf {
    NSLog(@"At the end of PDF download");
    
    BOOL zipStatus = NO;
    
    ZipArchive * zipFile = nil;
    NSArray * dirContents = nil;
    
    NSString * oldPath = nil;
    NSString * newPath = nil;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *unzippedDestination = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/",namePdf]];
    NSString *saveLocation = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.fpk",namePdf,namePdf]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:unzippedDestination withIntermediateDirectories:YES attributes:nil error:nil];        
    
    zipFile = [[ZipArchive alloc] init];
    [zipFile UnzipOpenFile:saveLocation];
    zipStatus = [zipFile UnzipFileTo:unzippedDestination overWrite:YES];    
    [zipFile UnzipCloseFile];
    [zipFile release];
    
    dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzippedDestination error:nil];
    
    
    BOOL pdfStatus = NO;
    for (NSString *tString in dirContents) {
        
        if ([tString hasSuffix:@".pdf"]) {
            
            oldPath =[unzippedDestination stringByAppendingString:tString];
            newPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.pdf",namePdf,namePdf]];
            
            [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];				
            pdfStatus = YES;
        }
    }
    
    return zipStatus && pdfStatus;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	
	[navigationController release];
    [window release];
    [menuVC_Kiosk release];
    [super dealloc];
}


@end

