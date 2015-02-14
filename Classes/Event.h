//
//  Event.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject {
    
    NSString *eventId;
    NSString *name;
    NSString *locationId;
    NSString *date;
    NSString *description;
    NSString *fullAddress;
    BOOL *tapTakeOver;
    UIImage *image;
    UIImage *map;
    NSMutableArray *arrayOfBeers;
    NSMutableDictionary *dictOfBeers;
    NSString *fourSquareName;
    UIImage *fourSquareIcon;
}

@property (nonatomic, retain) NSString *eventId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *map;
@property (nonatomic, retain) NSMutableArray *arrayOfBeers;
@property (nonatomic, retain) NSMutableDictionary *dictOfBeers;
@property (nonatomic, retain) NSString *fullAddress;
@property (nonatomic, retain) NSString *fourSquareName;
@property (nonatomic, retain) UIImage *fourSquareIcon;


@end

