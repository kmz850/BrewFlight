//
//  AddEventViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 12/8/12.
//
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Location.h"
#import <MapKit/MapKit.h>

@class Event;

@protocol AddEventDelegate <NSObject>

- (void)didAddEvent:(Event *)event;

@end

@interface AddEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{

    IBOutlet UITextField *name;
    IBOutlet UITextField *address;
    IBOutlet UITextField *date;
    UIDatePicker *tapDatePicker;
    NSString *locationId;
    Location *location;
    id delegate;
    __weak IBOutlet MKMapView *mapView;
    
}

@property (nonatomic, assign) id <AddEventDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITextField *name;
@property (retain, nonatomic) IBOutlet UITextField *address;
@property (retain, nonatomic) IBOutlet UITextField *date;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) UIDatePicker *tapDatePicker;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) MKMapView *mapView;

@end
