//
//  PresidentsViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BeerViewController.h"
#import "BeerDetailController.h"
#import "AddBeerViewController.h"
#import "President.h"
#import "BeerAppAppDelegate.h"
#import "Beer.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"


@implementation BeerViewController
@synthesize rowImage;
@synthesize detailTitle;
@synthesize locationId;
@synthesize beers;
@synthesize beerDict;
@synthesize tableView;
@synthesize segmentedControl;
@synthesize upcomingBeers;
@synthesize webserver;

- (void)dealloc
{
    [beers release];
    [tableView release];
    [segmentedControl release];
    [super dealloc];
    
}

- (void) didEditBeer:(NSString *)beerId {
    NSString *editBeerId = [beerId stringValue];
    NSLog(@"Delegate called");
    // Update beerchanged flag
    

    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString *webserver = [properties objectForKey:@"connection_string"];
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@.jpg", webserver, beerId];
    
    //currentBeer.image  = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
    
    Beer *currentBeer = [[[Beer alloc] init] autorelease];
    NSMutableArray *currentTap = [beerDict objectForKey:@"tap"];
    NSMutableArray *currentBottles = [beerDict objectForKey:@"bottles"];
    NSMutableArray *upcomingTap = [upcomingBeers objectForKey:@"tap"];
    NSMutableArray *upcomingBottles = [upcomingBeers objectForKey:@"bottles"];
    
    
    //Cycle through each array, updating each beer in the array
    for (Beer *beerTmp in currentTap) {
        NSString *beerIDtmp = [beerTmp.beerId stringValue];

        if ([beerIDtmp isEqualToString:editBeerId])
            beerTmp.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
    }
    for (Beer *beerTmp in currentBottles) {
        NSString *beerIDtmp = [beerTmp.beerId stringValue];

        
        if ([beerIDtmp isEqualToString:editBeerId])
            beerTmp.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            
    }
    for (Beer *beerTmp in upcomingTap) {
        NSString *beerIDtmp = [beerTmp.beerId stringValue];

        
        if ([beerIDtmp isEqualToString:editBeerId])
            beerTmp.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
    }
    for (Beer *beerTmp in upcomingBottles) {
        NSString *beerIDtmp = [beerTmp.beerId stringValue];
        
        if ([beerIDtmp isEqualToString:editBeerId])
            beerTmp.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
    }
    
    [beerDict setObject:currentTap forKey:@"tap"];
    [beerDict setObject:currentBottles forKey:@"bottles"];
    [upcomingBeers setObject:upcomingTap forKey:@"tap"];
    [upcomingBeers setObject:upcomingBottles forKey:@"bottles"];
    
    // Reload tableview
    [tableView reloadData];
   
}

- (void)didTouchSegmentedControl:(id)sender
{
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        [self.tableView reloadData];
        // Load tableView with dictionary data
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        NSLog(@"Upcoming");
        // Flag if has been run before
   
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"findUpcomingBeerByID.php"]];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setPostValue:self.locationId forKey:@"locationId"];
        request.userInfo = [NSDictionary dictionaryWithObject:@"getUpcomingBeers" forKey:@"type"];
        [request setDelegate:self];
        [request startAsynchronous];

        }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"getUpcomingBeers"]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        // Use list of IDs and call webservice for beers
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSData *response = [request responseData];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        NSDictionary *beersReturned = [parser objectWithString:json_string error:nil];
        // NSLog(@"json_string %@", json_string);
        [json_string release];
        [parser release];
        [properties release];
       
        NSDictionary *beerDetails = [beersReturned valueForKey:@"beers"];
        NSDictionary *tap = [beerDetails valueForKey:@"tap"];
        NSDictionary *bottles = [beerDetails valueForKey:@"bottles"];
            
        NSMutableArray *tapBeers = [[NSMutableArray alloc] init];
        NSMutableArray *bottledBeers = [[NSMutableArray alloc] init];
            
            
            for (id beerNames in tap) {
                Beer *beer = [[Beer alloc] init];
                
                beer.beerId = [beerNames valueForKey:@"beerId"];
                //NSLog(@"beerId = %@", beer.beerId);
                beer.name = [beerNames valueForKey:@"name"];
                beer.brewery = [beerNames valueForKey:@"brewery"];
                beer.style = [beerNames valueForKey:@"style"];
                beer.abv = [beerNames valueForKey:@"abv"];
                beer.addedDt = [beerNames valueForKey:@"addedDt"];
                beer.forEvent = [beerNames valueForKey:@"eventName"];
                NSString *imagePath = [beerNames objectForKey:@"image"];
                
                // Set Beer Image
                // REFACTOR - Basically we're going straight to the server and setting our beer.image
                // to the image on the server. If it doesn't exist we slap the default image on it.
                
                NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
                NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
                
                NSString *webserver = [properties objectForKey:@"connection_string"];
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
                    NSLog(@"filePath = %@", filePath);
                }
                else
                    beer.image = [UIImage imageNamed:@"leon.jpg"];
                
                
                [tapBeers addObject:beer];
                [beer release];
            }
            
            for (id beerNames in bottles) {
                Beer *beer = [[Beer alloc] init];
                
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
                
                
                [bottledBeers addObject:beer];
                [beer release];
            }
            
            
            upcomingBeers = [[NSMutableDictionary alloc] init];
            
            [upcomingBeers setObject:tapBeers forKey:@"tap"];
            [upcomingBeers setObject:bottledBeers forKey:@"bottles"];
        
        //NSLog(@"Upcoming beers %@", upcomingBeers);
       
        [self.tableView reloadData];
    }    
    
    //NSArray *allControllers = self.navigationController.viewControllers;
    //UITableViewController *parent = [allControllers lastObject];
    [self.tableView setEditing:NO animated:YES];
    
    //[parent.tableView reloadData];
    
        [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(IBAction)toggleDone:(id)sender {
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit                    target:self
                                   action:@selector(toggleEdit:)];

    
   [self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.rightBarButtonItem = editButton;
    
}
/*
- (void)didAddBeer:(Beer *)beer onTap:(NSString *)onTap {
    
    NSMutableArray *arrayOfBeersTmp = [[NSMutableArray alloc] init];
    
    if (onTap == @"Y")
    {
        arrayOfBeersTmp = [event.dictOfBeers objectForKey:@"tap"];
        [arrayOfBeersTmp addObject:beer];
        [event.dictOfBeers setObject:arrayOfBeersTmp forKey:@"tap"];
    }
    else
    {
        arrayOfBeersTmp = [event.dictOfBeers objectForKey:@"bottle"];
        [arrayOfBeersTmp addObject:beer];
        [event.dictOfBeers setObject:arrayOfBeersTmp forKey:@"bottle"];
    }
    
    [tableView reloadData];
}
 */

-(IBAction)toggleAdd:(id)sender {

    AddBeerViewController *childController = [[AddBeerViewController alloc] initWithStyle:UITableViewStyleGrouped];
   
    childController.title = @"Add Beer";
    //childController.beer = currentBeer;
    //Beer *currentBeer = [self.beers objectAtIndex:0];
    
    NSMutableArray *tempBeerIDs = [[NSMutableArray alloc] init];
    
    
    for (Beer *currentBeer in [beerDict objectForKey:@"tap"] )
    {
        NSLog(@"beerId = %@", currentBeer.beerId);
        [tempBeerIDs addObject:currentBeer.beerId];
    }
    for (Beer *currentBeer in [beerDict objectForKey:@"bottles"] )
    {
        NSLog(@"beerId = %@", currentBeer.beerId);
        
        [tempBeerIDs addObject:currentBeer.beerId];
    }
    for (Beer *currentBeer in [upcomingBeers objectForKey:@"tap"] )
    {
        NSLog(@"beerId = %@", currentBeer.beerId);
        
        [tempBeerIDs addObject:currentBeer.beerId];
    }
    for (Beer *currentBeer in [upcomingBeers objectForKey:@"bottles"] )
    {
        NSLog(@"beerId = %@", currentBeer.beerId);
        
        [tempBeerIDs addObject:currentBeer.beerId];
    }
    
    childController.locationBeerIDs = tempBeerIDs;
    childController.locationId = locationId;
    //childController.beers = self.beers;
    childController.upcomingBeers = self.upcomingBeers;
    childController.currentBeers = self.beerDict;
    [tempBeerIDs release];
    
    [self.navigationController pushViewController:childController animated:YES];
    [childController release]; //ZOMBIE!!!
        //[super viewDidLoad];
    NSArray *allControllers = self.navigationController.viewControllers;
    //UITableViewController *parent = [allControllers lastObject];
    //[self.tableView setEditing:NO animated:YES];

    //[parent.tableView reloadData];
    [self.tableView reloadData];
}

-(IBAction)toggleEdit:(id)sender {
   
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd                    target:self
                                  action:@selector(toggleAdd:)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone                    target:self
                                   action:@selector(toggleDone:)];
    
    if (self.tableView.editing)
    {
        self.navigationItem.rightBarButtonItem = addButton;
        self.navigationItem.leftBarButtonItem = doneButton;
        self.navigationItem.hidesBackButton = YES;
    }
    
    [addButton release];
    [doneButton release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemEdit                    target:self
                                    action:@selector(toggleEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [segmentedControl addTarget:self
                         action:@selector(didTouchSegmentedControl:)
               forControlEvents:UIControlEventValueChanged];
    
     NSLog(@"Current Tap bottles: %@", [beerDict objectForKey:@"bottles"]);

    /*
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Current",@"Upcoming",nil]];
    segmentedControl.frame = CGRectMake(50,0,220,50);
    segmentedControl.bounds = CGRectMake(50,0,220,50);
    [self.view addSubview:segmentedControl];
    
    self.tableView.frame = CGRectMake(0,50,220,320);*/
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section{
    
   if (segmentedControl.selectedSegmentIndex == 0)
    {
        if (section == 0)
        {
            NSLog(@"Current Tap Count: %i", [[beerDict objectForKey:@"tap"] count]);
            return ([[beerDict objectForKey:@"tap"] count]);
        }
        else
        {
            NSLog(@"Current Bottle Count: %i", [[beerDict objectForKey:@"bottles"] count]);
            return ([[beerDict objectForKey:@"bottles"] count]);
        }
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        if (section == 0)
        {
            NSLog(@"Upcoming Tap Count: %i", [[upcomingBeers objectForKey:@"tap"] count]);
            return ([[upcomingBeers objectForKey:@"tap"] count]);
        }
        else
        {
            NSLog(@"Upcoming Bottle Count: %i", [[upcomingBeers objectForKey:@"bottles"] count]);
            return ([[upcomingBeers objectForKey:@"bottles"] count]);
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        return [beerDict count];
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        return [upcomingBeers count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = [[[NSString alloc] init] autorelease];
    
    if (section == 0)
       sectionTitle = @"On Tap";
    else
       sectionTitle = @"Bottles";
    
    return sectionTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
       
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SectionsTableIdentifier] autorelease];
    }

   // NSString *key = [[NSString alloc] init];
   // NSArray *nameSection = [[NSArray alloc] init];
    
    // Getting crashes here if not set to autorelease,
    // need to research why

    Beer *currentBeer = [[[Beer alloc] init] autorelease]; 
    //currentBeer = [[beerDict objectForKey:@"tap"] objectAtIndex:row];
    //NSLog(@"currentBeer.name = %@", currentBeer.name);
    
   
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        //NSLog(@"Array: %@", [beerDict objectForKey:@"tap"]);
        if (section == 0)
           currentBeer = [[beerDict objectForKey:@"tap"] objectAtIndex:row];
        else if (section == 1)
            currentBeer = [[beerDict objectForKey:@"bottles"] objectAtIndex:row];
        
        //nameSection = [beerDict objectForKey:key];
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        if (section == 0)
            currentBeer = [[upcomingBeers objectForKey:@"tap"] objectAtIndex:row];
        else if (section == 1)
            currentBeer = [[upcomingBeers objectForKey:@"bottles"] objectAtIndex:row];

        
        //key = [[upcomingBeers allKeys] objectAtIndex:section];
        //nameSection = [upcomingBeers objectForKey:key];
    }
    
    NSLog(@"currentBeer.name: %@", currentBeer.name);
    NSLog(@"currentBeer.event: %@", currentBeer.forEvent);
        
     //[nameSection objectAtIndex:row];

    //NSLog(@"locationId = %@", self.locationId);
    //NSLog(@"currentBeer.name = %@", currentBeer.name);
    
    cell.textLabel.text = currentBeer.name;
    cell.imageView.image = currentBeer.image;
    
    //cell.detailTextLabel.text = @"Added Dt: ";
    //cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:currentBeer.addedDt];
    //cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:@", "];
    //cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:currentBeer.brewery];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    if (currentBeer.forEvent == nil)
        currentBeer.forEvent = @" ";
    else if (currentBeer.forEvent == [NSNull null])
        currentBeer.forEvent = @" ";
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\r%@", currentBeer.brewery, currentBeer.forEvent];// currentBeer.brewery;
    
   
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //[currentBeer release];
    //[key release];
    //[nameSection release];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}


#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    // ADD LOGIC TO CHOOSE BETWEEN CURRENT AND UPCOMING
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    
    NSString *key = [[NSString alloc] init];
    NSArray *nameSection = [[NSArray alloc] init];
    
    
    //NSString *key = [[beerDict allKeys] objectAtIndex:section];
    //NSArray *nameSection = [beerDict objectForKey:key];
    
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        key = [[beerDict allKeys] objectAtIndex:section];
        nameSection = [beerDict objectForKey:key];
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        key = [[upcomingBeers allKeys] objectAtIndex:section];
        nameSection = [upcomingBeers objectForKey:key];
    }
    
    Beer *currentBeer = [nameSection objectAtIndex:row];
    
    //BeerDetailController *childController = [[BeerDetailController alloc] initWithStyle:UITableViewStyleGrouped];
    
    BeerDetailController *childController = [[BeerDetailController alloc] init];
    childController.title = currentBeer.name;
    childController.beer = currentBeer;
    childController.beerImage = currentBeer.image;
    childController.delegate = self;

    [self.navigationController pushViewController:childController animated:YES];
    NSLog(@"Back from BeerDetail!");
    [childController release];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
   
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        webserver = [[NSString alloc] initWithString:[properties objectForKey:@"connection_string"]];
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"removeBeer.php"]];

        
        NSString *key = [[NSString alloc] init];
        NSArray *nameSection = [[NSArray alloc] init];
        NSMutableArray *tmpBeers = [[NSMutableArray alloc] init];
        
        if (segmentedControl.selectedSegmentIndex == 0)
        {
            key = [[beerDict allKeys] objectAtIndex:section];
            nameSection = [beerDict objectForKey:key];
            tmpBeers = [beerDict objectForKey:key];
        }
        else if (segmentedControl.selectedSegmentIndex == 1)
        {
            key = [[upcomingBeers allKeys] objectAtIndex:section];
            nameSection = [upcomingBeers objectForKey:key];
            tmpBeers = [upcomingBeers objectForKey:key];
        }

        Beer *currentBeer = [nameSection objectAtIndex:row];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setPostValue:self.locationId forKey:@"locationId"];
        [request setPostValue:currentBeer.beerId forKey:@"beerId"];
        [request setDelegate:self];
        [request startAsynchronous];

        [tmpBeers removeObjectAtIndex:row];
        
               
       
    
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        if (segmentedControl.selectedSegmentIndex == 0)
            [beerDict setObject:tmpBeers forKey:key];
        else if (segmentedControl.selectedSegmentIndex == 1)
            [upcomingBeers removeObjectForKey:key];

           
        }

}



- (void)viewDidUnload {
    [tableView release];
    tableView = nil;
    //[segmentedControl release];
    //segmentedControl = nil;
    [super viewDidUnload];
}
@end
