//
//  EventViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Event.h"
#import "AddEventLocationViewController.h"

@interface EventViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate, AddEventLocationDelegate>
{
    IBOutlet UISegmentedControl *segmentedControl;
    NSString *latitude;
    NSString *longitude;
    CLLocationManager *locationManager;
    IBOutlet UITableView *tableView;
    NSString *webserver;
    //NSMutableDictionary *eventDict;
    NSMutableArray *eventArray;
    NSMutableArray *eventUpcomingArray;
    Event *selectedEvent;
    NSMutableDictionary *addressByLocId;
    NSMutableDictionary *foursquareInfoByLocId;
    UIRefreshControl *refreshControl;
}

@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *webserver;
//@property (nonatomic, retain) NSMutableDictionary *eventDict;
@property (nonatomic, retain) NSMutableArray *eventArray;
@property (nonatomic, retain) NSMutableArray *eventUpcomingArray;
@property (nonatomic, retain) Event *selectedEvent;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSMutableDictionary *addressByLocId;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (nonatomic, retain) NSMutableDictionary *foursquareInfoByLocId;

@end
