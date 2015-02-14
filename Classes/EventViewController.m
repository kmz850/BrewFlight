//
//  EventViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "EventDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Event.h"
#import "Beer.h"
#import "AddEventViewController.h"
#import "AddEventLocationViewController.h"

@interface EventViewController ()

@end

@implementation EventViewController
@synthesize latitude;
@synthesize longitude;
@synthesize locationManager;
@synthesize tableView;
@synthesize webserver;
//@synthesize eventDict;
@synthesize eventArray;
@synthesize eventUpcomingArray;
@synthesize selectedEvent;
@synthesize segmentedControl;
@synthesize addressByLocId;
@synthesize refreshControl;
@synthesize foursquareInfoByLocId;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"EventDetailSegue"]){
        
        EventDetailViewController *edvc = (EventDetailViewController *)[segue destinationViewController];
        edvc.event = self.selectedEvent;
        edvc.title = self.selectedEvent.name;
    }
    
    if([[segue identifier] isEqualToString:@"AddEventSegue"]){
        //AddEventViewController *aevc = (AddEventViewController *)[segue destinationViewController];
        //aevc.delegate;
        
        AddEventLocationViewController *aelvc = (AddEventLocationViewController *)[segue destinationViewController];
        aelvc.delegate = self;
        aelvc.title = @"Choose Location";
        
    }
     
}

- (void) didAddEvent:(Event *)event {

    /////
    
    // Compare the event date with the current date to determine Current vs Upcoming
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
    
    // Create a projectedDate two weeks away - keep them on the Current main view
    NSDateComponents *offset = [[[NSDateComponents alloc] init] autorelease];
    [offset setWeek:2];
    NSDate *projectedDate = [[NSCalendar currentCalendar] dateByAddingComponents:offset toDate:currentDate options:0];
    
    NSDate *eventDate = [dateFormatter dateFromString:event.date];

    switch ([eventDate compare:projectedDate]) {
        case NSOrderedSame:
            [eventArray addObject:event];
            break;
        case NSOrderedAscending:
            [eventArray addObject:event];
            break;
        case NSOrderedDescending:
            [eventUpcomingArray addObject:event];
            break;
    }

    
    /////
    
    /* OLD SHIT
    if ([event.date isEqualToString:stringFromSystemDate])
        [eventArray addObject:event];
    else
        [eventUpcomingArray addObject:event];
    */
    [tableView reloadData];
    
}
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/


- (void)didTouchSegmentedControl:(id)sender
{
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.navigationItem.title = @"Events";

    //eventDict = [[NSMutableDictionary alloc] init];
    eventArray = [[NSMutableArray alloc] init];
    eventUpcomingArray = [[NSMutableArray alloc] init];
    selectedEvent = [[Event alloc] init];
    addressByLocId = [[NSMutableDictionary alloc] init];
    foursquareInfoByLocId = [[NSMutableDictionary alloc] init];
    
    [segmentedControl addTarget:self
                         action:@selector(didTouchSegmentedControl:)
               forControlEvents:UIControlEventValueChanged];

    
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

	// Do any additional setup after loading the view.
}

-(void)refresh {
    // do something here to refresh.
    eventArray = [[NSMutableArray alloc] init];
    eventUpcomingArray = [[NSMutableArray alloc] init];
    selectedEvent = [[Event alloc] init];
    addressByLocId = [[NSMutableDictionary alloc] init];
    foursquareInfoByLocId = [[NSMutableDictionary alloc] init];
    tableView = [[UITableView alloc] init];
    
    [self.locationManager startUpdatingLocation];
}


- (void)viewDidUnload
{
    [tableView release];
    tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    
    if (segmentedControl.selectedSegmentIndex == 0)
        return [eventArray count];
    else if (segmentedControl.selectedSegmentIndex == 1)
        return [eventUpcomingArray count];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"removeEvent.php"]];
        
        Event *eventTmp = [[Event alloc] init];
        
        if (segmentedControl.selectedSegmentIndex == 0)
            eventTmp = [eventArray objectAtIndex:row];
        else if (segmentedControl.selectedSegmentIndex == 1)
            eventTmp = [eventUpcomingArray objectAtIndex:row];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setPostValue:eventTmp.eventId forKey:@"eventId"];
        [request setDelegate:self];
        [request startAsynchronous];
      
        if (segmentedControl.selectedSegmentIndex == 0)
            [eventArray removeObjectAtIndex:row];
        else if (segmentedControl.selectedSegmentIndex == 1)
            [eventUpcomingArray removeObjectAtIndex:row];
        
        [tableView reloadData];
        
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *EventCellIdentifier = @"PresidentCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EventCellIdentifier] autorelease];
    }
    
    NSUInteger row = [indexPath row];

    Event *eventTmp = [[Event alloc] init];
    
    if (segmentedControl.selectedSegmentIndex == 0)
        eventTmp = [eventArray objectAtIndex:row];
    else if (segmentedControl.selectedSegmentIndex == 1)
        eventTmp = [eventUpcomingArray objectAtIndex:row];
    
         
    cell.textLabel.text = eventTmp.name;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set formatting equal to what it is in the database, then transform string to date
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:eventTmp.date];
    
    // Next set desired formatting - Jan 01, 2013 ... etc, then transform back into string
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateStr = [dateFormatter stringFromDate:date];

    NSArray *foursquareTmp = [foursquareInfoByLocId objectForKey:eventTmp.locationId];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", eventTmp.fourSquareName, dateStr];
    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
    //°
    self.longitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    
    NSURL *fourSquareURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&limit=50&intent=browse&radius=5000&categoryId=4d4b7105d754a06374d81259,4d4b7105d754a06376d81259,4bf58dd8d48988d118951735&oauth_token=WW4ZXZTAVWSIKPDR0MFKJKUQCJMUTW1WH3YOMPB1KW2OHAWB&v=20120421", latitude,longitude]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:fourSquareURL];
    
    request.userInfo = [NSDictionary dictionaryWithObject:@"getVenues" forKey:@"type"];
    
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
                tmpVenues = [tmpVenues stringByAppendingString:[[object valueForKey:@"id"] stringByAppendingString:@","]];
                
                // Foursquare
                NSArray *location = [[NSArray alloc] init];
                location = [object valueForKey:@"location"];
                NSString *name = [object valueForKey:@"name"];
                NSString *street = [location valueForKey:@"address"];
                NSString *city = [location valueForKey:@"city"];
                NSString *state = [location valueForKey:@"state"];
                NSString *zip = [location valueForKey:@"postalCode"];
                
                NSString *fullAddress = [NSString stringWithFormat:@"%@ %@ %@ %@", street, city, state, zip];
                
                [addressByLocId setObject:fullAddress forKey:[object valueForKey:@"id"]];
                
                NSMutableArray *foursquareArray = [[NSMutableArray alloc] init];
                [foursquareArray addObject:name];
                [foursquareArray addObject:iconURLPrefix];
                [foursquareInfoByLocId setObject:foursquareArray forKey:[object valueForKey:@"id"]];
                
            }
        }
        
        if ( [tmpVenues length] > 0)
            tmpVenues = [tmpVenues substringToIndex:[tmpVenues length] - 1];
        
        NSLog(@"tmpVenues = %@", tmpVenues);
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"findEventsByID.php"]];
        ASIHTTPRequest *nextRequest = [ASIFormDataRequest requestWithURL:url];
        nextRequest.delegate = self;
        nextRequest.userInfo = [NSDictionary dictionaryWithObject:@"getEvents" forKey:@"type"];
        [nextRequest setPostValue:tmpVenues forKey:@"venueIDs"];
        [nextRequest startAsynchronous];
        [properties release];
        [filteredVenuesDict release];
        
    }
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getEvents"]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSData *response = [request responseData];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        NSLog(@"json_string = %@", json_string);
        
        NSDictionary *events = [parser objectWithString:json_string error:nil];
        //NSDictionary *beerDetails = [beersReturned valueForKey:@"beers"];
        
        //NSDictionary *listOfEvents = [events valueForKey:@"events"];
        //NSLog(@"events = %@", events);
        
        [json_string release];
        [parser release];
        [properties release];
          
        for (id event in events)
        {
           // NSLog(@"eventID = %@", [event objectForKey:@"eventId"]);
            Event *eventObject = [[Event alloc] init];
            
            eventObject.eventId = [event objectForKey:@"eventId"];
            eventObject.name = [event objectForKey:@"eventName"];
            eventObject.locationId = [event objectForKey:@"locationId"];
            eventObject.date = [event objectForKey:@"eventDate"];
            eventObject.fullAddress = [addressByLocId objectForKey:eventObject.locationId];
            
            NSArray *beerArrayTmp = [event objectForKey:@"beerList"];
            NSMutableArray *arrayOfTapBeersTmp = [[NSMutableArray alloc] init];
            NSMutableArray *arrayOfBottleBeersTmp = [[NSMutableArray alloc] init];
        
            NSMutableDictionary *dictOfBeersTmp = [[NSMutableDictionary alloc] init];
            for (id beer in beerArrayTmp)
            {
                Beer *beerTmp = [[Beer alloc] init];
                beerTmp.beerId = [beer objectForKey:@"beerId"];
                beerTmp.name = [beer objectForKey:@"name"];
                beerTmp.brewery = [beer objectForKey:@"brewery"];
                beerTmp.style = [beer objectForKey:@"style"];
                beerTmp.abv = [beer objectForKey:@"abv"];
                beerTmp.addedDt = [beer objectForKey:@"addedDt"];
                //beerTmp.image = [beer objectForKey:@"image"];
                
                
                // Set Beer Image
                // REFACTOR - Basically we're going straight to the server and setting our beer.image
                // to the image on the server. If it doesn't exist we slap the default image on it.
                 /*
                
                NSString *filePath = [NSString stringWithFormat:@"%@%@",[webserver stringByAppendingString:beerTmp.beerId],@".jpg"];
                beerTmp.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
                
                if (beerTmp.image == nil)
                    beerTmp.image = [UIImage imageNamed:@"leon.jpg"];
                
                */
                
                NSString *imagePath = [beer objectForKey:@"image"];
                
                if ((NSNull *)imagePath != [NSNull null])
                {
                    NSString *filePath = [NSString stringWithFormat:@"%@",[webserver stringByAppendingString:[beer valueForKey:@"image"]]];
                    
                    NSLog(@"filepath = %@", filePath);
                    
                    beerTmp.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
                }
                else
                    beerTmp.image = [UIImage imageNamed:@"leon.jpg"];

                
                if ([[beer objectForKey:@"onTap"] isEqualToString:@"Y"])
                    [arrayOfTapBeersTmp addObject:beerTmp];
                else
                    [arrayOfBottleBeersTmp addObject:beerTmp];
            }
            
            [dictOfBeersTmp setObject:arrayOfTapBeersTmp forKey:@"tap"];
            [dictOfBeersTmp setObject:arrayOfBottleBeersTmp forKey:@"bottle"];
            
            //[eventDict setValue:eventObject forKey:[event objectForKey:@"eventId"]];
            //eventObject.arrayOfBeers = arrayOfBeersTmp;
            eventObject.dictOfBeers = dictOfBeersTmp;
            
            // NSMutableArray *foursquareArray = [[NSMutableArray alloc] init];
            //[foursquareArray addObject:name];
            //[foursquareArray addObject:iconURLPrefix];
            //[foursquareInfoByLocId setObject:foursquareArray forKey:[object valueForKey:@"id"]];
            
            NSArray *foursquareArrayTmp = [foursquareInfoByLocId objectForKey:eventObject.locationId];
            eventObject.fourSquareName = [foursquareArrayTmp objectAtIndex:0];
            
            NSString * iconURLPrefixTmp = [foursquareArrayTmp objectAtIndex:1];
            eventObject.fourSquareIcon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURLPrefixTmp]]];
           
            // Compare the event date with the current date to determine Current vs Upcoming
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
        
            NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
            NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
            
            // Create a projectedDate two weeks away - keep them on the Current main view
            NSDateComponents *offset = [[[NSDateComponents alloc] init] autorelease];
            [offset setWeek:2];
            NSDate *projectedDate = [[NSCalendar currentCalendar] dateByAddingComponents:offset toDate:currentDate options:0];
            
            NSDate *eventDate = [dateFormatter dateFromString:eventObject.date];
            
            switch ([eventDate compare:projectedDate]) {
                case NSOrderedSame:
                    [eventArray addObject:eventObject];
                    break;
                case NSOrderedAscending:
                    [eventArray addObject:eventObject];
                    break;
                case NSOrderedDescending:
                    [eventUpcomingArray addObject:eventObject];
                    break;
            }
        }
        
        
        [tableView reloadData];
        [refreshControl endRefreshing];
    }


}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (segmentedControl.selectedSegmentIndex == 0)
        selectedEvent = [eventArray objectAtIndex:[indexPath row]];
    else if (segmentedControl.selectedSegmentIndex == 1)
        selectedEvent = [eventUpcomingArray objectAtIndex:[indexPath row]];
    
    [self performSegueWithIdentifier:@"EventDetailSegue" sender:self];
}

- (void)dealloc {
    [tableView release];
    [segmentedControl release];
    [super dealloc];
}
@end
