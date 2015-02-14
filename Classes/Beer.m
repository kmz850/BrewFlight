//
//  Beer.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Beer.h"


@implementation Beer

@synthesize beerId;
@synthesize locationId;
@synthesize name;
@synthesize brewery;
@synthesize style;
@synthesize abv;
@synthesize addedDt;
@synthesize tapDt;
@synthesize image;
@synthesize forEvent;

- (void)dealloc {
    [beerId release];
    [locationId release];
    [name release];
    [brewery release];
    [style release];
    [abv release];
    [addedDt release];
    [tapDt release];
    [image release];
    [forEvent release];
    [super dealloc];
}
@end
