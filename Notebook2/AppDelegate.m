//
//  AppDelegate.m
//  Notebook2
//
//  Created by Sergey on 7/14/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//


#import "ViewController.h"
#import "ContactsModel.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[ContactsModel model];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController* vc = [[ViewController alloc] initWithNibName:nil bundle:nil];
    
    UINavigationController* nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [nv.navigationBar setTranslucent:YES];
    
    self.window.rootViewController = nv;
    
    [self.window makeKeyAndVisible];
    

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // FBSample logic
    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
    
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //[[ContactsModel model] writeToFile];
    
    //[FBSession.activeSession close];
    
    
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [ContactsModel model ].managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}





- (BOOL) application:(UIApplication *) application
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(id)annotation
{
    NSLog ( @"application openURL");
    NSLog ( @"URL = %@", url);
    NSLog ( @"Application = %@", sourceApplication);
    // Call FBAppCall's ha
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    //[LoginUIViewController updateView];
    
    return wasHandled;
}
 
 




@end
