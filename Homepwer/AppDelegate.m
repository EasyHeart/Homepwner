//
//  AppDelegate.m
//  Homepwner
//
//  Created by hangliu on 15/6/3.
//  Copyright (c) 2015年 MoonBright. All rights reserved.
//

#import "AppDelegate.h"
#import "LYMItemsViewController.h"
#import "LYMItemStore.h"

NSString *const LYMNextItemValuePrefsKey = @"NextItemValue";
NSString *const LYMNextItemNamePrefsKey = @"NextItemName";


@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *factorySettings = @{LYMNextItemValuePrefsKey:@75,
                                      LYMNextItemNamePrefsKey:@"Coffee Cup"
                                      };
    [defaluts registerDefaults:factorySettings];
    NSLog(@"%@",[defaluts dictionaryRepresentation]);
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (!self.window.rootViewController) {
    LYMItemsViewController *itemViewController = [[LYMItemsViewController alloc]init];
    UINavigationController *nav =[[UINavigationController alloc]initWithRootViewController:itemViewController];
    nav.restorationIdentifier = NSStringFromClass([nav class]);
    self.window.rootViewController = nav;
    }
    //NSLog(@"%@",NSHomeDirectory());
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIViewController *)application:(nonnull UIApplication *)application viewControllerWithRestorationIdentifierPath:(nonnull NSArray *)identifierComponents coder:(nonnull NSCoder *)coder
{
    UIViewController *vc = [[UINavigationController alloc]init];
    vc.restorationIdentifier = [identifierComponents lastObject];
    if ([identifierComponents count]==1) {
        self.window.rootViewController = vc;
    }
    
    return vc;
}

- (BOOL)application:(nonnull UIApplication *)application shouldSaveApplicationState:(nonnull NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(nonnull UIApplication *)application shouldRestoreApplicationState:(nonnull NSCoder *)coder
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    [defaluts synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[LYMItemStore sharedStore]saveChanges];
    if (success) {
        NSLog(@"Saved all of the LYMItems");
    } else {
        NSLog(@"Could not save any of the LYMItems");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
