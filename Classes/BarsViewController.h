//
//  BarsViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BarsViewController : UITableViewController 
<UITableViewDelegate, UITableViewDataSource> {
    
    NSArray *listData;
}

@property (nonatomic, retain) NSArray *listData;

@end
