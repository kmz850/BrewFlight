//
//  President.h
//  Nav
//
//  Created by Keith Zenoz on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kPresidentNumberKey     @"President"
#define kPresidentNameKey       @"Name"
#define kPresidentFromKey       @"FromYear"
#define kPresidentToKey         @"ToYear"
#define kPresidentPartyKey      @"Party"

#import <Foundation/Foundation.h>

@interface President : NSObject <NSCoding> {
    int number;
    NSString *name;
    NSString *fromYear;
    NSString *toYear;
    NSString *party;
    NSString *beerName;
    NSString *brewery;
    NSString *style;
    NSString *abv;
}

@property int number;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *fromYear;
@property (nonatomic, retain) NSString *toYear;
@property (nonatomic, retain) NSString *party;
@property (nonatomic, retain) NSString *beerName;
@property (nonatomic, retain) NSString *brewery;
@property (nonatomic, retain) NSString *style;
@property (nonatomic, retain) NSString *abv;

@end
