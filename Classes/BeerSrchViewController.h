//
//  BeerSrchViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BeerSrchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate>
{
    NSString *latitude;
    NSString *longitude;
    NSString *webserver;
    NSMutableArray *filteredBeers;
    NSMutableDictionary *beerDetails;
    NSMutableDictionary *nameToId;
    NSMutableDictionary *beerLocations;
    NSMutableDictionary *locationAddress;
    NSMutableDictionary *locationNames;
    NSMutableDictionary *locationIcons;
    CLLocationManager *locationManager;
    IBOutlet UISearchDisplayController *searchDisplayController;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UITableView *tableView;
    UIRefreshControl *refreshControl;
}

@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *webserver;
@property (nonatomic, retain) NSMutableArray *filteredBeers;
@property (nonatomic, retain) NSMutableDictionary *beerDetails;
@property (nonatomic, retain) NSMutableDictionary *nameToId;
@property (nonatomic, retain) NSMutableDictionary *beerLocations;
@property (nonatomic, retain) NSMutableDictionary *locationAddress;
@property (nonatomic, retain) NSMutableDictionary *locationNames;
@property (nonatomic, retain) NSMutableDictionary *locationIcons;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end
