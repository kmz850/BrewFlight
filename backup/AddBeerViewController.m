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
        
        Beer *newBeer = [[Beer alloc] init];
        newBeer.beerId = beerId;
        
        for (NSNumber *key in [tempValues allKeys])
        {
            switch ([key intValue]) {
                case kNameRowIndex:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"name"];
                    newBeer.name = [tempValues objectForKey:key];
                    break;
                case kFromYearRowIndex:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"brewery"];
                    newBeer.brewery = [tempValues objectForKey:key];
                    break;
                case kToYearRowIndex:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"style"];
                    newBeer.style = [tempValues objectForKey:key];
                    break;
                case kPartyIndex:
                    [request setPostValue:[tempValues objectForKey:key] forKey:@"abv"];
                    newBeer.abv = [tempValues objectForKey:key];
                default:
                    break;
            }
        }
        
        [request setDelegate:self];
        [request startAsynchronous];
        
        if (textFieldBeingEdited != nil)
        {
            [textFieldBeingEdited resignFirstResponder];
        }
        
        // popViewController when request is finished
        [self.navigationController popViewControllerAnimated:YES];
        
        //NSArray *allControllers = self.navigationController.viewControllers;
        //UITableViewController *parent = [allControllers lastObject];
        //[parent.tableView reloadData];
        
        //[self.tableView reloadData];
        
        newBeer.addedDt = @"0000-00-00";
        
        [beers addObject:newBeer];
        [newBeer release];
        [properties release];
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
    NSArray *array = [[NSArray alloc] initWithObjects:@"Name", @"Brewery", @"Style", @"ABV", nil];
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
        return kNumberOfEditableRows;
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
        
        
    if (cell == nil) {
                
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
                                       reuseIdentifier:AddBeerCellIdentifier] autorelease];
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
        default:
            break;
    }
        
        
    if (editingDisabled) {
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

        searchDisplayController.searchResultsTableView.allowsSelectionDuringEditing = YES;
        searchDisplayController.searchResultsTableView.allowsSelection = YES;
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
        [req startAsynchronous];    
    }
    else
        autocompleteTableView.hidden = YES;
                        
   // [url release];
    [properties release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *par = [[SBJsonParser alloc] init];
    
    NSData *res = [request responseData];
    
    NSString *json = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
    
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
        //[autocompleteUrls removeAllObjects];
        autocompleteTableView.hidden = YES;
    
    [autocompleteUrls removeAllObjects];
    
    NSLog(@"pastUrls: %@", pastUrls);
    for(NSString *curString in pastUrls) {
        //NSRange substringRange = [curString rangeOfString:self.substringGlobal];
        //if (substringRange.location == 0) {
            [autocompleteUrls addObject:curString];  
        //}
    }
    [autocompleteTableView reloadData];
    [searchDisplayController.searchResultsTableView reloadData];

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
   
        autocompleteTableView.hidden = YES;
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
        [self.tableView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
    }
    
    [self.tableView reloadData];
       //[beerLookup release];
    //[beerIDs release];
}


@end
