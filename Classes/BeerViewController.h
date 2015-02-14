//
//  PresidentsViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBeerViewController.h"
#import "BeerDetailController.h"
//#import "SecondLevelViewController.h"
@class PresidentDetailController;

//@interface PresidentsViewController : UIViewController {
  
@interface BeerViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource, EditBeerDelegate/*, AddBeerDelegate*/> {
    
        UIImage *rowImage;
        NSString *detailTitle;
        IBOutlet UITableView *tableView;
        IBOutlet UISegmentedControl *segmentedControl;
        NSString *locationId;
        NSMutableArray *beers;
        NSMutableDictionary *beerDict;
        NSMutableDictionary *upcomingBeers;
        NSString *webserver;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSString *webserver;
@property (nonatomic, retain) NSMutableArray *beers;
@property (nonatomic, retain) NSMutableDictionary *beerDict;
@property (nonatomic, retain) NSMutableDictionary *upcomingBeers;
@property (nonatomic, retain) UIImage *rowImage;
@property (nonatomic, retain) NSString *detailTitle;

@end
