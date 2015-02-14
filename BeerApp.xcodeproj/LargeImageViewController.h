//
//  LargeImageViewController.h
//  BeerApp
//
//  Created by Keith Zenoz on 1/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LargeImageViewController : UIViewController <UINavigationControllerDelegate> {
    UIImageView *imageView;
    UIImage *image;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;

@end
