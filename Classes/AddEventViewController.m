//
//  AddEventViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 12/8/12.
//
//
#import <QuartzCore/QuartzCore.h>
#import "AddEventViewController.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@interface AddEventViewController ()

@end

@implementation AddEventViewController
@synthesize mapView;
@synthesize name;
@synthesize address;
@synthesize date;
@synthesize locationId;
@synthesize delegate;
@synthesize location;


-(IBAction)save:(id)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString *webserver = [properties objectForKey:@"connection_string"];
    //NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"createEvent.php"]];
    NSURL *url = [NSURL URLWithString:webserver];
    
    //NSString *url2 = [webserver stringByAppendingString:@"createEvent.php"];
     
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *stringFromSystemDate = [formatter stringFromDate:[NSDate date]];
    NSString *tmpDate = [[NSString alloc] init];
    
    if ([date.text isEqualToString:@"Current Date"])
        tmpDate= stringFromSystemDate;
    else
        tmpDate = date.text;
    
   
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                     name.text, @"name",
                                     location.locationId, @"address",
                                     tmpDate, @"date",
                                     nil];

    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                 path:@"/createEvent.php"
                                           parameters:parameters];
    
    BOOL *addEvent = FALSE;
   
    
    [httpClient postPath:@"/createEvent.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSDictionary* jsonFromData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        // REFACTOR: Probably need to fix this in the future. Webservice returns a string, not JSON
        // Couldn't quite get the JSON to return correctly.
        NSString *eventIdTmp = [[NSString alloc] init];
        eventIdTmp = operation.responseString;
      
        
        Event *eventTmp = [[Event alloc] init];
        eventTmp.eventId = eventIdTmp;
        eventTmp.name = name.text;
        eventTmp.locationId = location.locationId;//address.text;
        eventTmp.date = tmpDate;
        NSString *fullAddress = [NSString stringWithFormat:@"%@ %@ %@ %@", location.address, location.city, location.state, location.zip];
        
        eventTmp.fullAddress = fullAddress;
        eventTmp.fourSquareName = location.name;
        eventTmp.fourSquareIcon = location.icon;
        
        [self.delegate didAddEvent:eventTmp];
    
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"failure = %@", error);
    }];
    
    
   
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

-(IBAction)cancel:(id)sender {
    
    int count = [self.navigationController.viewControllers count];
    NSLog(@"COUNT = %d", [self.navigationController.viewControllers count]);
    NSLog(@"View controller = %@", [self.navigationController.viewControllers objectAtIndex:count-1]);
    NSLog(@"View controller = %@", [self.navigationController.viewControllers objectAtIndex:count-2]);
    NSLog(@"View controller = %@", [self.navigationController.viewControllers objectAtIndex:count-3]);
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count-3]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)datePickerDoneClicked:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *stringFromPickerDate = [formatter stringFromDate:tapDatePicker.date];
    NSString *stringFromSystemDate = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    if ([stringFromPickerDate isEqualToString:stringFromSystemDate])
    {
        date.textColor = [UIColor blueColor];
        date.text = @"Current Date";
    }
    else
    {
        date.textColor = [UIColor blackColor];
        date.text =  stringFromPickerDate;
    }
    
    [date resignFirstResponder];
}

-(IBAction)datePickerCancelClicked:(id)sender
{
    [date resignFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // **************** Construct Date Picker ****************
    
    self.title = @"Add Event";
    tapDatePicker = [[UIDatePicker alloc] init];
    tapDatePicker.datePickerMode = UIDatePickerModeDate;

    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone target:self
                                                                   action:@selector(datePickerDoneClicked:)] autorelease];
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                      style:UIBarButtonSystemItemCancel target:self
                                                                     action:@selector(datePickerCancelClicked:)] autorelease];
    
    
    UIToolbar *datePickerToolBar = [[UIToolbar alloc] init];
    datePickerToolBar.barStyle = UIBarStyleDefault;
    [datePickerToolBar sizeToFit];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [datePickerToolBar setItems:[NSArray arrayWithObjects:cancelButton, flexibleSpace, doneButton, nil]];
    [flexibleSpace release];
    
    date.inputView = tapDatePicker;
    date.inputAccessoryView = datePickerToolBar;
    
    date.text = @"Current Date";
    date.textColor = [UIColor blueColor];
    
    //NSLog(@"AddEvent location = %@", locationId);
    //address.text = location.locationId;
    address.text = location.name;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:location.address completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark* aPlacemark in placemarks)
        {
            annotation.coordinate = aPlacemark.location.coordinate;
            
            
            MKCoordinateRegion region =  MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500);
            
            //MKCoordinateSpan span;
            
            //span.latitudeDelta = mapView.region.span.latitudeDelta * 2;
            //span.longitudeDelta = mapView.region.span.longitudeDelta * 2;
            //region.span = span;
            
            [mapView setRegion:region];
            
            mapView.layer.masksToBounds = YES;
            //mapView.layer.cornerRadius = 15.0;
            mapView.mapType = MKMapTypeStandard;
            
            [mapView setScrollEnabled:NO];
            
            // add a pin using self as the object implementing the MKAnnotation protocol
            [mapView addAnnotation:annotation];
            
        }
    }];
    

    
	// ******************************************************
}

// Dismiss keyboard when tapping away from textfield
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [[self view] endEditing:TRUE];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [mapView release];
    [name release];
    [address release];
    [date release];
    [super dealloc];
}
- (void)viewDidUnload {
    mapView = nil;
    [super viewDidUnload];
}
@end
