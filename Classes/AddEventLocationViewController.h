//
//  AddEventLocationViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 1/3/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Event.h"
#import "AddEventViewController.h"
#import "Location.h"

@class Event;

@protocol AddEventLocationDelegate <NSObject>

- (void)didAddEvent:(Event *)event;

@end

@interface AddEventLocationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, AddEventDelegate> {
    NSString *latitude;
    NSString *longitude;
    CLLocationManager *locationManager;
    IBOutlet UISearchDisplayController *searchDisplayController;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UITableView *tableView;
    UITableView *autocompleteTableView;
    NSMutableArray *arrayOfLocations;
    NSString *locationId;
    id delegate;
    Location *selectedLocation;
    NSMutableArray *autocompleteLocations;
}


@property (nonatomic, assign) id <AddEventLocationDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *arrayOfLocations;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) Location *selectedLocation;
@property (nonatomic, retain) UITableView *autocompleteTableView;
@property (nonatomic, retain) NSMutableArray *autocompleteLocations;

@end
