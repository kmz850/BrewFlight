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


@implementation BeerViewController
@synthesize locationId;
@synthesize beers;

- (void)dealloc
{
    [beers release];
    [super dealloc];
    
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
-(IBAction)toggleAdd:(id)sender {

    AddBeerViewController *childController = [[AddBeerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    childController.title = @"Add Beer";
    //childController.beer = currentBeer;
    //Beer *currentBeer = [self.beers objectAtIndex:0];
    
    NSMutableArray *tempBeerIDs = [[NSMutableArray alloc] init];
    
    for (Beer *currentBeer in beers)
    {
        [tempBeerIDs addObject:currentBeer.beerId];
    }
    
    childController.locationBeerIDs = tempBeerIDs;
    childController.locationId = locationId;
    [tempBeerIDs release];
    [self.navigationController pushViewController:childController animated:YES];
    //[childController release]; //ZOMBIE!!!
    
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
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"Presidents" 
    //                                                 ofType:@"plist"];
    
    //NSData *data;
    //NSKeyedUnarchiver *unarchiver;
    
    //data = [[NSData alloc] initWithContentsOfFile:path];
    //unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemEdit                    target:self
                                    action:@selector(toggleEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];

    
    //[unarchiver finishDecoding];
    //[unarchiver release];
    //[data release];
    
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section{
    return [beers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *PresidentListCellIdentifier = @"PresidentListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PresidentListCellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PresidentListCellIdentifier] autorelease];
    }
    
    NSUInteger row = [indexPath row];
    Beer *currentBeer = [self.beers objectAtIndex:row];

    NSLog(@"currentBeer.name = %@", currentBeer.name);
    cell.textLabel.text = currentBeer.name;
    cell.detailTextLabel.text = @"Added Dt: ";
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:currentBeer.addedDt];
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:@", "];
    cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:currentBeer.brewery];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
    
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
  
    Beer *currentBeer = [self.beers objectAtIndex:row];
    
    BeerDetailController *childController = [[BeerDetailController alloc] initWithStyle:UITableViewStyleGrouped];
    
    childController.title = currentBeer.name;
    childController.beer = currentBeer;

    [self.navigationController pushViewController:childController animated:YES];
    [childController release];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        NSString *webserver = [properties objectForKey:@"connection_string"];
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"removeBeer.php"]];

        Beer *currentBeer = [self.beers objectAtIndex:row];
        
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setPostValue:currentBeer.locationId forKey:@"locationId"];
        [request setPostValue:currentBeer.beerId forKey:@"beerId"];
        [request setDelegate:self];
        [request startAsynchronous];

        
        [self.beers removeObjectAtIndex:row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
       
        [properties release];

        
    }
}



@end
