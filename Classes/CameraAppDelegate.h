//
//  CameraAppDelegate.h
//  Camera
//
//  Created by Dave Mark on 12/16/1/Users/keithzenoz/Desktop/BeerApp/Classes/CameraAppDelegate.h0.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;

@interface CameraAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CameraViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CameraViewController *viewController;

@end

