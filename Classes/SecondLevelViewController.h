//
//  SecondLevelViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecondLevelViewController : UIViewController {
    UIImage *rowImage;
    NSString *detailTitle;
}

@property (nonatomic, retain) UIImage *rowImage;
@property (nonatomic, retain) NSString *detailTitle;
@end
