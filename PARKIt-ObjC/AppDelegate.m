//
//  AppDelegate.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-17.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "AppDelegate.h"
#import "PIRootViewControllerHandler.h"
#import "PIConstants.h"

@import GoogleMaps;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // setup window & get root view controller
    [self setupWindow];
    // GoogleMpas setup
    [self setupGoogleMaps];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupRootViewController) name:RootViewControllerChangeNotification object:nil];
    
    return YES;
}

- (void)setupWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self setupRootViewController];
}

- (void)setupRootViewController {
    self.window.rootViewController = [PIRootViewControllerHandler rootViewController];
}

- (void)setupGoogleMaps{
    // GoogleMaps setup
    [GMSServices provideAPIKey:@"AIzaSyChjJ0M0f3VjuZJ2j-xRnx-cxYa6wmUJ2s"];
}

@end
