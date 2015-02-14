//
//  BeerAppViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BeerAppViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

@implementation BeerAppViewController
@synthesize textView;
@synthesize loginField;
@synthesize pwdField;
@synthesize firstField;
@synthesize lastField;
@synthesize emailField;

- (IBAction)registerPressed:(UIButton *)sender {

    // Start request
    NSString *login = loginField.text;
    NSString *pwd = pwdField.text;
    NSString *first = firstField.text;
    NSString *last = lastField.text;
    NSString *email = emailField.text;
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:8888/poop.php"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:login forKey:@"login"];
    [request setPostValue:pwd forKey:@"password"];
    [request setPostValue:first forKey:@"lastname"];                               
    [request setPostValue:last forKey:@"firstname"];
    [request setPostValue:email forKey:@"email"];
    [request setDelegate:self];
    [request startAsynchronous];
    
    // Hide keyword
    //[textField resignFirstResponder];
    [sender resignFirstResponder];

    // Clear text field
    textView.text = @"";
    textView.text = [request responseString];
    
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)backgroundClick:(id)sender
{
    [loginField resignFirstResponder];
    [pwdField resignFirstResponder];
    [firstField resignFirstResponder];
    [lastField resignFirstResponder];
    [emailField resignFirstResponder];
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.responseStatusCode == 400) {
        textView.text = @"Missing parameters";
    } else if (request.responseStatusCode == 403) {
        textView.text = @"Login already used";
    } else if (request.responseStatusCode == 200) {
        textView.text = @"Login created";
    } else {
        textView.text = @"Unexpected error";
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    textView.text = error.localizedDescription;
    
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setTextView:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [textView release];
    [super dealloc];
}

@end
