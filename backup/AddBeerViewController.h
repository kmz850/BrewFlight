//
//  AddBeerViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#define kNumberOfEditableRows    4
#define kNameRowIndex            0
#define kFromYearRowIndex        1
#define kToYearRowIndex          2
#define kPartyIndex              3

#define kLabelTag                4096

#import <UIKit/UIKit.h>

@class Beer;
//UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> 
@interface AddBeerViewController : UITableViewController <UITextFieldDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {

//{
    
    Beer *beer;
    NSString *locationId;
    NSString *beerId;
    NSString *substringGlobal;
    NSArray *fieldLabels;
    NSMutableDictionary *tempValues;
    UITextField *textFieldBeingEdited;
    UITextField *firstTextField;
    UITableView *autocompleteTableView;
    NSMutableArray *autocompleteUrls;
    NSMutableArray *pastUrls;
    NSMutableArray *beerDetails;
    NSMutableArray *beerIDs;
    NSMutableArray *locationBeerIDs;
    NSMutableDictionary *beerLookup;
    UISearchDisplayController *searchDisplayController;
    UISearchBar *searchBar;
    BOOL *editingDisabled;
    BOOL *brewerySearch;
}

@property (nonatomic, retain) Beer *beer;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSString *beerId;
@property (nonatomic, retain) NSString *substringGlobal;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic, retain) UITextField *firstTextField;
@property (nonatomic, retain) UITableView *autocompleteTableView;
@property (nonatomic, retain) NSMutableArray *autocompleteUrls;
@property (nonatomic, retain) NSMutableArray *pastUrls;
@property (nonatomic, retain) NSMutableArray *beerDetails;
@property (nonatomic, retain) NSMutableArray *beerIDs;
@property (nonatomic, retain) NSMutableArray *locationBeerIDs;
@property (nonatomic, retain) NSMutableDictionary *beerLookup;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL *editingDisabled;
@property (nonatomic) BOOL *brewerySearch;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;

@end
