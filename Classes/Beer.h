//
//  Beer.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Beer : NSObject {
    NSString *beerId;
    NSString *locationId;
    NSString *name;
    NSString *brewery;
    NSString *style;
    NSString *abv; 
    NSString *addedDt;
    NSString *tapDt;
    UIImage *image;
    NSString *forEvent;
}

@property (nonatomic, retain) NSString *beerId;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *brewery;
@property (nonatomic, retain) NSString *style;
@property (nonatomic, retain) NSString *abv;
@property (nonatomic, retain) NSString *addedDt;
@property (nonatomic, retain) NSString *tapDt;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *forEvent;
@end
