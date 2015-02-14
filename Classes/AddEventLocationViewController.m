//
//  AddEventLocationViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 1/3/13.
//
//

#import "AddEventLocationViewController.h"
#import "AFJSONRequestOperation.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Location.h"
#import "Event.h"
#import "JSON.h"

@interface AddEventLocationViewController ()

@end

@implementation AddEventLocationViewController
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize tableView;
@synthesize arrayOfLocations;
@synthesize locationId;
@synthesize delegate;
@synthesize selectedLocation;
@synthesize autocompleteTableView;
@synthesize autocompleteLocations;


- (BOOL)searchBar:(UISearchBar *)textField
shouldChangeTextInRange:(NSRange)range
  replacementText:(NSString *)string
{
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [autocompleteLocations removeAllObjects];
    [self searchAutocompleteEntriesWithSubstring:substring];
    
    return YES;
    
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString *newSubstring = [substring stringByReplacingOccurrencesOfString:@" " withString:@"*"];
    
    NSURL *fourSquareURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&limit=50&query=%@&categoryId=4d4b7105d754a06374d81259,4d4b7105d754a06376d81259,4bf58dd8d48988d118951735&oauth_token=WW4ZXZTAVWSIKPDR0MFKJKUQCJMUTW1WH3YOMPB1KW2OHAWB&v=20120421", latitude,longitude,newSubstring]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:fourSquareURL];
    
    request.userInfo = [NSDictionary dictionaryWithObject:@"getVenuesLookup" forKey:@"type"];
    
    [request setDelegate:self];
    [request startAsynchronous];
    [locationManager stopUpdatingLocation];
    
    //[properties release];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"AddEventLocationSegue"]){
        
        [locationManager stopUpdatingLocation];
        
        AddEventViewController *aevc = (AddEventViewController *)[segue destinationViewController];
        aevc.locationId = self.locationId;
        aevc.delegate = self;
        aevc.location = self.selectedLocation;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Occurs when user searches for string in Location search bar
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getVenuesLookup"]) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSData *response = [request responseData];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        //NSLog(@"json_string = %@", json_string);
        NSDictionary *location = [parser objectWithString:json_string error:nil];
        
        NSString *tmpVenues = [[[NSString alloc] init] autorelease];
        
        NSArray *listOfVenues = [location valueForKey:@"response"];
        
        NSDictionary *venues = [listOfVenues valueForKey:@"venues"];
        NSString *pathOfVenues = [[NSBundle mainBundle] pathForResource:@"FilteredVenues" ofType:@"plist"];
        NSDictionary *filteredVenuesDict = [[NSDictionary alloc] initWithContentsOfFile:pathOfVenues];
        
        // Cycle through each Venue
        for (id object in venues ) {
            bool isValidVenue = true;
            
            NSDictionary *categories = [object valueForKey:@"categories"];
            NSArray *categoryID = [categories valueForKey:@"id"];
            NSString *catID = [categoryID objectAtIndex:0];
            
            NSArray *iconID = [categories valueForKey:@"icon"];
            NSArray *iconURL = [iconID valueForKey:@"prefix"];
            NSString *iconURLPrefix = [iconURL objectAtIndex:0];
            iconURLPrefix = [iconURLPrefix stringByAppendingString:@"64.png"];
            
            if ([filteredVenuesDict objectForKey:catID] != nil)
                isValidVenue = false;
            
            if (isValidVenue)
            {
                NSDictionary *locationDetails = [object valueForKey:@"location"];
                //NSMutableArray *locationDetailsTmp = [[NSMutableArray alloc] init];
                
                Location *locationTmp = [[Location alloc] init];
                
                locationTmp.locationId = [object valueForKey:@"id"];
                locationTmp.address = [locationDetails valueForKey:@"address"];
                locationTmp.city = [locationDetails valueForKey:@"city"];
                locationTmp.state = [locationDetails valueForKey:@"state"];
                locationTmp.zip = [locationDetails valueForKey:@"postalCode"];
                
                locationTmp.name = [object valueForKey:@"name"];
                
                NSURL *imageURL = [NSURL URLWithString:iconURLPrefix];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                
                locationTmp.icon = [UIImage imageWithData:imageData];

                [autocompleteLocations addObject:locationTmp];
                
            }
        }
        
        [searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void) didAddEvent:(Event *)event {
    
    [self.delegate didAddEvent:event];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    latitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
    //°
    longitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
    
    
    
    //NSLog(@"Longitude: %@", longitude);
    //NSLog(@"Latitude: %@", latitude);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    //webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
    
    //NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"findBeer.php"]];
    NSURL *fourSquareURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&limit=50&categoryId=4d4b7105d754a06374d81259,4d4b7105d754a06376d81259,4bf58dd8d48988d118951735&oauth_token=WW4ZXZTAVWSIKPDR0MFKJKUQCJMUTW1WH3YOMPB1KW2OHAWB&v=20120421", latitude,longitude]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:fourSquareURL];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    
       // NSLog(@"JSON = %@", JSON);
        
        NSDictionary *JSONresponse = [JSON valueForKey:@"response"];
        
        NSDictionary *venues = [JSONresponse valueForKey:@"venues"];
        NSString *pathOfVenues = [[NSBundle mainBundle] pathForResource:@"FilteredVenues" ofType:@"plist"];
        NSDictionary *filteredVenuesDict = [[NSDictionary alloc] initWithContentsOfFile:pathOfVenues];
        
        // Cycle through each Venue
        for (id object in venues ) {
            
            bool isValidVenue = true;
            NSDictionary *categories = [object valueForKey:@"categories"];
            NSArray *categoryID = [categories valueForKey:@"id"];
            NSString *catID = [categoryID objectAtIndex:0];
            
            
            NSArray *iconID = [categories valueForKey:@"icon"];
            NSArray *iconURL = [iconID valueForKey:@"prefix"];
            NSString *iconURLPrefix = [iconURL objectAtIndex:0];
            iconURLPrefix = [iconURLPrefix stringByAppendingString:@"64.png"];

            
            if ([filteredVenuesDict objectForKey:catID] != nil)
                isValidVenue = false;
            
            if (isValidVenue)
            {
                NSDictionary *locationDetails = [object valueForKey:@"location"];
                
                Location *location = [[Location alloc] init];
                
                                
                location.name = [object valueForKey:@"name"];
                location.address = [locationDetails valueForKey:@"address"];
               
                location.city = [locationDetails valueForKey:@"city"];
                location.state = [locationDetails valueForKey:@"state"];
                location.zip = [locationDetails valueForKey:@"postalCode"];
                
               
                //NSLog(@"Address = %@", location.address);
                location.locationId = [object valueForKey:@"id"];
                
                NSURL *imageURL = [NSURL URLWithString:iconURLPrefix];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *image = [UIImage imageWithData:imageData];
                location.icon = image;
               
                [arrayOfLocations addObject:location];
                
            }
        }
        
        [tableView reloadData];
        [locationManager stopUpdatingLocation];
        
    } failure:nil];
    [operation start];
    
    [locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [super viewDidLoad];
    self.autocompleteLocations = [[NSMutableArray alloc] init];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsTableView.delegate = self;
    searchDisplayController.searchResultsTableView.dataSource = self;
    searchBar.placeholder = @"Search Locations";

    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    [searchDisplayController setSearchResultsDelegate:self];
    searchDisplayController.searchResultsTableView.allowsSelectionDuringEditing = YES;
    
   // autocompleteTableView = [[UITableView alloc] init];
    
    //autocompleteTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 143, 320, 150) style:UITableViewStylePlain];
    
   // autocompleteTableView.delegate = self;
  //  autocompleteTableView.dataSource = self;
   // autocompleteTableView.scrollEnabled = YES;
   // autocompleteTableView.hidden = YES;

    searchDisplayController.searchResultsTableView.allowsSelection = YES;

    arrayOfLocations = [[NSMutableArray alloc] init];
    locationId = [[NSString alloc] init];
    selectedLocation = [[Location alloc] init];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != searchDisplayController.searchResultsTableView)
        return [arrayOfLocations count];
    else
        return [autocompleteLocations count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if (tableView != searchDisplayController.searchResultsTableView)
    {

    selectedLocation = [arrayOfLocations objectAtIndex:row];
    locationId = selectedLocation.locationId;
    
    NSLog(@"locationId = %@", locationId);
    }
    else if (tableView == searchDisplayController.searchResultsTableView)
    {
        [locationManager stopUpdatingLocation];
        Location *locationTmp = [autocompleteLocations objectAtIndex:indexPath.row];
        
        selectedLocation = locationTmp;
        locationId = selectedLocation.locationId;

    }
    
    [self performSegueWithIdentifier:@"AddEventLocationSegue" sender:self];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView != searchDisplayController.searchResultsTableView)
    {
        
    static NSString *EventCellIdentifier = @"PresidentCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EventCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    

    Location *locationTmp = [arrayOfLocations objectAtIndex:row];
  
    cell.textLabel.text = locationTmp.name;
    cell.detailTextLabel.text = locationTmp.address;
    //cell.imageView.image = controller.rowImage;
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = locationTmp.icon;
    
    return cell;
    }
    
    else if (tableView == searchDisplayController.searchResultsTableView)
    {
        NSUInteger row = [indexPath row];
        
        UITableViewCell *cell = nil;
        static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AutoCompleteRowIdentifier] autorelease];
        }
       // autocompleteTableView.allowsSelection = YES;
        //autocompleteTableView.allowsSelectionDuringEditing = YES;
        
        searchDisplayController.searchResultsTableView.allowsSelectionDuringEditing = YES;
        searchDisplayController.searchResultsTableView.allowsSelection = YES;
        Location *locationTmp = [autocompleteLocations objectAtIndex:indexPath.row];
        
        cell.textLabel.text = locationTmp.name;
        cell.detailTextLabel.text = locationTmp.address;
        return cell;
    }


    
}

// To avoid a zombie when calling searchDisplay controller then popToRootViewController
- (void)dealloc {
    
    self.searchDisplayController.delegate = nil;
    self.searchDisplayController.searchResultsDelegate = nil;
    self.searchDisplayController.searchResultsDataSource = nil;
    
}

- (void)viewDidUnload {
    
    searchDisplayController = nil;
    searchBar = nil;
    tableView = nil;
    
    latitude = nil;
    longitude = nil;
    locationManager = nil;
    autocompleteTableView = nil;
    arrayOfLocations = nil;
    locationId = nil;
    selectedLocation = nil;
    autocompleteLocations = nil;
    
    
        
    [super viewDidUnload];
}
@end
