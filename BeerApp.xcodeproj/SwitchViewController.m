//
//  SwitchViewController.m
//  BeerApp
//
//  Created by Keith Zenoz on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SwitchViewController.h"
#import "BarsViewController.h"
#import "BeerAppViewController.h"



@implementation SwitchViewController
@synthesize barsViewController;
@synthesize beerAppViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [barsViewController release];
    [beerAppViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    BarsViewController *barsController = [[BarsViewController alloc]
                                          initWithNibName:@"BarsViewController" bundle:nil];
    self.barsViewController = barsController;
    [self.view insertSubview:barsController.view atIndex:0];
    [barsController release];
    
    //[super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)switchViews:(id)sender
{
    if (self.beerAppViewController == nil)
    {
        BeerAppViewController *beerAppController = [[BeerAppViewController alloc]
                                                    initWithNibName:@"BeerAppViewController" bundle:nil];
        self.beerAppViewController = beerAppController;
        [beerAppController release];
    }
    
    if (self.barsViewController.view.superview == nil)
    {
        [barsViewController.view removeFromSuperview];
        [self.view insertSubview:barsViewController.view atIndex:0];
    }
    else
    {
        [barsViewController.view removeFromSuperview];
        [self.view insertSubview:beerAppViewController.view atIndex:0];
    }
}

@end
