//
//  LocationViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationViewController.h"
//#import "SecondLevelViewController.h"
#import "AddLocationViewController.h"
//#import "BeerAppAppDelegate.h"
#import "DeleteMeController.h"
#import "BeerViewController.h"
#import "Beer.h"
#import "Location.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"


//@implementation UINavigationBar (UINavigationBarCategory)

//- (void)drawRect:(CGRect)rect {
//    UIImage *img = [UIImage imageNamed:@"navbar.png"];
//    [img drawInRect:rect];
//}
//@end
@implementation LocationViewController

@synthesize locations;
@synthesize locationsSearch;
@synthesize locationIcons;
@synthesize tmpBeerControllers;
@synthesize locationManager;
@synthesize latitude;
@synthesize longitude;
@synthesize webserver;
@synthesize tableView;
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize autocompleteTableView;
@synthesize autocompleteLocations;
@synthesize emailButton;
@synthesize refreshControl;
@synthesize imageView;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

/*
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Fire a notification to let all views know that our app entered foreground.
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification//@"EnteredForeground"
                                                        object:nil];
}
*/
-(IBAction)composeEmail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:brewquestapp@gmail.com?subject=BrewQuest%20App%20Question/Comment"]];
}



#pragma mark - View lifecycle

-(IBAction)toggleAdd:(id)sender {
    AddLocationViewController *childController = [[AddLocationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    childController.title = @"Add Location";
    
       
    [self.navigationController pushViewController:childController animated:YES];
    [childController release];

}

- (void) viewWillAppear:(BOOL)animated {
    
   
 //   [tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
    //°
    self.longitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
    
    
    
    //NSLog(@"Longitude: %@", longitude);
    //NSLog(@"Latitude: %@", latitude);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    //webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
    
    //NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"findBeer.php"]];

    NSURL *fourSquareURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&limit=30&categoryId=4d4b7105d754a06374d81259,4d4b7105d754a06376d81259,4bf58dd8d48988d118951735&oauth_token=WW4ZXZTAVWSIKPDR0MFKJKUQCJMUTW1WH3YOMPB1KW2OHAWB&v=20120421", latitude,longitude]];
   
    
    //NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"findBeer.php"]];
    
    //ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:fourSquareURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:fourSquareURL];
    
    request.userInfo = [NSDictionary dictionaryWithObject:@"getVenues" forKey:@"type"];
    
    //[request setPostValue:self.latitude forKey:@"latitude"];
    //[request setPostValue:self.longitude forKey:@"longitude"];
    
    [request setDelegate:self];
    [request startAsynchronous];    
    [self.locationManager stopUpdatingLocation];

    [properties release];

 }

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getVenues"]) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
    
        NSData *response = [request responseData];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
        NSLog(@"json_string = %@", json_string);
        NSDictionary *location = [parser objectWithString:json_string error:nil];
    
        NSString *tmpVenues = [[[NSString alloc] init] autorelease];
        tmpBeerControllers = [[NSMutableDictionary alloc] init];
        [json_string release];
        [parser release];
    
        NSArray *listOfVenues = [location valueForKey:@"response"];
        
        
        NSDictionary *venues = [listOfVenues valueForKey:@"venues"];
        NSString *pathOfVenues = [[NSBundle mainBundle] pathForResource:@"FilteredVenues" ofType:@"plist"];
        NSDictionary *filteredVenuesDict = [[NSDictionary alloc] initWithContentsOfFile:pathOfVenues];
        
        // Cycle through each Venue
        for (id object in venues ) {
            
            bool isValidVenue = true;
            NSDictionary *categories = [object valueForKey:@"categories"];
            NSArray *categoryID = [categories valueForKey:@"id"];
            NSArray *iconID = [categories valueForKey:@"icon"];
            NSString *catID = [categoryID objectAtIndex:0];
            NSArray *iconURL = [iconID valueForKey:@"prefix"];
            NSString *iconURLPrefix = [iconURL objectAtIndex:0];
            iconURLPrefix = [iconURLPrefix stringByAppendingString:@"64.png"];
            
            if ([filteredVenuesDict objectForKey:catID] != nil)
                isValidVenue = false;

            if (isValidVenue)
            {
                NSDictionary *locationDetails = [object valueForKey:@"location"];
                
                BeerViewController *beerMeController = 
                [[BeerViewController alloc] initWithNibName:@"BeerViewController" bundle:nil]; 
                // initWithStyle:UITableViewStyleGrouped];
        
                beerMeController.title = [object valueForKey:@"name"];
                
                beerMeController.detailTitle = [locationDetails valueForKey:@"address"];
                beerMeController.locationId = [object valueForKey:@"id"];
        
                tmpVenues = [tmpVenues stringByAppendingString:[beerMeController.locationId stringByAppendingString:@","]];
            
                NSURL *imageURL = [NSURL URLWithString:iconURLPrefix];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *image = [UIImage imageWithData:imageData];
                
                /*
                Location *locationTmp = [[Location alloc] init];
                locationTmp.icon = image;
                [locationIcons addObject:locationTmp];
                */
                
                beerMeController.rowImage = image;
                [tmpBeerControllers setObject:beerMeController forKey:[object valueForKey:@"id"]];
                
                // Code to create Venue Icon Image
                
                [beerMeController release];
             }
        }
    
        if ( [tmpVenues length] > 0)
            tmpVenues = [tmpVenues substringToIndex:[tmpVenues length] - 1];
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];

        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"findBeerByID.php"]];
        ASIHTTPRequest *nextRequest = [ASIFormDataRequest requestWithURL:url];
        nextRequest.delegate = self;
        nextRequest.userInfo = [NSDictionary dictionaryWithObject:@"getBeers" forKey:@"type"];
        [nextRequest setPostValue:tmpVenues forKey:@"venueIDs"];
        [nextRequest startAsynchronous];
        [properties release];
        [filteredVenuesDict release];

    }
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getBeers"]) {
        [self getBeersFromVenueKeys:request];
    }
    
    // Occurs when user selects Venue location from searchDisplayController's tableView
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getBeersFromLookup"]) {
        [self getBeersFromVenueKeys:request];
        
        // Should only be one location object, so it's safe to reference the first one
        BeerViewController *nextController = [self.locationsSearch objectAtIndex:0];
        //SecondLevelViewController *nextController = [self.locationsSearch
         //                                            objectAtIndex:0];
        
        //BeerAppAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [self.navigationController pushViewController:nextController animated:YES];
    }
    // Occurs when user searches for string in Location search bar
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getVenuesLookup"]) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSData *response = [request responseData];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        //NSLog(@"json_string = %@", json_string);
        NSDictionary *location = [parser objectWithString:json_string error:nil];
        
        NSString *tmpVenues = [[[NSString alloc] init] autorelease];
        tmpBeerControllers = [[NSMutableDictionary alloc] init];
        [json_string release];
        [parser release];
        
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
            
            if ([filteredVenuesDict objectForKey:catID] != nil)
                isValidVenue = false;
            
            if (isValidVenue)
            {
                NSDictionary *locationDetails = [object valueForKey:@"location"];
                NSMutableArray *locationDetailsTmp = [[NSMutableArray alloc] init];
                
                [locationDetailsTmp addObject:[object valueForKey:@"name"]];
                if ([locationDetails valueForKey:@"address"] == nil)
                    [locationDetailsTmp addObject:@""];
                else
                    [locationDetailsTmp addObject:[locationDetails valueForKey:@"address"]];
                [autocompleteLocations setValue:locationDetailsTmp forKey:[object valueForKey:@"id"]];
                

                [locationDetailsTmp release];
            }
        }
        
        [searchDisplayController.searchResultsTableView reloadData];
    }

        
    
    /*
    for (id object in location) {
        
        BeerViewController *beerMeController = 
        [[BeerViewController alloc] initWithStyle:UITableViewStylePlain];
        
        beerMeController.title = [object valueForKey:@"name"];
        
        if ([beerMeController.title isEqualToString:@"Fermentation Lounge"])
            beerMeController.rowImage = [UIImage imageNamed:@"fermentation.jpg"];
        else if ([beerMeController.title isEqualToString:@"Leon Pub"])
            beerMeController.rowImage = [UIImage imageNamed:@"leon.jpg"]; 
        else
            beerMeController.rowImage = [UIImage imageNamed:@"proof.jpg"];
        
        beerMeController.detailTitle = [object valueForKey:@"address"];
        
        NSDictionary *beerDetails = [object valueForKey:@"beers"];
        NSMutableArray *beers = [[NSMutableArray alloc] init];
        
        for (id beerNames in beerDetails) {
            Beer *beer = [[Beer alloc] init];
            
            beer.locationId = [object valueForKey:@"locationId"];
            beer.beerId = [beerNames valueForKey:@"beerId"];
            beer.name = [beerNames valueForKey:@"name"];
            beer.brewery = [beerNames valueForKey:@"brewery"];
            beer.style = [beerNames valueForKey:@"style"];
            beer.abv = [beerNames valueForKey:@"abv"];
            beer.addedDt = [beerNames valueForKey:@"addedDt"];
            
            NSString *imagePath = [beerNames objectForKey:@"image"];
            
            // if ([beerNames valueForKey:@"image"] != (id)[NSNull null] || [[beerNames valueForKey:@"image"] length] != 0)
            //if ([imagePath length] > 0)
            if ((NSNull *)imagePath != [NSNull null])
            {
                NSString *filePath = [NSString stringWithFormat:@"%@",[webserver stringByAppendingString:[beerNames valueForKey:@"image"]]];
                //NSLog(@"filePath: %@", filePath);
                beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            }
            else
                beer.image = [UIImage imageNamed:@"leon.jpg"];
            
            
            [beers addObject:beer];
            [beer release];
            
        }
        
        beerMeController.beers = beers;
        beerMeController.locationId = [object valueForKey:@"locationId"];
        
        [beers release];
        [array addObject:beerMeController];
        [beerMeController release];
    }
    
    self.locations = array;
    [array release];
    //[webserver release];
    [self.tableView reloadData];
    [self.locationManager stopUpdatingLocation];
     */
    
}   

- (void)enteredForeground:(id)object {
    // Reload the tableview
    [self.locationManager startUpdatingLocation];

    [self.tableView reloadData];
}

- (void)viewDidLoad
{
   
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [super viewDidLoad];
    self.autocompleteLocations = [[NSMutableDictionary alloc] init];
     //UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
    //                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd                    target:self
        //                          action:@selector(toggleAdd:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    
    /*
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 400.0, 44.0)];
    navLabel.font = [UIFont fontWithName:@"Zapfino" size:22];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navLabel.textAlignment = UITextAlignmentCenter;
    navLabel.text = @"Locations";
    self.navigationItem.titleView = navLabel;
    */ 
    self.navigationItem.title = @"Locations";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:84.0/255.0f green:84.0/255.0f blue:84.0/255.0f alpha:1.0f];
    //[navLabel sizeToFit];
      //[addButton release];
    //[navLabel release];
    searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    [searchBar sizeToFit];
    searchBar.delegate = self;
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsTableView.delegate = self;
    searchDisplayController.searchResultsTableView.dataSource = self;
    searchBar.placeholder = @"Search Locations";
    
    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    [searchDisplayController setSearchResultsDelegate:self];
    //self.tableView.tableHeaderView = searchBar;
    [self.view addSubview:searchBar];
    
    
    autocompleteTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 143, 320, 150) style:UITableViewStylePlain];
    
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;
    [self.view addSubview:autocompleteTableView];
    
    searchDisplayController.searchResultsTableView.allowsSelectionDuringEditing = YES;
    searchDisplayController.searchResultsTableView.allowsSelection = YES;
    autocompleteTableView.allowsSelectionDuringEditing = YES;
    autocompleteTableView.allowsSelection = YES;
    
       // Do any additional setup after loading the view from its nib.
    
    locationIcons = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification//@"EnteredForeground"
                                               object:nil];
    
    /*
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    */
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
}

-(void)refresh {
    // do something here to refresh.
    [self.locationManager startUpdatingLocation];
}


- (void)viewDidUnload
{
    self.locations = nil;
    //[tableView release];
    //tableView = nil;

    [tableView release];
    tableView = nil;
    emailButton = nil;
    imageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [locations release];
    [tmpBeerControllers release];
    [tableView release];
    [super dealloc];
}


#pragma mark - 
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section{
   // NSLog(@"locations count: %@", [self.locations count]);
    if (tableView != searchDisplayController.searchResultsTableView)
        return [self.locations count];
    else {
        return [autocompleteLocations count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView != searchDisplayController.searchResultsTableView)
    {
    static NSString *RootViewCell = @"Locations";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RootViewCell];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:RootViewCell] autorelease];
    }
    
    // Configure the cell
    NSUInteger row = [indexPath row];
        BeerViewController *controller = [locations objectAtIndex:row];
    //SecondLevelViewController *controller = [locations objectAtIndex:row];
    cell.textLabel.text = controller.title;
    //NSLog(@"title: %@", controller.title);
    cell.detailTextLabel.text = controller.detailTitle;
    cell.imageView.image = controller.rowImage;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
        autocompleteTableView.allowsSelection = YES;
        autocompleteTableView.allowsSelectionDuringEditing = YES;
        
        searchDisplayController.searchResultsTableView.allowsSelectionDuringEditing = YES;
        searchDisplayController.searchResultsTableView.allowsSelection = YES;
        NSArray *locationsTemp = [autocompleteLocations objectForKey:[[autocompleteLocations allKeys] objectAtIndex:indexPath.row]];
        
        cell.textLabel.text = [locationsTemp objectAtIndex:0];
        cell.detailTextLabel.text = [locationsTemp objectAtIndex:1];
        return cell;
    }
    
}

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

- (void)getBeersFromVenueKeys:(ASIHTTPRequest *)request {

    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
    // Use list of IDs and call webservice for beers
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSData *response = [request responseData];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    NSDictionary *location = [parser objectWithString:json_string error:nil];
    
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    //NSMutableArray *listOfVenueIDs = [[NSMutableArray alloc] init];
    
    
    [json_string release];
    [parser release];
    [properties release];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id object in location) {
        
        NSDictionary *beerDetails = [object valueForKey:@"beers"];
        NSDictionary *tap = [beerDetails valueForKey:@"tap"];
        NSDictionary *bottles = [beerDetails valueForKey:@"bottles"];
        
        NSMutableArray *tapBeers = [[NSMutableArray alloc] init];
        NSMutableArray *bottledBeers = [[NSMutableArray alloc] init];
        
        
        for (id beerNames in tap) {
            Beer *beer = [[Beer alloc] init];
            
            beer.locationId = [object valueForKey:@"locationID"];
            beer.beerId = [beerNames valueForKey:@"beerId"];
            //NSLog(@"BeerId: %@", beer.beerId);
            beer.name = [beerNames valueForKey:@"name"];
            beer.brewery = [beerNames valueForKey:@"brewery"];
            beer.style = [beerNames valueForKey:@"style"];
            beer.abv = [beerNames valueForKey:@"abv"];
            beer.addedDt = [beerNames valueForKey:@"addedDt"];
            beer.forEvent = [beerNames valueForKey:@"eventName"];
            NSString *imagePath = [beerNames objectForKey:@"image"];
            NSLog(@"imagePath = %@, for beerId = %@, for beerNames = %@", imagePath, beer.beerId, [beerNames valueForKey:@"image"]);
            
            
            /*
            NSString *filePath = [NSString stringWithFormat:@"%@%@",[webserver stringByAppendingString:beer.beerId],@".jpg"];
            beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            
            if (beer.image == nil)
                beer.image = [UIImage imageNamed:@"leon.jpg"];
            
             */
            
            if ((NSNull *)imagePath != [NSNull null] && imagePath != nil)
            {
                NSString *filePath = [NSString stringWithFormat:@"%@",[webserver stringByAppendingString:[beerNames valueForKey:@"image"]]];
                beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            }
            else
                beer.image = [UIImage imageNamed:@"leon.jpg"];
            
            [tapBeers addObject:beer];
            [beer release];
        }
        
        for (id beerNames in bottles) {
            Beer *beer = [[Beer alloc] init];
            
            beer.locationId = [object valueForKey:@"locationID"];
            beer.beerId = [beerNames valueForKey:@"beerId"];
            beer.name = [beerNames valueForKey:@"name"];
            beer.brewery = [beerNames valueForKey:@"brewery"];
            beer.style = [beerNames valueForKey:@"style"];
            beer.abv = [beerNames valueForKey:@"abv"];
            beer.addedDt = [beerNames valueForKey:@"addedDt"];
            beer.forEvent = [beerNames valueForKey:@"eventName"];
            NSString *imagePath = [beerNames objectForKey:@"image"];
            
            /*
            NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
            NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
            
            NSString *webserver = [properties objectForKey:@"connection_string"];
            
            NSString *filePath = [NSString stringWithFormat:@"%@%@",[webserver stringByAppendingString:beer.beerId],@".jpg"];
            beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            
            if (beer.image == nil)
                beer.image = [UIImage imageNamed:@"leon.jpg"];
            */
            
            
            if ((NSNull *)imagePath != [NSNull null] && imagePath != nil)
            {
                NSString *filePath = [NSString stringWithFormat:@"%@",[webserver stringByAppendingString:[beerNames valueForKey:@"image"]]];
                beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            }
            else
                beer.image = [UIImage imageNamed:@"leon.jpg"];
            
            
            [bottledBeers addObject:beer];
            [beer release];
        }
        
        
        
        BeerViewController *tmpBeerMeController;
        
        // If this comes from user search, then no beerControllers have been setup.. why bother
        // pulling back all that data when they're just going to select only one
        if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getBeersFromLookup"])
            tmpBeerMeController = [[BeerViewController alloc] init];
        
        else
            tmpBeerMeController = [tmpBeerControllers objectForKey:[object valueForKey:@"locationID"]];
        
        
        NSMutableDictionary *beerDictTmp = [[NSMutableDictionary alloc] init];
        
        [beerDictTmp setObject:tapBeers forKey:@"tap"];
        [beerDictTmp setObject:bottledBeers forKey:@"bottles"];
        
        // Add beers
        tmpBeerMeController.beers = tapBeers;
        //NSLog(@"beerDictTmp: %@", [beerDictTmp valueForKey:@"tap"]);
        tmpBeerMeController.beerDict = beerDictTmp;
        tmpBeerMeController.locationId = [object valueForKey:@"locationID"];
        
        [array addObject:tmpBeerMeController];
        [tapBeers release];
        [bottledBeers release];
        [beerDictTmp release];
        
    }
    
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getBeersFromLookup"])
        self.locationsSearch = array;
    else 
        self.locations = array;
    
    [array release];
    
    // Remove title image once table loads
    [imageView removeFromSuperview];
    [self.tableView reloadData];
    [self.locationManager stopUpdatingLocation];
    [self.refreshControl endRefreshing];

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
    [self.locationManager stopUpdatingLocation];
    
    [properties release];
}
    
#pragma mark -
#pragma mark Table View Delegate Methods
/*- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView != searchDisplayController.searchResultsTableView)
    {
        NSUInteger row = [indexPath row];
        BeerViewController *nextController = [self.locations
                                                     objectAtIndex:row];
        //SecondLevelViewController *nextController = [self.locations
         //                                        objectAtIndex:row];
        
        //BeerAppAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [self.navigationController pushViewController:nextController animated:YES];
    }
    else if (tableView == searchDisplayController.searchResultsTableView)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"findBeerByID.php"]];
        ASIHTTPRequest *nextRequest = [ASIFormDataRequest requestWithURL:url];
        nextRequest.delegate = self;
        nextRequest.userInfo = [NSMutableDictionary dictionaryWithObject:@"getBeersFromLookup" forKey:@"type"];
        //[nextRequest.userInfo setValue:indexPath forKey:@"indexPath"];
        [nextRequest setPostValue:[[autocompleteLocations allKeys] objectAtIndex:indexPath.row] forKey:@"venueIDs"];
        
        [nextRequest startAsynchronous];
        [properties release];
        
    }
}



@end
