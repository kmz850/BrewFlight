//
//  Locations.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Location.h"

@implementation Location
@synthesize locationId;
@synthesize name;
@synthesize address;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize type;
@synthesize latitude;
@synthesize longitude;
@synthesize icon;

- (void)dealloc {
    [locationId release];
    [name release];
    [address release];
    [city release];
    [state release];
    [zip release];
    [type release];
    [latitude release];
    [longitude release];
    [icon release];
    [super dealloc];
    
}
@end
