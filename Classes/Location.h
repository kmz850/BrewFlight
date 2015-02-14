//
//  Locations.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Location : NSObject {
    NSString *locationId;
    NSString *name;
    NSString *address;
    NSString *city;
    NSString *state;
    NSString *zip;
    NSString *type;
    NSString *latitude;
    NSString *longitude;
    UIImage *icon;
}

@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) UIImage *icon;


@end
