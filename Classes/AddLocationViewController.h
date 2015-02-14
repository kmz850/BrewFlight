//
//  AddLocationViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kNumberOfEditableRows    4
#define kNameRowIndex            0
#define kFromYearRowIndex        1
#define kToYearRowIndex          2
#define kPartyIndex              3

#define kLabelTag                4096

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class Location;

@interface AddLocationViewController : UITableViewController <UITextFieldDelegate,CLLocationManagerDelegate> {
    Location *location;
    NSString *locationId;
    NSArray *fieldLabels;
    NSMutableDictionary *tempValues;
    UITextField *textFieldBeingEdited;
    UITextField *firstTextField;
    CLLocationManager *locationManager;
    NSString *latitude;
    NSString *longitude;
}

@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic, retain) UITextField *firstTextField;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;


@end
