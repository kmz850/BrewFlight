//
//  BeerAppAppDelegate.h
//  BeerApp
//
//  Created by Keith Zenoz on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class BeerAppViewController;
@class SwitchViewController;

@interface BeerAppAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet SwitchViewController *switchViewController;
    //BeerAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) SwitchViewController *switchViewController;
//@property (nonatomic, retain) IBOutlet BeerAppViewController *viewController;

@end

