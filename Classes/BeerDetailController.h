//
//  BeerDetailController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kNumberOfEditableRows    4
#define kNameRowIndex            0
#define kFromYearRowIndex        1
#define kToYearRowIndex          2
#define kPartyIndex              3

#define kLabelTag                4096


#import <UIKit/UIKit.h>
//#import <Beer.h>

//@class President;
@class Beer;

@protocol EditBeerDelegate <NSObject>

- (void)didEditBeer:(NSString *)beerId;

@end


@interface BeerDetailController : UIViewController 
<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    //President *president;
    Beer *beer;
    NSArray *fieldLabels;
    NSMutableDictionary *tempValues;
    UITextField *textFieldBeingEdited;
    UITextField *firstTextField;
    UIImageView *beerView;
    UIImage *beerImage;
    UIImage *beerImageLg;
    BOOL *editMode;
    BOOL *editImage;
    id delegate;
}

//@property (nonatomic, retain) President *president;
@property (nonatomic, assign) id <EditBeerDelegate> delegate;
@property (nonatomic, retain) Beer *beer;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic, retain) UITextField *firstTextField;
@property (nonatomic, retain) UIImageView *beerView;
@property (nonatomic, retain) UIImage *beerImage;
@property (nonatomic, retain) UIImage *beerImageLg;
@property (nonatomic) BOOL *editMode;
@property (nonatomic) BOOL *editImage;

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (NSData *)decodeBase64WithString:(NSString *)strBase64;
- (NSString *)encodeBase64WithData:(NSData *)objData;
- (NSString *)encodeBase64WithString:(NSString *)strData;

@end
