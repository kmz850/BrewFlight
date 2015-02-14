//
//  SwitchViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BarsViewController;
@class BeerAppViewController;

@interface SwitchViewController : UIViewController {
    
    BarsViewController *barsViewController;
    BeerAppViewController *beerAppViewController;
}

@property (retain, nonatomic) BarsViewController *barsViewController;
@property (retain, nonatomic) BeerAppViewController *beerAppViewController;

-(IBAction)switchViews:(id)sender;

@end
