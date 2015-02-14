//
//  DeleteMeController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"

@interface DeleteMeController : SecondLevelViewController {
    NSMutableArray *list;
    NSMutableArray *beers;
}

@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) NSMutableArray *beers;
-(IBAction)toggleEdit:(id)sender;

@end
