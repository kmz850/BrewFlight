//
//  EventDetailViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 10/28/12.
//
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "AddBeerViewController.h"
#import <MapKit/MapKit.h>

@interface EventDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AddBeerDelegate>
{
    Event *event;
    IBOutlet UITableView *tableView;
    NSString *webserver;
    __weak IBOutlet MKMapView *mapView;
    __weak IBOutlet UIImageView *foursquareLocImg;
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UILabel *lblDate;
    __weak IBOutlet UILabel *lblAddress;
    
}

@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *webserver;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIImageView *foursquareLocImg;
@property (nonatomic, retain) UILabel *lblLocation;
@property (nonatomic, retain) UILabel *lblDate;
@property (nonatomic, retain) UILabel *lblAddress;



@end
