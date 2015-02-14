//
//  BeerAppViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeerAppViewController : UIViewController {

    UITextView *textView;
    IBOutlet UITextField *loginField;
    IBOutlet UITextField *pwdField;
    IBOutlet UITextField *firstField;
    IBOutlet UITextField *lastField;
    IBOutlet UITextField *emailField;
    
}
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) UITextField *loginField;
@property (nonatomic, retain) UITextField *pwdField;
@property (nonatomic, retain) UITextField *firstField;
@property (nonatomic, retain) UITextField *lastField;
@property (nonatomic, retain) UITextField *emailField;

- (IBAction)registerPressed:(UIButton *)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundClick:(id)sender;

@end

