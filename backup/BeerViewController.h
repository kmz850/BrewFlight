//
//  PresidentsViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"
@class PresidentDetailController;

//@interface PresidentsViewController : UIViewController {
  
@interface BeerViewController : SecondLevelViewController 
    <UITableViewDelegate, UITableViewDataSource> {
    
        NSString *locationId;
        NSMutableArray *beers;
}

@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSMutableArray *beers;

@end
