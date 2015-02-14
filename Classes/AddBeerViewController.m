//
//  AddBeerViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddBeerViewController.h"
#import "BeerViewController.h"
#import "Beer.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"


@implementation AddBeerViewController
@synthesize delegate;
@synthesize beer;
@synthesize beers;
@synthesize locationId;
@synthesize beerId;
@synthesize substringGlobal;
@synthesize fieldLabels;
@synthesize tempValues;
@synthesize textFieldBeingEdited;
@synthesize firstTextField;
@synthesize autocompleteTableView;
@synthesize autocompleteUrls;
@synthesize pastUrls;
@synthesize beerDetails;
@synthesize beerIDs;
@synthesize locationBeerIDs;
@synthesize beerLookup;
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize editingDisabled;
@synthesize brewerySearch;
@synthesize beerServing;
@synthesize tapDatePicker;
@synthesize currentBeers;
@synthesize upcomingBeers;
@synthesize isEvent;
@synthesize eventDate;
@synthesize eventId;

-(IBAction)datePickerDoneClicked:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *stringFromPickerDate = [formatter stringFromDate:tapDatePicker.date];
    NSString *stringFromSystemDate = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    if ([stringFromPickerDate isEqualToString:stringFromSystemDate])
    {
        textFieldBeingEdited.textColor = [UIColor blueColor];
        textFieldBeingEdited.text = @"Current Date";
    }
    else
    {
        textFieldBeingEdited.textColor = [UIColor blackColor];
        textFieldBeingEdited.text =  stringFromPickerDate;
    }
    
    // Make sure we update our global tempValues to include the recent change to Tap Date
    NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textFieldBeingEdited.tag];

    [tempValues setObject:textFieldBeingEdited.text forKey:tagAsNum];
    [tagAsNum release];

    [textFieldBeingEdited resignFirstResponder];
}

-(IBAction)datePickerCancelClicked:(id)sender
{
    [textFieldBeingEdited resignFirstResponder];
}

-(IBAction)save:(id)sender
{
    bool duplicateBeer = false;
    
    if (textFieldBeingEdited != nil)
    {
        NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textFieldBeingEdited.tag];
        [tempValues setObject:textFieldBeingEdited.text forKey:tagAsNum];
        [tagAsNum release];
    }
    
    NSString *currentBeerName = [[tempValues objectForKey:[NSNumber numberWithInt:0]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *currentBreweryName = [[tempValues objectForKey:[NSNumber numberWithInt:1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Check if returned Beer has already been added to this location
    for (NSString *locationBeerID in locationBeerIDs)
    {
        if ([locationBeerID isEqual:self.beerId])
            duplicateBeer = true;
    }
    
    // Is it a dup?
    if (duplicateBeer)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Beer" 
                                                        message:@"Beer has already been added to this location."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    // Is Beer name empty?
    else if ([currentBeerName length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beer Name" 
                                                        message:@"Beer name must be entered"
                                                       delegate:nil
                                                   cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    // Is Brewery empty?
    else if ([currentBreweryName length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Brewery" 
                                                        message:@"Brewery must be entered"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        NSString *webserver = [properties objectForKey:@"connection_string"];
                
        
        NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"createBeer.php"]];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setPostValue:locationId forKey:@"locationId"];
        
        if (beerId != NULL)
        { 
            [request setPostValue:beerId forKey:@"beerId"];
        }
        
    
        //[tempValues setObject:tapDatePicker forKey:[NSNumber numberWithInt:kTapDate]];
        
         // Add beerServing
        [tempValues setObject:beerServing forKey:[NSNumber numberWithInt:kBottleTap]];
        
        //Beer *newBeer = [[Beer alloc] init];
        //newBeer.beerId = beerId;
        
        for (NSNumber *key in [tempValues allKeys])
        {
            switch ([key intValue]) {
                case kNameRowIndex:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"name"];
                    //newBeer.name = [tempValues objectForKey:key];
                    break;
                case kFromYearRowIndex:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"brewery"];
                   // newBeer.brewery = [tempValues objectForKey:key];
                    break;
                case kToYearRowIndex:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"style"];
                    //newBeer.style = [tempValues objectForKey:key];
                    break;
                case kPartyIndex:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"abv"];
                    //newBeer.abv = [tempValues objectForKey:key];
                    break;
                case kTapDate:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"tapDt"];
                    
                    NSLog(@"tap Dt = %@", [tempValues objectForKey:key]);
                    //newBeer.tapDt = [tempValues objectForKey:key];
                    break;
                case kBottleTap:
                    if (beerServing.selectedSegmentIndex == 0)
                      [request setPostValue:@"Y" forKey:@"onTap"];
                    else if (beerServing.selectedSegmentIndex == 1)
                      [request setPostValue:@"N" forKey:@"onTap"];
                default:
                    break;
            }
        }
        if (isEvent)
            [request setPostValue:eventId forKey:@"eventId"];
        
        [request setDelegate:self];
        request.userInfo = [NSDictionary dictionaryWithObject:@"saveBeer" forKey:@"type"];
        
        [request startAsynchronous];
        
        
        if (textFieldBeingEdited != nil)
        {
            [textFieldBeingEdited resignFirstResponder];
        }
        
        [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
        
        //newBeer.addedDt = @"0000-00-00";
        
        //[beers addObject:newBeer];
        //[newBeer release];
        //[properties release];

        
        // popViewController when request is finished
        
        //NSArray *allControllers = self.navigationController.viewControllers;
        //UITableViewController *parent = [allControllers lastObject];
        //[parent.tableView reloadData];
        
        //[self.tableView reloadData];
        
        
    }
   
    
}

-(IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(IBAction)textFieldDone:(id)sender
{
    [sender resignFirstResponder];
    autocompleteTableView.hidden = YES;
}

- (void)dealloc
{
    [textFieldBeingEdited release];
    [tempValues release];
    [beer release];
    [fieldLabels release];
    [locationId release];
    [beerId release];
    [substringGlobal release];
    [firstTextField release];
    [autocompleteTableView release];
    [autocompleteUrls release];
    [pastUrls release];
    [beerDetails release];
    //[beerIDs release];

    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *array = [[NSArray alloc] initWithObjects:@"Name", @"Brewery", @"Style", @"ABV", @"Tap Date", @"", nil];
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
    
    searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 25, self.tableView.frame.size.width, 0)];
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    [searchBar sizeToFit];
    searchBar.delegate = self;
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsTableView.delegate = self;
    searchDisplayController.searchResultsTableView.dataSource = self;
    searchBar.placeholder = @"Beer, Brewery";
   
    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    [searchDisplayController setSearchResultsDelegate:self];
    
    //[searchDisplayController searchResultsTableView]; autocompleteTableView;
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.hidesBackButton = YES;
    self.tableView.tableHeaderView = searchBar;
    //[searchDisplayController setActive:YES animated:YES];
    
    //self.pastUrls = [[NSMutableArray alloc] initWithObjects:@"www.google.com", nil];
    self.autocompleteUrls = [[NSMutableArray alloc] init];
  
    
    autocompleteTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 143, 320, 150) style:UITableViewStylePlain];
    
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;
    [self.view addSubview:autocompleteTableView];
    //[self.view addSubview:searchDisplayController.searchResultsTableView];
     
     
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    self.tempValues = dict;
    [dict release];
    
    self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)] autorelease];
    searchDisplayController.searchResultsTableView.allowsSelectionDuringEditing = YES;
    searchDisplayController.searchResultsTableView.allowsSelection = YES;
    autocompleteTableView.allowsSelectionDuringEditing = YES;
    autocompleteTableView.allowsSelection = YES;
    
    // Add system date for our tap Date in the globals variable
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateAsString = [[NSString alloc] init];
    
    // If beer added to Event, then beer inherits Event's date
    if (isEvent)
        dateAsString = eventDate;
    else
        dateAsString = [formatter stringFromDate:[NSDate date]];
    
    [tempValues setObject:dateAsString forKey:[NSNumber numberWithInt:kTapDate]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [beerLookup release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (tableView != autocompleteTableView)
    if (tableView != searchDisplayController.searchResultsTableView && tableView != autocompleteTableView)
    {
        return kNumberOfAddBeerFields;
    }
    else
        return autocompleteUrls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.allowsSelection = YES;
    tableView.allowsSelectionDuringEditing = YES;
    
    if (tableView != searchDisplayController.searchResultsTableView && tableView != autocompleteTableView)
    {
        static NSString *AddBeerCellIdentifier = @"AddBeerCellIdentifier";
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddBeerCellIdentifier];
    
        
        tableView.allowsSelection = YES;
        tableView.allowsSelectionDuringEditing = YES;
       
        NSUInteger row = [indexPath row];
        
    
        
    if (cell == nil) {
        
       
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
                                       reuseIdentifier:AddBeerCellIdentifier] autorelease];
        
        if (row != kBottleTap)
        {
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10,10,75,25)];
        label.textAlignment = UITextAlignmentRight;
        label.tag = kLabelTag;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
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
    }

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
                textField.text = beer.name;
            break;
        case kFromYearRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = beer.brewery;
            break;
        case kToYearRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = beer.style;
            break;   
        case kPartyIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = beer.abv; 
            break;
        case kTapDate:
            
            //tapDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-5, cell.frame.size.height/2, cell.frame.size.width, cell.frame.size.height)];
            tapDatePicker = [[UIDatePicker alloc] init];
            //tapDatePicker.center = CGPointMake ((self.view.frame.size.width/2)-5, cell.frame.size.height/2);
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
            
            textField.inputView = tapDatePicker;
            textField.inputAccessoryView = datePickerToolBar;
            
            if (isEvent)
            {
                textField.userInteractionEnabled = FALSE;
                textField.textColor = [UIColor lightGrayColor];
                tableView.allowsSelection = FALSE;
                textField.text = eventDate;
                
            }
            else
            {
                textField.text = @"Current Date";
                 textField.textColor = [UIColor blueColor];
            }
            break;
        case kBottleTap: {
            beerServing = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Tap", @"Bottle", nil]];
            beerServing.center = CGPointMake ((self.view.frame.size.width/2)-5, cell.frame.size.height/2);
            beerServing.selectedSegmentIndex = 0;
            
            [cell.contentView addSubview:beerServing];
            break;
        }
        default:
            break;
    }
        
       
        
    if (editingDisabled && row != kTapDate && row != kBottleTap) {
        textField.userInteractionEnabled = FALSE;
        textField.textColor = [UIColor lightGrayColor];
        tableView.allowsSelection = FALSE;
    }

    if (row == kNameRowIndex)
    {
        firstTextField = textField;
    }
    
    if (textFieldBeingEdited == textField)
        textFieldBeingEdited = nil;
    
    textField.tag = row;
    [rowAsNum release];
        searchDisplayController.searchResultsTableView.allowsSelectionDuringEditing = YES;
        searchDisplayController.searchResultsTableView.allowsSelection = YES;
        autocompleteTableView.allowsSelectionDuringEditing = YES;
        autocompleteTableView.allowsSelection = YES;
        
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
                NSLog(@"autocompleteUrls: %@", autocompleteUrls);
        NSArray *beerDetailsTemp = [beerLookup objectForKey:[beerIDs objectAtIndex:row]];
        NSLog(@"beerDetailsTemp: %@", beerDetailsTemp);
 
        cell.textLabel.text = [autocompleteUrls objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [beerDetailsTemp objectAtIndex:1];
        return cell;
    }
    
    else if (tableView == autocompleteTableView)
    {
        UITableViewCell *cell = nil;
        static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] 
                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] autorelease];
        }
        autocompleteTableView.allowsSelection = YES;
        autocompleteTableView.allowsSelectionDuringEditing = YES;

        //searchDisplayController.searchResultsTableView.allowsSelectionDuringEditing = YES;
        //searchDisplayController.searchResultsTableView.allowsSelection = YES;
        cell.textLabel.text = [autocompleteUrls objectAtIndex:indexPath.row];
        brewerySearch = false;
        
        return cell;

    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)textField 
shouldChangeTextInRange:(NSRange)range 
replacementText:(NSString *)string
{
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    
    return YES;

}

- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string {
    
    if (textField.tag == kFromYearRowIndex)
    {
        brewerySearch = TRUE;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]]; 
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
        autocompleteTableView.hidden = NO;
        
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring];
    }
    
    return YES;
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    self.substringGlobal = substring;
        
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString *webserver = [properties objectForKey:@"connection_string"];
   // NSURL *url = [[[NSURL alloc] init] autorelease];
    NSURL *url;
        
    if (brewerySearch)
        url = [NSURL URLWithString:[webserver stringByAppendingString:@"findBreweryLookup.php"]];
    else
        url = [NSURL URLWithString:[webserver stringByAppendingString:@"findBeerLookup.php"]];
    
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:url];
    
    // If nothing is entered, don't bother calling webservice then hide the tableView since
    // the user isn't entering anything.
    if (substring.length != 0)
    {
        [req setPostValue:substring forKey:@"letter"];
        [req setDelegate:self];
        req.userInfo = [NSDictionary dictionaryWithObject:@"autocomplete" forKey:@"type"];
        
        [req startAsynchronous];    
    }
    else
        autocompleteTableView.hidden = YES;
                        
   // [url release];
    [properties release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Only want to catch Autocomplete's request
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"autocomplete"]) {
        
    SBJsonParser *par = [[SBJsonParser alloc] init];
    
    NSData *res = [request responseData];
    
    NSString *json = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
    
    NSLog(@"JSON response: %@", json);
        
    NSDictionary *returnBeers = [par objectWithString:json error:nil];
        
    [json release];
    [par release];
    
    pastUrls = [[NSMutableArray alloc] init];
    beerLookup = [[NSMutableDictionary alloc] init];
    beerIDs = [[NSMutableArray alloc] init];

    NSLog(@"returnBeers: %@", returnBeers);
    
    for (id object in returnBeers) {
        beerDetails = [[NSMutableArray alloc] init];
        
        if ([object valueForKey:@"name"] != nil)
            [beerDetails addObject: [object valueForKey:@"name"]];
        
        if ([object valueForKey:@"brewery"] != nil)
            [beerDetails addObject: [object valueForKey:@"brewery"]];
        
        if ([object valueForKey:@"style"] != nil)
            [beerDetails addObject: [object valueForKey:@"style"]];
        
        if ([object valueForKey:@"abv"] != nil)
            [beerDetails addObject: [object valueForKey:@"abv"]];
        
        if ([object valueForKey:@"name"] != nil)
            [pastUrls addObject: [object valueForKey:@"name"]];
        else 
            [pastUrls addObject: [object valueForKey:@"brewery"]];
        
        if ([object valueForKey:@"beerId"] != nil)
            [beerIDs addObject: [object valueForKey:@"beerId"]];
        
        if ([object valueForKey:@"beerId"] != nil)
            [beerLookup setValue: beerDetails forKey:[object valueForKey:@"beerId"]];
        else
            [beerLookup setValue: beerDetails forKey:[object valueForKey:@"brewery"]];
    }
    
     if ([returnBeers count] == 0)
     {
        [autocompleteUrls removeAllObjects];
        autocompleteTableView.hidden = YES;
     }
        
    [autocompleteUrls removeAllObjects];
    
    //NSLog(@"pastUrls: %@", pastUrls);
    for(NSString *curString in pastUrls) {
        //NSRange substringRange = [curString rangeOfString:self.substringGlobal];
        //if (substringRange.location == 0) {
            [autocompleteUrls addObject:curString];  
        //}
    }
    [autocompleteTableView reloadData];
    [searchDisplayController.searchResultsTableView reloadData];
    }
    else if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"saveBeer"]) 
    {
        SBJsonParser *par = [[SBJsonParser alloc] init];
        
        NSData *res = [request responseData];
        
        NSString *json = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
        NSLog(@"beerDictionaryReturn = %@", json);
        
        NSDictionary *beerDictionaryReturned = [par objectWithString:json error:nil];
        NSLog(@"beerDictionaryReturn = %@", beerDictionaryReturned);
        
        NSString *beerIdReturned = [beerDictionaryReturned valueForKey:@"beerId"];
        NSLog(@"beerIdReturned = %@", beerIdReturned);
        
        Beer *newBeer = [[Beer alloc] init];
        NSString *onTap = [[NSString alloc] init];
        
        newBeer.beerId = [beerIdReturned stringValue];
        
        for (NSNumber *key in [tempValues allKeys])
        {
            switch ([key intValue]) {
                case kNameRowIndex:
                    newBeer.name = [tempValues objectForKey:key];
                    break;
                case kFromYearRowIndex:
                    newBeer.brewery = [tempValues objectForKey:key];
                    break;
                case kToYearRowIndex:
                    newBeer.style = [tempValues objectForKey:key];
                    break;
                case kPartyIndex:
                    newBeer.abv = [tempValues objectForKey:key];
                    break;
                case kTapDate:
                    newBeer.tapDt = [tempValues objectForKey:key];
                    break;
                case kBottleTap:
                    if (beerServing.selectedSegmentIndex == 0)
                        onTap = @"Y";
                       //[request setPostValue:@"Y" forKey:@"onTap"];
                    else if (beerServing.selectedSegmentIndex == 1)
                       //[request setPostValue:@"N" forKey:@"onTap"];
                        onTap = @"N";
                default:
                    break;
            }
        }
        
        // Set Beer Image
        // REFACTOR - Basically we're going straight to the server and setting our beer.image
        // to the image on the server. If it doesn't exist we slap the default image on it.
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
        NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        NSString *webserver = [properties objectForKey:@"connection_string"];
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@",[webserver stringByAppendingString:newBeer.beerId],@".jpg"];
        newBeer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
        
        if (newBeer.image == nil)
             newBeer.image = [UIImage imageNamed:@"leon.jpg"];
            
            /*
        NSString *imagePath = [tempValues objectForKey:@"image"];
        
        if ((NSNull *)imagePath != [NSNull null])
        {
            NSString *filePath = [NSString stringWithFormat:@"%@",[webserver stringByAppendingString:[beerNames valueForKey:@"image"]]];
            beer.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
        }
        else
            beer.image = [UIImage imageNamed:@"leon.jpg"];
         */

        //NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:yourDateHere];
        //NSInteger hour = [dateComponents hour];
        //NSInteger minute = [dateComponents minute];
        //NSInteger second = [dateComponents second];
        //[gregorian release];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
        NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
        
        NSDate *tapDate = [dateFormatter dateFromString:newBeer.tapDt];
       
        //[dateFormatter setDateStyle:NSDate
        NSMutableArray *tmpCurrentTapBeers = [currentBeers objectForKey:@"tap"];
        NSMutableArray *tmpCurrentBottleBeers = [currentBeers objectForKey:@"bottles"];
        NSMutableArray *tmpUpcomingTapBeers = [upcomingBeers objectForKey:@"tap"];
        NSMutableArray *tmpUpcomingBottleBeers = [upcomingBeers objectForKey:@"bottles"];
        
        if (tmpCurrentTapBeers == nil)
            tmpCurrentTapBeers = [[NSMutableArray alloc] init];
        if (tmpCurrentBottleBeers == nil)
            tmpCurrentBottleBeers = [[NSMutableArray alloc] init];
        if (tmpUpcomingTapBeers == nil)
            tmpUpcomingTapBeers = [[NSMutableArray alloc] init];
        if (tmpUpcomingBottleBeers == nil)
            tmpUpcomingBottleBeers = [[NSMutableArray alloc] init];
        
        
        
        switch ([tapDate compare:currentDate]) {
            case NSOrderedSame:
                NSLog(@"Same");
                if (onTap == @"Y") {
                    [tmpCurrentTapBeers addObject:newBeer];
                    [currentBeers setObject:tmpCurrentTapBeers forKey:@"tap"];
                }
                else {
                    [tmpCurrentBottleBeers addObject:newBeer];
                    [currentBeers setObject:tmpCurrentBottleBeers forKey:@"bottles"];
                }
                break;
            case NSOrderedAscending:
                NSLog(@"Ascending");
                if (onTap == @"Y") {
                    [tmpCurrentTapBeers addObject:newBeer];
                    [currentBeers setObject:tmpCurrentTapBeers forKey:@"tap"];
                }
                else {
                    [tmpCurrentBottleBeers addObject:newBeer];
                    [currentBeers setObject:tmpCurrentBottleBeers forKey:@"bottles"];
                }
                break;
            case NSOrderedDescending:
                NSLog(@"Descending");
                if (onTap == @"Y") {
                    [tmpUpcomingTapBeers addObject:newBeer];
                    [upcomingBeers setObject:tmpUpcomingTapBeers forKey:@"tap"];
                }
                else {
                    [tmpUpcomingBottleBeers addObject:newBeer];
                    [upcomingBeers setObject:tmpUpcomingBottleBeers forKey:@"bottles"];
                }
                break;
          }
        
        
           // [currentBeers setObject:tmpCurrentBottleBeers forKey:@"bottles"];
           // [currentBeers setObject:tmpCurrentTapBeers forKey:@"tap"];
                
        newBeer.addedDt = @"0000-00-00";
        
        [self.delegate didAddBeer:newBeer onTap:onTap];
        NSLog(@"newBeer.beerId = %@", newBeer.beerId);
        
        //if (newBeer.tapDt >
        //[beers addObject:newBeer];
        [newBeer release];
        [dateFormatter release];
        [json release];
        [par release];
        
        
       [self.navigationController popViewControllerAnimated:YES];
    }
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
    self.textFieldBeingEdited = textField;
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];

    [self.tableView scrollToRowAtIndexPath:textFieldIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
    
    [tempValues setObject:textField.text forKey:tagAsNum];
    [tagAsNum release];
    
    // push view back to normal
    // unhide search bar controller
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == searchDisplayController.searchResultsTableView)
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        textFieldBeingEdited.text = selectedCell.textLabel.text;
        
        
        NSUInteger row = [indexPath row];
        beerId = [beerIDs objectAtIndex:row];
        NSArray *beerDetailsTemp = [beerLookup objectForKey:beerId];
        
        [tempValues setObject:[beerDetailsTemp objectAtIndex:0] forKey:[NSNumber numberWithInt:0]];
        [tempValues setObject:[beerDetailsTemp objectAtIndex:1] forKey:[NSNumber numberWithInt:1]];
        [tempValues setObject:[beerDetailsTemp objectAtIndex:2] forKey:[NSNumber numberWithInt:2]];
        [tempValues setObject:[beerDetailsTemp objectAtIndex:3] forKey:[NSNumber numberWithInt:3]];
        //[tempValues setObject:[beerDetailsTemp objectAtIndex:4] forKey:[NSNumber numberWithInt:4]];
        
        //autocompleteTableView.hidden = YES;
        searchDisplayController.searchResultsTableView.hidden = YES;
        [searchDisplayController setActive:NO animated:YES];
        
        // Reset scroll to the invisible rectange at top because scrollToIndexPath is pissing me off
        [self.tableView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];

        editingDisabled = TRUE;
        
    }
    
    else if (tableView == autocompleteTableView)
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        textFieldBeingEdited.text = selectedCell.textLabel.text;
        
        NSUInteger row = [indexPath row];
        
        [tempValues setObject:[autocompleteUrls objectAtIndex:row] forKey:[NSNumber numberWithInt:1]];
        
        [autocompleteUrls removeAllObjects];
        autocompleteTableView.hidden = YES;
        //[searchDisplayController setActive:NO animated:YES];
        
         
        // Reset scroll to the invisible rectange at top because scrollToIndexPath is pissing me off
        
        // Causing segmented control to copy itself in Tap Date field?!
        //[self.tableView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
    }
    
    [self.tableView reloadData];
       //[beerLookup release];
    //[beerIDs release];
}


@end
