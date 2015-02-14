//
//  CameraViewController.h
//  Camera
//
//  Created by Dave Mark on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface CameraViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImageView *imageView;
    UIButton *takePictureButton;
    //MPMoviePlayerController *moviePlayerController;
    UIImage *image;
    UIImage *imageLg;
    NSURL *movieURL;
    NSString *lastChosenMediaType;
    CGRect imageFrame;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *takePictureButton;
//@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *imageLg;
@property (nonatomic, retain) NSURL *movieURL;
@property (nonatomic, copy) NSString *lastChosenMediaType;

- (IBAction)shootPictureOrVideo:(id)sender;
- (IBAction)selectExistingPictureOrVideo:(id)sender;
//- (NSData *)decodeBase64WithString:(NSString *)strBase64;
//- (NSString *)encodeBase64WithData:(NSData *)objData;
//- (NSString *)encodeBase64WithString:(NSString *)strData;

@end
