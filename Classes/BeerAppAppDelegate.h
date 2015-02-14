//
//  BeerAppAppDelegate.h
//  BeerApp
//
//  Created by Keith Zenoz on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationViewController.h"
//@class BeerAppViewController;
//@class SwitchViewController;

@interface BeerAppAppDelegate : NSObject <UIApplicationDelegate, UITableViewDelegate, UITableViewDataSource> {
    UIWindow *window;
    IBOutlet UINavigationController *navController;
    IBOutlet LocationViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet LocationViewController *viewController;

@end

