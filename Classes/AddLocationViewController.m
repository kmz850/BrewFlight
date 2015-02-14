//
//  AddLocationViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddLocationViewController.h"
#import "Location.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@implementation AddLocationViewController
@synthesize location;
@synthesize locationId;
@synthesize fieldLabels;
@synthesize tempValues;
@synthesize textFieldBeingEdited;
@synthesize firstTextField;
@synthesize locationManager;
@synthesize longitude;
@synthesize latitude;


-(IBAction)save:(id)sender
{
    
    if (textFieldBeingEdited != nil)
    {
        NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textFieldBeingEdited.tag];
        [tempValues setObject:textFieldBeingEdited.text forKey:tagAsNum];
        [tagAsNum release];
    }
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString *webserver = [properties objectForKey:@"connection_string"];
    
    NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"createLocation.php"]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    for (NSNumber *key in [tempValues allKeys])
    {
        switch ([key intValue]) {
            case kNameRowIndex:
                [request setPostValue:[tempValues objectForKey:key] forKey:@"name"];
                break;
            case kFromYearRowIndex:
                [request setPostValue:[tempValues objectForKey:key] forKey:@"address"];
                break;
            case kToYearRowIndex:
                [request setPostValue:[tempValues objectForKey:key] forKey:@"city"];
                break;
            case kPartyIndex:
                [request setPostValue:[tempValues objectForKey:key] forKey:@"state"];
            default:
                break;
        }
    }
    
    NSLog(@"Longitude: %@", longitude);
    NSLog(@"Latitude: %@", latitude);

    
    [request setPostValue:latitude forKey:@"latitude"];
    [request setPostValue:longitude forKey:@"longitude"];

    [request setDelegate:self];
    [request startAsynchronous];
    
    if (textFieldBeingEdited != nil)
    {
        [textFieldBeingEdited resignFirstResponder];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [properties release];

}

-(IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(IBAction)textFieldDone:(id)sender
{
    [sender resignFirstResponder];
}

- (void)dealloc
{
    [textFieldBeingEdited release];
    [tempValues release];
    [location release];
    [fieldLabels release];
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSArray *array = [[NSArray alloc] initWithObjects:@"Name", @"Address", @"City", @"State", nil];
    
    self.fieldLabels = array;
    [array release];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Save"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(save:)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel:)];
    
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.hidesBackButton = YES;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    self.tempValues = dict;
    [dict release];
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
    //°
    self.longitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
    
    
    
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfEditableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AddLocationCellIdentifier = @"AddLocationCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddLocationCellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
                                       reuseIdentifier:AddLocationCellIdentifier] autorelease];
        
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10,10,75,25)];
        label.textAlignment = UITextAlignmentRight;
        label.tag = kLabelTag;
        label.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:label];
        [label release];
        
        UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(90,12,200,25)];
        textField.clearsOnBeginEditing = NO;
        [textField setDelegate:self];
        textField.returnKeyType = UIReturnKeyDone;
        [textField addTarget:self 
                      action:@selector(textFieldDone:)
            forControlEvents:UIControlEventEditingDidEndOnExit];
        [cell.contentView addSubview:textField];
        
    }
    
    NSUInteger row = [indexPath row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
    UITextField *textField = nil;
    
    for (UIView *oneView in cell.contentView.subviews)
    {
        if ([oneView isMemberOfClass:[UITextField class]])
            textField = (UITextField *)oneView;
    }
    
    label.text = [fieldLabels objectAtIndex:row];
    
    NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
    
    switch (row) {
        case kNameRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = location.name;
            break;
        case kFromYearRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = location.address;
            break;
        case kToYearRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = location.city;
            break;   
        case kPartyIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = location.state; 
        default:
            break;
    }
    
    if (row == kNameRowIndex)
    {
        firstTextField = textField;
    }
    
    if (textFieldBeingEdited == textField)
        textFieldBeingEdited = nil;
    
    textField.tag = row;
    [rowAsNum release];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
    self.textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
    [tempValues setObject:textField.text forKey:tagAsNum];
    [tagAsNum release];
}



@end
