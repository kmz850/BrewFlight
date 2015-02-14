//
//  AddBeerViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#define kNumberOfAddBeerFields   6
#define kNameRowIndex            0
#define kFromYearRowIndex        1
#define kToYearRowIndex          2
#define kPartyIndex              3
#define kTapDate                 4
#define kBottleTap               5

#define kLabelTag                4096

#import <UIKit/UIKit.h>
#import "BeerViewController.h"


@class Beer;

@protocol AddBeerDelegate <NSObject>

- (void)didAddBeer:(Beer *)beer onTap:(NSString *)onTap;

@end

//UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> 
@interface AddBeerViewController : UITableViewController <UITextFieldDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {

//{
    
    Beer *beer;
    NSMutableArray *beers;
    NSMutableDictionary *currentBeers;
    NSMutableDictionary *upcomingBeers;
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
    UISegmentedControl *beerServing;
    UIDatePicker *tapDatePicker;
    BOOL *editingDisabled;
    BOOL *brewerySearch;
    BOOL *isEvent;
    NSString *eventId;
    NSString *eventDate;
    id delegate;
}

@property (nonatomic, assign) id <AddBeerDelegate> delegate;
@property (nonatomic, retain) Beer *beer;
@property (nonatomic, retain) NSMutableArray *beers;
@property (nonatomic, retain) NSMutableDictionary *currentBeers;
@property (nonatomic, retain) NSMutableDictionary *upcomingBeers;
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
@property (nonatomic, retain) UISegmentedControl *beerServing;
@property (nonatomic, retain) UIDatePicker *tapDatePicker;
@property (nonatomic) BOOL *editingDisabled;
@property (nonatomic) BOOL *brewerySearch;
@property (nonatomic) BOOL *isEvent;
@property (nonatomic, retain) NSString *eventId;
@property (nonatomic, retain) NSString *eventDate;


- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;

@end



