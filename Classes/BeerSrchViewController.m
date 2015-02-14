//
//  BeerSrchViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BeerSrchViewController.h"
#import "Beer.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Location.h"
#import "BeerDetailController.h"
#import "LocationSrchViewController.h"
//@interface BeerSrchViewController ()



@implementation BeerSrchViewController

@synthesize latitude;
@synthesize longitude;
@synthesize webserver;
@synthesize filteredBeers;
@synthesize nameToId;
@synthesize beerDetails;
@synthesize beerLocations;
@synthesize locationAddress;
@synthesize locationNames;
@synthesize locationIcons;
@synthesize locationManager;
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize tableView;
@synthesize refreshControl;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    beerDetails = [[NSMutableDictionary alloc] init];
    beerLocations = [[NSMutableDictionary alloc] init];
    
    locationAddress = [[NSMutableDictionary alloc] init];
    locationNames = [[NSMutableDictionary alloc] init];
    locationIcons = [[NSMutableDictionary alloc] init];
    
    filteredBeers = [[NSMutableArray alloc] init];
    nameToId = [[NSMutableDictionary alloc] init];
    
    self.navigationItem.title = @"Beers";

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    

    searchBar.delegate = self;
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsTableView.delegate = self;
    searchDisplayController.searchResultsTableView.dataSource = self;
    searchBar.placeholder = @"Search Beers";
    
    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    [searchDisplayController setSearchResultsDelegate:self];

    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    

    // Do any additional setup after loading the view from its nib.
}

-(void)refresh {
    // do something here to refresh.
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
    //°
    self.longitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    
    NSURL *fourSquareURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&limit=50&categoryId=4d4b7105d754a06374d81259,4d4b7105d754a06376d81259,4bf58dd8d48988d118951735&oauth_token=WW4ZXZTAVWSIKPDR0MFKJKUQCJMUTW1WH3YOMPB1KW2OHAWB&v=20120421", latitude,longitude]];
        
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:fourSquareURL];
    
    request.userInfo = [NSDictionary dictionaryWithObject:@"getVenues" forKey:@"type"];
    
    [request setDelegate:self];
    [request startAsynchronous];    
    [self.locationManager stopUpdatingLocation];
    
    [properties release];
}

/*
- (BOOL)searchBar:(UISearchBar *)textField 
shouldChangeTextInRange:(NSRange)range 
  replacementText:(NSString *)string
{
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    //[autocompleteLocations removeAllObjects];
    [self searchAutocompleteEntriesWithSubstring:substring];
    
    return YES;
    
}*/
/*
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSURL *fourSquareURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&limit=50&query=%@&radius=100000&categoryId=4d4b7105d754a06374d81259,4d4b7105d754a06376d81259,4bf58dd8d48988d118951735&oauth_token=WW4ZXZTAVWSIKPDR0MFKJKUQCJMUTW1WH3YOMPB1KW2OHAWB&v=20120421", latitude,longitude,substring]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:fourSquareURL];
    
    request.userInfo = [NSDictionary dictionaryWithObject:@"getVenuesLookup" forKey:@"type"];
    
    [request setDelegate:self];
    [request startAsynchronous];    
    [self.locationManager stopUpdatingLocation];
    
    [properties release];
}*/



- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getVenues"]) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSData *response = [request responseData];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        //NSLog(@"json_string = %@", json_string);
        NSDictionary *location = [parser objectWithString:json_string error:nil];
        
        NSString *tmpVenues = [[[NSString alloc] init] autorelease];
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
            
            NSArray *iconID = [categories valueForKey:@"icon"];
            NSArray *iconURL = [iconID valueForKey:@"prefix"];
            NSString *iconURLPrefix = [iconURL objectAtIndex:0];
            iconURLPrefix = [iconURLPrefix stringByAppendingString:@"64.png"];
            
            
            if ([filteredVenuesDict objectForKey:catID] != nil)
                isValidVenue = false;
            
            if (isValidVenue)
            {
                 NSDictionary *locationDetails = [object valueForKey:@"location"];
                
                if ([[locationDetails valueForKey:@"address"] length] > 0)
                    [locationAddress setObject:[locationDetails valueForKey:@"address"] forKey:[object valueForKey:@"id"]];
                
                if ([[object valueForKey:@"name"] length] > 0)
                    [locationNames setObject:[object valueForKey:@"name"] forKey:[object valueForKey:@"id"]];
                
                
                NSURL *imageURL = [NSURL URLWithString:iconURLPrefix];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *image = [UIImage imageWithData:imageData];

                
                [locationIcons setObject:image forKey:[object valueForKey:@"id"]];
                            

                tmpVenues = [tmpVenues stringByAppendingString:[[object valueForKey:@"id"] stringByAppendingString:@","]];
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
}

- (void)getBeersFromVenueKeys:(ASIHTTPRequest *)request {
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSData *response = [request responseData];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    //NSLog(@"json_string2 = %@", json_string);
    
    NSDictionary *location = [parser objectWithString:json_string error:nil];
    
    [json_string release];
    [parser release];
    [properties release];
    
    
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id object in location) {
        
        NSDictionary *beerDetailsTmp = [object valueForKey:@"beers"];
        NSDictionary *tap = [beerDetailsTmp valueForKey:@"tap"];
        NSDictionary *bottles = [beerDetailsTmp valueForKey:@"bottles"];
        
        for (id beerNames in tap) {
            Beer *beer = [[Beer alloc] init];
            
            beer.locationId = [object valueForKey:@"locationID"];
            beer.beerId = [beerNames valueForKey:@"beerId"];
            beer.name = [beerNames valueForKey:@"name"];
            beer.brewery = [beerNames valueForKey:@"brewery"];
            beer.style = [beerNames valueForKey:@"style"];
            beer.abv = [beerNames valueForKey:@"abv"];
            beer.addedDt = [beerNames valueForKey:@"addedDt"];
            
            NSString *imagePath = [beerNames objectForKey:@"image"];
            
            // Set Beer Image
            // REFACTOR - Basically we're going straight to the server and setting our beer.image
            // to the image on the server. If it doesn't exist we slap the default image on it.
            
            /*
            NSString *filePath = [NSString stringWithFormat:@"%@%@",[webserver stringByAppendingString:beer.beerId],@".jpg"];
            beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            
            if (beer.image == nil)
                beer.image = [UIImage imageNamed:@"leon.jpg"];
            
            */
            if ((NSNull *)imagePath != [NSNull null])
            {
                NSString *filePath = [NSString stringWithFormat:@"%@",[webserver stringByAppendingString:[beerNames valueForKey:@"image"]]];
                beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            }
            else
                beer.image = [UIImage imageNamed:@"leon.jpg"];
             
            
            
            NSMutableDictionary *locationDetailsTmp = [beerLocations objectForKey:beer.beerId];
            
            Location *locationDetailsObject = [[Location alloc] init];
            
            locationDetailsObject.locationId = beer.locationId;
            locationDetailsObject.name = [locationNames valueForKey:locationDetailsObject.locationId];
            locationDetailsObject.address = [locationAddress valueForKey:locationDetailsObject.locationId];
            locationDetailsObject.icon = [locationIcons valueForKey:locationDetailsObject.locationId];
            
            
            if (locationDetailsTmp == nil)
               locationDetailsTmp = [[NSMutableDictionary alloc] init];
            
            if ([locationDetailsTmp objectForKey:beer.locationId] == nil)
                [locationDetailsTmp setObject:locationDetailsObject forKey:beer.locationId];
            
            [beerLocations setObject:locationDetailsTmp forKey:beer.beerId];
            [beerDetails setObject:beer forKey:beer.beerId];
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
            
            NSString *imagePath = [beerNames objectForKey:@"image"];
            
            if ((NSNull *)imagePath != [NSNull null])
            {
                NSString *filePath = [NSString stringWithFormat:@"%@",[webserver stringByAppendingString:[beerNames valueForKey:@"image"]]];
                beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            }
            else
                beer.image = [UIImage imageNamed:@"leon.jpg"];
            
            
            NSMutableDictionary *locationDetailsTmp = [beerLocations objectForKey:beer.beerId];
            Location *locationDetailsObject = [[Location alloc] init];
            
            locationDetailsObject.locationId = beer.locationId;
            locationDetailsObject.name = [locationNames valueForKey:locationDetailsObject.locationId];
            locationDetailsObject.address = [locationAddress valueForKey:locationDetailsObject.locationId];
            locationDetailsObject.icon = [locationIcons valueForKey:locationDetailsObject.locationId];

            if (locationDetailsTmp == nil)
                locationDetailsTmp = [[NSMutableDictionary alloc] init];
            
            if ([locationDetailsTmp objectForKey:beer.locationId] == nil)
                [locationDetailsTmp setObject:locationDetailsObject forKey:beer.locationId];
            
            [beerLocations setObject:locationDetailsTmp forKey:beer.beerId];
           
            [beerDetails setObject:beer forKey:beer.beerId];
            [beer release];
        }
        
                
        /*BeerViewController *tmpBeerMeController;
        
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
    */
       // NSLog(@"BeerDetails = %@", beerDetails);

        [self.tableView reloadData];
        [self.locationManager stopUpdatingLocation];
        [refreshControl endRefreshing];
        
    } //end of for loop
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    if (tableView != self.searchDisplayController.searchResultsTableView)
        return [beerDetails count];
    else 
        return [filteredBeers count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView != self.searchDisplayController.searchResultsTableView)
    {
        

    static NSString *RootViewCell = @"Beers";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RootViewCell];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:RootViewCell] autorelease];
    }

    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    NSUInteger row = [indexPath row];
    // Configure the cell
    
    Beer *beerTmp = [beerDetails objectForKey:[[beerDetails allKeys] objectAtIndex:row]];
    
    cell.textLabel.text = beerTmp.name;
    cell.detailTextLabel.text = beerTmp.brewery;
    cell.imageView.image = beerTmp.image;
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    }
    
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        static NSString *RootViewCell = @"Beers";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RootViewCell];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:RootViewCell] autorelease];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        NSUInteger row = [indexPath row];
        // Configure the cell
        
        Beer *beerTmp = [filteredBeers objectAtIndex:row];
        
        cell.textLabel.text = beerTmp.name;//[filteredBeers objectAtIndex:row];//.name;
        cell.detailTextLabel.text = beerTmp.brewery;
        cell.imageView.image = beerTmp.image;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;

    }


}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    BeerDetailController *beerDetailViewController = [[BeerDetailController alloc] init];
    if (tableView != searchDisplayController.searchResultsTableView)
    {
        Beer *beerTmp = [beerDetails objectForKey:[[beerDetails allKeys] objectAtIndex:row]];
        beerDetailViewController.beer = beerTmp;
        beerDetailViewController.beerImage = beerTmp.image;
        
        [self.navigationController pushViewController:beerDetailViewController animated:YES];
    }
    else if (tableView == searchDisplayController.searchResultsTableView)
    {
        Beer *beerTmp = [filteredBeers objectAtIndex:row];
        beerDetailViewController.beer = beerTmp;
        beerDetailViewController.beerImage = beerTmp.image;
        
        [self.navigationController pushViewController:beerDetailViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    NSMutableDictionary *locationsDict;
    
    if (tableView != searchDisplayController.searchResultsTableView)
    {
       locationsDict = [beerLocations objectForKey:[[beerDetails allKeys] objectAtIndex:row]];
    }
    else if (tableView == searchDisplayController.searchResultsTableView)
    {
        Beer *beerTmp = [filteredBeers objectAtIndex:row];
        
        locationsDict = [beerLocations objectForKey:beerTmp.beerId];
    }
    
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
   // NSLog(@"LocationsDict = %@", locationsDict);

    for (id location in locationsDict)
    {
        [locations addObject:[locationsDict objectForKey:location]];
        
    
    }
    
    //NSLog(@"LocationsName = %@", locations);
    
    LocationSrchViewController *locationSrchViewController = [[LocationSrchViewController alloc] init];

    locationSrchViewController.locations = locations;

    [self.navigationController pushViewController:locationSrchViewController animated:YES];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [filteredBeers removeAllObjects];
    
    if([searchText length] > 0) {
        [self searchTableView];
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void) searchTableView {
    
    NSString *searchText = self.searchDisplayController.searchBar.text;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    
    for (id beers in beerDetails)
    {
        Beer *beerTmp = [beerDetails objectForKey:beers];
        
        // Room for bugs here, we're taking a non-key field "name" and making it a key
        [nameToId setObject:beerTmp.beerId forKey:beerTmp.name];
        [searchArray addObject:beerTmp.name];
    }

    //NSLog(@"SearchArray = %@", searchArray);
    //[searchArray addObjectsFromArray:[beerLocations allKeys]];
    
    
    for (NSString *sTemp in searchArray)
    {
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0) {
            //if ([beerDetails objectForKey:sTemp] != nil)
                [filteredBeers addObject:[beerDetails objectForKey:[nameToId objectForKey:sTemp]]];
        }
    }
    
    //NSLog(@"FilteredBeers = %@", filteredBeers);
    
    searchArray = nil;
}


@end
