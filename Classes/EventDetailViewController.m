//
//  EventDetailViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 10/28/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "EventDetailViewController.h"
#import "BeerDetailController.h"
#import "AddBeerViewController.h"
#import "Beer.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "CameraViewController.h"

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController
@synthesize event;
@synthesize tableView;
@synthesize webserver;
@synthesize mapView;
@synthesize foursquareLocImg;
@synthesize lblLocation;
@synthesize lblAddress;
@synthesize lblDate;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"AddEventBeerSegue"]){
        
        AddBeerViewController *abvc = (AddBeerViewController *)[segue destinationViewController];
        abvc.isEvent = YES;
        abvc.locationId = event.locationId;
        abvc.eventId = event.eventId;
        abvc.eventDate = event.date;
        // Removed because using protocols to talk between viewControllers. Uncommenting this will result
        // in duplicate beers in tableview.
        //abvc.currentBeers = self.event.dictOfBeers;
        abvc.delegate = self;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"removeBeer.php"]];
        
        //NSMutableDictionary *dictOfBeersTmp = event.dictOfBeers;
        NSMutableArray *arrayOfBeersTmp = [[NSMutableArray alloc] init];
        Beer *currentBeer = [[Beer alloc] init];
        
        if (section == 0)
        {
            arrayOfBeersTmp = [event.dictOfBeers objectForKey:@"tap"];
            currentBeer = [arrayOfBeersTmp objectAtIndex:row];
            [arrayOfBeersTmp removeObjectAtIndex:row];
            [event.dictOfBeers setObject:arrayOfBeersTmp forKey:@"tap"];

        }
        else if (section == 1)
        {
            arrayOfBeersTmp = [event.dictOfBeers objectForKey:@"bottle"];
            currentBeer = [arrayOfBeersTmp objectAtIndex:row];
            [arrayOfBeersTmp removeObjectAtIndex:row];
            [event.dictOfBeers setObject:arrayOfBeersTmp forKey:@"bottle"];


        }
       
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setPostValue:event.locationId forKey:@"locationId"];
        [request setPostValue:currentBeer.beerId forKey:@"beerId"];
        [request setDelegate:self];
        [request startAsynchronous];
        
        [event.arrayOfBeers removeObjectAtIndex:row];
        [tableView reloadData];
    }
}

- (void)didAddBeer:(Beer *)beer onTap:(NSString *)onTap {
    
    NSMutableArray *arrayOfBeersTmp = [[NSMutableArray alloc] init];
    
   if (onTap == @"Y")
   {
       arrayOfBeersTmp = [event.dictOfBeers objectForKey:@"tap"];
       
       // REFACTOR -- is this local scope? May cause issues
       if (event.dictOfBeers == nil)
           event.dictOfBeers = [[NSMutableDictionary alloc] init];
       
       if (arrayOfBeersTmp == nil)
           arrayOfBeersTmp = [[NSMutableArray alloc] init];
       
       [arrayOfBeersTmp addObject:beer];
       
       [event.dictOfBeers setObject:arrayOfBeersTmp forKey:@"tap"];
   }
   else
   {
       arrayOfBeersTmp = [event.dictOfBeers objectForKey:@"bottle"];
       
       // REFACTOR -- is this local scope? May cause issues
       if (event.dictOfBeers == nil)
           event.dictOfBeers = [[NSMutableDictionary alloc] init];
       
       if (arrayOfBeersTmp == nil)
           arrayOfBeersTmp = [[NSMutableArray alloc] init];
       
       [arrayOfBeersTmp addObject:beer];
      
       [event.dictOfBeers setObject:arrayOfBeersTmp forKey:@"bottle"];
   }
    
    [tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = [[[NSString alloc] init] autorelease];
    
    if (section == 0)
        sectionTitle = @"On Tap";
    else
        sectionTitle = @"Bottles";
    
    return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0)
        return [[event.dictOfBeers objectForKey:@"tap"] count];
    
    else
        return [[event.dictOfBeers objectForKey:@"bottle"] count];

    //return [event.arrayOfBeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *EventCellIdentifier = @"PresidentCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EventCellIdentifier] autorelease];
    }
    
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    //Event *eventTmp = [eventDict objectForKey:[[eventDict allKeys] objectAtIndex:row]];
    
    NSArray *arrayOfBeersTmp = [[NSArray alloc] init];
    
    if (section == 0)
        arrayOfBeersTmp = [event.dictOfBeers objectForKey:@"tap"];
    else
        arrayOfBeersTmp= [event.dictOfBeers objectForKey:@"bottle"];
    
    //NSArray *arrayOfBeersTmp = [event.dictOfBeers allValues];//event.arrayOfBeers;
    Beer *beerTmp = [arrayOfBeersTmp objectAtIndex:row];
    //NSLog(@"beerTmp = %@", beerTmp.name);
    
    
    cell.textLabel.text = beerTmp.name;
    cell.detailTextLabel.text = beerTmp.brewery;
    cell.imageView.image = beerTmp.image;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeerDetailController *btc = [[BeerDetailController alloc] init];
    
    NSArray *arrayOfBeersTmp = [[NSArray alloc] init];
    NSUInteger section = [indexPath section];

    if (section == 0)
        arrayOfBeersTmp = [event.dictOfBeers objectForKey:@"tap"];
    else
        arrayOfBeersTmp= [event.dictOfBeers objectForKey:@"bottle"];
    
    btc.beer = [arrayOfBeersTmp objectAtIndex:[indexPath row]];
    btc.beerImage = btc.beer.image;
    //btc.beer = [event.arrayOfBeers objectAtIndex:[indexPath row]];
    btc.title = btc.beer.name;
    
    [self.navigationController pushViewController:btc animated:YES];
}


- (IBAction) handleSingleTapOnHeader: (UIGestureRecognizer *) sender {
    
    //if (editMode)
   // {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        NSString *webserver = [properties objectForKey:@"connection_string"];
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@_event_lg.jpg", webserver, event.eventId];
        
       // self.eventImageLg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
        
        CameraViewController *cwc = [[CameraViewController alloc] init];
        //cwc.image = self.beerImage;
        //cwc.imageLg = self.beerImageLg;
        [self.navigationController pushViewController:cwc animated:YES];
        //self.editImage = TRUE;
        
        //beerView.image = self.beerImage;
        [properties release];
        [cwc release];
        //[self updateDisplay];
    //}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    foursquareLocImg.image = event.fourSquareIcon;
    lblLocation.text = event.fourSquareName;
    lblDate.text = event.date;
    lblAddress.text = event.fullAddress;
    
    mapView.layer.cornerRadius = 12.0;
    [mapView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [mapView.layer setBorderWidth: 0.5f];
    
    NSLog(@"event.dictOfBeers = %@", [event.dictOfBeers allValues]);
    //Beer *beerTmp = [event.arrayOfBeers objectAtIndex:0];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnHeader:)];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:event.fullAddress completionHandler:^(NSArray *placemarks, NSError *error) {
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
    
    
    //[imageView addGestureRecognizer:singleTap];
    [self.tableView reloadData];
    //NSLog(@"Beer Name = %@", beerTmp.name);
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    NSLog(@"Beers = %@", event.dictOfBeers);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [tableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    mapView = nil;
    foursquareLocImg = nil;
    lblLocation = nil;
    lblDate = nil;
    lblAddress = nil;
    [super viewDidUnload];
}
@end
