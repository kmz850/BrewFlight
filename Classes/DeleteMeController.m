//
//  DeleteMeController.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DeleteMeController.h"


@implementation DeleteMeController
@synthesize list;
@synthesize beers;

- (IBAction)toggleEdit:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

/*
#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
- (void)dealloc
{
    [list release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    if (list == nil)
    {
       NSString *path = [[NSBundle mainBundle] pathForResource:@"computers" 
                                                     ofType:@"plist"];
       NSMutableArray *array = [[NSMutableArray alloc] 
                             initWithContentsOfFile:path];
       //self.list = array;
        NSLog(@"Beers: %@", beers);
        self.list = beers;
       [array release];
    }
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
                                   initWithTitle:@"Delete"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(toggleEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *DeleteMeCellIdentifier = @"DeleteMeCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             DeleteMeCellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  //initWithFrame:CGRectZero 
                 reuseIdentifier:DeleteMeCellIdentifier] autorelease];
    }
    
    NSInteger row = [indexPath row];
    cell.textLabel.text = [self.list objectAtIndex:row];
    
    return cell;
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    [self.list removeObjectAtIndex:row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
