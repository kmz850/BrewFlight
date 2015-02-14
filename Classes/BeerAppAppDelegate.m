//
//  BeerAppAppDelegate.m
//  BeerApp
//
//  Created by Keith Zenoz on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BeerAppAppDelegate.h"
#import "LocationViewController.h"

@implementation BeerAppAppDelegate

@synthesize window;
@synthesize navController;
@synthesize viewController;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    // Override point for customization after application launch.

	// Set the view controller as the window's root view controller and display.
    //self.viewController = [[[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil] autorelease];
    //self.window.rootViewController = self.viewController;
    
    self.window.rootViewController = self.viewController;
    //[window addSubview: navController.view];
    //[window addSubview: viewController.view];
    
    [self.window makeKeyAndVisible];
   // [self.window makeKeyAndVisible];
    

}

- (void)dealloc {
    //[viewController release];
    [window release];
    [navController release];
    [viewController release];
    [super dealloc];
}


@end
