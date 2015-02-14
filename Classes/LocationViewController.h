//
//  LocationViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"

//@interface LocationViewController : UIViewController <UITableViewDelegate,ITableViewDataSource> {

//@interface LocationViewController : UITableViewController <CLLocationManagerDelegate> {
@interface LocationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>{
    NSArray *locations;
    NSArray *locationsSearch;
    NSMutableArray *locationIcons;
    NSMutableDictionary *tmpBeerControllers;
    NSString *latitude;
    NSString *longitude;
    NSString *webserver;
    CLLocationManager *locationManager;
    UISearchDisplayController *searchDisplayController;
    UISearchBar *searchBar;
    UITableView *autocompleteTableView;
    IBOutlet UITableView *tableView;
    NSMutableDictionary *autocompleteLocations;
    __weak IBOutlet UIBarButtonItem *emailButton;
    UIRefreshControl *refreshControl;
    __weak IBOutlet UIImageView *imageView;
    
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *emailButton;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) NSArray *locationsSearch;
@property (nonatomic, retain) NSMutableArray *locationIcons;
@property (nonatomic, retain) NSMutableDictionary *tmpBeerControllers;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *webserver;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) UITableView *autocompleteTableView;
@property (nonatomic, retain) NSMutableDictionary *autocompleteLocations;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;


- (IBAction) composeEmail;


@end
