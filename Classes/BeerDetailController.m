//
//  BeerDetailController.m
//  BeerApp
//
//  Created by Keith Zenoz on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BeerDetailController.h"
#import "Beer.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AFHTTPClient.h"

#import "CameraViewController.h"
#import "LargeImageViewController.h"
#import "QSStrings.h"
#import "UIImage-Extensions.h"
#import "UIImage+FixOrientation.h"
//#import "President.h"

//#import "BeerAppAppDelegate.h"

@interface BeerDetailController ()
- (void)updateDisplay;
UIImage *scaleAndRotateImage2(UIImage *image);

@end

@implementation BeerDetailController




@synthesize beer;
@synthesize fieldLabels;
@synthesize tempValues;
@synthesize textFieldBeingEdited;
@synthesize firstTextField;
@synthesize editMode;
@synthesize beerView;
@synthesize beerImage;
@synthesize beerImageLg;
@synthesize editImage;
@synthesize delegate;

#pragma mark -

-(IBAction)toggleEdit:(id)sender {
    //[self setEditing:TRUE];
    self.editMode = TRUE;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.hidesBackButton = YES;
    [cancelButton release];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Save"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    [firstTextField becomeFirstResponder];
    
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return kNumberOfEditableRows;
}


-(IBAction)cancel:(id)sender {
    
    // Dismiss any changes user made, then tell tableView to refresh
    // the initial data
    
    tempValues = nil;    
    //[self.tableView reloadData];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = NO;
    
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Edit"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(toggleEdit:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    self.editMode = false;
    if (textFieldBeingEdited != nil)
    {
        [textFieldBeingEdited resignFirstResponder];
        textFieldBeingEdited = nil;
    }
    
}

-(IBAction)save:(id)sender
{
    if (textFieldBeingEdited != nil)
    {
        NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textFieldBeingEdited.tag];
        [tempValues setObject:textFieldBeingEdited.text forKey:tagAsNum];
        [tagAsNum release];
    }
    
    for (NSNumber *key in [tempValues allKeys])
    {
        switch ([key intValue]) {
            case kNameRowIndex:
                beer.name = [tempValues objectForKey:key];
                break;
            case kFromYearRowIndex:
                beer.brewery = [tempValues objectForKey:key];
                break;
            case kToYearRowIndex:
                beer.style = [tempValues objectForKey:key];
                break;
            case kPartyIndex:
                beer.abv = [tempValues objectForKey:key];
            default:
                break;
        }
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = NO;
    
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Edit"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(toggleEdit:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    self.editMode = false;
    if (textFieldBeingEdited != nil)
    {
        [textFieldBeingEdited resignFirstResponder];
        textFieldBeingEdited = nil;
    }
    
    
    
      
    NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString *webserver = [properties objectForKey:@"connection_string"];
    
    NSURL *url = [NSURL URLWithString:[webserver stringByAppendingString:@"updateBeer.php"]];
    
    // Take image and base64encode to send across webservice
    //NSString *encodedImage = [NSString alloc];
    //NSData *imageData = UIImageJPEGRepresentation(beerImage, 1.0);
    //NSData *imageData = UIImagePNGRepresentation(beerImage);
    //NSData *imageData = [[NSData alloc] initWithData:UIImagePNGRepresentation(beerImage)];
    NSData *imageDataLg = [[NSData alloc] initWithData:UIImageJPEGRepresentation([beerImageLg fixOrientation], 0.0)];
    //NSData *imageDataLg = [[NSData alloc] initWithData:UIImagePNGRepresentation(beerImageLg)];
    
    //NSLog(@"imageDataLg size = %d", [imageDataLg length]);
    //NSLog(@"imageDataLg: %@", imageDataLg);
    //encodedImage = [self encodeBase64WithData:imageData];
   
    
    /*
     NSURL *url = [NSURL URLWithString:@"http://api-base-url.com"];
     AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
     NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"avatar.jpg"], 0.5);
     NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/upload" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
     [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
     }];
     
     AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
     NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
     }];
     [httpClient enqueueHTTPRequestOperation:operation];
     */
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setPostValue:beer.beerId forKey:@"beerId"];
    [request setPostValue:beer.name forKey:@"name"];
    [request setPostValue:beer.brewery forKey:@"brewery"];                               
    [request setPostValue:beer.style forKey:@"style"];
    [request setPostValue:beer.abv forKey:@"abv"];
    [request setData:imageDataLg withFileName:[NSString stringWithFormat:@"%@", beer.beerId,@".jpg"] andContentType:@"image/jpg" forKey:@"img"];
    //[request setData:imageDataLg withFileName:[NSString stringWithFormat:@"%@", beer.beerId,@"_lg.jpg"] andContentType:@"image/jpeg" forKey:@"imgLg"];
    [request setDelegate:self];
    
    NSLog(@"starting Request");
    [request startAsynchronous];

    
    //[properties release];
    //[imageData release];
    //[imageDataLg release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSData *response = [request responseData];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        NSLog(@"json_string = %@", json_string);
    
    [self.delegate didEditBeer:beer.beerId];
    
    [self.navigationController popViewControllerAnimated:YES];
    //NSArray *allControllers = self.navigationController.viewControllers;
   // UITableViewController *parent = [allControllers lastObject];
   // [parent.tableView reloadData];


}

-(IBAction)textFieldDone:(id)sender
{
    [sender resignFirstResponder];
}

- (void)dealloc
{
    [textFieldBeingEdited release];
    [tempValues release];
    [beer release];
    [fieldLabels release];
    
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 104;
}*/


- (IBAction) handleSingleTapOnHeader: (UIGestureRecognizer *) sender {
  
        if (editMode)
        {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
            NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
            
            NSString *webserver = [properties objectForKey:@"connection_string"];
            
            NSString *filePath = [NSString stringWithFormat:@"%@%@_lg.jpg", webserver, beer.beerId];
            
            self.beerImageLg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            
            CameraViewController *cwc = [[CameraViewController alloc] init];
            cwc.image = self.beerImage;
            cwc.imageLg = self.beerImageLg;
            [self.navigationController pushViewController:cwc animated:YES];
            self.editImage = TRUE;
            
            beerView.image = self.beerImage;
            [properties release];
            [cwc release];
            //[self updateDisplay]; 
        }
        else
        {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
            NSDictionary *properties = [[NSDictionary alloc] initWithContentsOfFile:path];
            
            NSString *webserver = [properties objectForKey:@"connection_string"];
        
            NSString *filePath = [NSString stringWithFormat:@"%@%@_lg.jpg", webserver, beer.beerId];

            self.beerImageLg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]]];
            NSLog(@"filePath = %@", filePath);
            // Display large pic
            LargeImageViewController *largeImageView = [[LargeImageViewController alloc] init];
            

            largeImageView.image = self.beerImageLg;
            [self.navigationController pushViewController:largeImageView animated:YES];
            [largeImageView release];
            [properties release];
        }
        
   
    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    //UIImage *beerImage = [UIImage imageNamed:@"fermentation.jpg"];
    
    //UIImage *beerImageSmall = [UIImage imageWithCGImage:beerImage.CGImage scale:0.25 orientation:beerImage.imageOrientation];
    
    beerView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,104)];
    //initWithFrame:CGRectMake(0,0,320,104)];
    
    
    
    
    
    //            initWithImage:self.beerImage];
    beerView.userInteractionEnabled = true;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnHeader:)];
    
    //singleTap.numberOfTouchesRequired = 1;
    //singleTap.enabled = TRUE;
    //singleTap.numberOfTapsRequired = 1;
    
    
    
    
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,480)
                                                   style:UITableViewStyleGrouped];
    [beerView setContentMode:UIViewContentModeCenter];
    
    [tv.tableHeaderView setContentMode:UIViewContentModeScaleAspectFit];
    beerView.frame = CGRectMake(0, 0, 320, 104);
    //[beerView setContentMode:UIViewContentModeScaleToFill];
    tv.tableHeaderView.frame = CGRectMake(0,0,320,104);
    tv.tableHeaderView.bounds = CGRectMake(0,0,320,104);
    
    // Make tableView cell borders clear
    tv.separatorColor = [UIColor clearColor];
    
    [beerView addGestureRecognizer:singleTap];
    [singleTap release];
    //[tv setTableHeaderView:beerView];
    
    //[tv.tableHeaderView addSubview:beerView];
    tv.tableHeaderView = beerView;
    tv.delegate = self;
    tv.dataSource = self;
    //[tv reloadData];
    //[tv.tableHeaderView setFrame:CGRectMake(0,0,beerImage.size.width, beerImage.size.height)]; 
   // tv.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)] autorelease];
    
    // Give some room at the bottom to scroll and focus on fields
    tv.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,680)] autorelease];
    [self.view addSubview:tv];
    [tv.tableHeaderView setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    [tv setUserInteractionEnabled: YES];
    [beerView setUserInteractionEnabled:YES];
    
    
    //[self.view setContentMode:UIViewContentModeScaleAspectFit];
    
    [beerView release];
    [tv release];
    
}

/*
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textFieldBeingEdited = textField;
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];
    
    [tableView scrollToRowAtIndexPath:textFieldIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}*/

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}



//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 0.0;
//}

UIImage *scaleAndRotateImage2(UIImage *image)  
{  
    int kMaxResolution = 320; // Or whatever  
    
    CGImageRef imgRef = image.CGImage;  
    
    CGFloat width = CGImageGetWidth(imgRef);  
    CGFloat height = CGImageGetHeight(imgRef);  
    
    CGAffineTransform transform = CGAffineTransformIdentity;  
    CGRect bounds = CGRectMake(0, 0, width, height);  
    if (width > kMaxResolution || height > kMaxResolution) {  
        CGFloat ratio = width/height;  
        if (ratio > 1) {  
            bounds.size.width = kMaxResolution;  
            bounds.size.height = bounds.size.width / ratio;  
        }  
        else {  
            bounds.size.height = kMaxResolution;  
            bounds.size.width = bounds.size.height * ratio;  
        }  
    }  
    
    CGFloat scaleRatio = bounds.size.width / width;  
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
    CGFloat boundHeight;  
    UIImageOrientation orient = image.imageOrientation;  
    switch(orient) {  
            
        case UIImageOrientationUp: //EXIF = 1  
            transform = CGAffineTransformIdentity;  
            break;  
            
        case UIImageOrientationUpMirrored: //EXIF = 2  
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            break;  
            
        case UIImageOrientationDown: //EXIF = 3  
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
            transform = CGAffineTransformRotate(transform, M_PI);  
            break;  
            
        case UIImageOrientationDownMirrored: //EXIF = 4  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);  
            transform = CGAffineTransformScale(transform, 1.0, -1.0);  
            break;  
            
        case UIImageOrientationLeftMirrored: //EXIF = 5  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
            
        case UIImageOrientationLeft: //EXIF = 6  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
            
        case UIImageOrientationRightMirrored: //EXIF = 7  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeScale(-1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
            
        case UIImageOrientationRight: //EXIF = 8  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
            
        default:  
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
            
    }  
    
    UIGraphicsBeginImageContext(bounds.size);  
    
    CGContextRef context = UIGraphicsGetCurrentContext();  
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {  
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);  
        CGContextTranslateCTM(context, -height, 0);  
    }  
    else {  
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);  
        CGContextTranslateCTM(context, 0, -height);  
    }  
    
    CGContextConcatCTM(context, transform);  
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    
    return imageCopy;  
}  


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateDisplay];
}

- (void)updateDisplay {
  
    [beerView setImage:self.beerImage];
  
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   

    
    //NSArray *array = [[NSArray alloc] initWithObjects:@"Name:", @"From:", @"To:", @"Party:", nil];
    NSArray *array = [[NSArray alloc] initWithObjects:@"Name", @"Brewery", @"Style", @"ABV", nil];
    
    self.fieldLabels = array;
    [array release];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Edit"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(toggleEdit:)];
    
    //self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem = editButton;
      
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    self.tempValues = dict;

    [dict release];
    
    // Resize image
    beerView.image = beerImage;
    beerView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect frame = beerView.frame;
    frame.size.width = 100;
    beerView.frame = frame;
    
    [super viewDidLoad];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   
    static NSString *PresidentCellIdentifier = @"PresidentCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PresidentCellIdentifier];
    if (cell == nil) {
    
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PresidentCellIdentifier] autorelease];
        
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10,10,75,25)];
        
        label.textAlignment = UITextAlignmentRight;
        label.tag = kLabelTag;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
        
        [cell.contentView addSubview:label];
        [label release];
        
        UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(90,12,200,25)];
        textField.clearsOnBeginEditing = NO;
        [textField setDelegate:self];
        textField.returnKeyType = UIReturnKeyDone;
        [textField addTarget:self 
                      action:@selector(textFieldDone:)
            forControlEvents:UIControlEventEditingDidEndOnExit];
        [cell.contentView addSubview:textField];
        
              
    }
    
    
    NSUInteger row = [indexPath row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
    UITextField *textField = nil;
    
    for (UIView *oneView in cell.contentView.subviews)
    {
        if ([oneView isMemberOfClass:[UITextField class]])
            textField = (UITextField *)oneView;
    }
    label.text = [fieldLabels objectAtIndex:row];
    NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
    
    switch (row) {
        case kNameRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = beer.name;
            break;
        case kFromYearRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = beer.brewery;
            break;
        case kToYearRowIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = beer.style;
            break;   
        case kPartyIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = beer.abv; 
        default:
            break;
    }
    
    if (row == kNameRowIndex)
    {
        firstTextField = textField;
    }
    
    if (textFieldBeingEdited == textField)
        textFieldBeingEdited = nil;
    
    textField.tag = row;
    [rowAsNum release];
    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
    self.textFieldBeingEdited = textField;
    
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];

    [table scrollToRowAtIndexPath:textFieldIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
    [tempValues setObject:textField.text forKey:tagAsNum];
    [tagAsNum release];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.editMode)
        return true;
    else
        return false;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

- (NSString *)encodeBase64WithString:(NSString *)strData {
	return [QSStrings encodeBase64WithData:[strData dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *)encodeBase64WithData:(NSData *)objData {
	const unsigned char * objRawData = [objData bytes];
	char * objPointer;
	char * strResult;
    
	// Get the Raw Data length and ensure we actually have data
	int intLength = [objData length];
	if (intLength == 0) return nil;
	// Setup the String-based Result placeholder and pointer within that placeholder
	strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
	objPointer = strResult;
	
	// Iterate through everything
	while (intLength > 2) { // keep going until we have less than 24 bits
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
		*objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
		*objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
		
		// we just handled 3 octets (24 bits) of data
		objRawData += 3;
		intLength -= 3; 
	}
    
	// now deal with the tail end of things
	if (intLength != 0) {
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		if (intLength > 1) {
			*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
			*objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
			*objPointer++ = '=';
		} else {
			*objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
			*objPointer++ = '=';
			*objPointer++ = '=';
		}
	}
    
	// Terminate the string-based result
	*objPointer = '\0';
    
	// Return the results as an NSString object
	return [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
}

- (NSData *)decodeBase64WithString:(NSString *)strBase64 {
	const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
	int intLength = strlen(objPointer);
	int intCurrent;
	int i = 0, j = 0, k;
    
	unsigned char * objResult;
	objResult = calloc(intLength, sizeof(char));
    
	// Run through the whole string, converting as we go
	while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
		if (intCurrent == '=') {
			if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
				// the padding character is invalid at this point -- so this entire string is invalid
				free(objResult);
				return nil;
			}
			continue;
		}
        
		intCurrent = _base64DecodingTable[intCurrent];
		if (intCurrent == -1) {
			// we're at a whitespace -- simply skip over
			continue;
		} else if (intCurrent == -2) {
			// we're at an invalid character
			free(objResult);
			return nil;
		}
        
		switch (i % 4) {
			case 0:
				objResult[j] = intCurrent << 2;
				break;
                
			case 1:
				objResult[j++] |= intCurrent >> 4;
				objResult[j] = (intCurrent & 0x0f) << 4;
				break;
                
			case 2:
				objResult[j++] |= intCurrent >>2;
				objResult[j] = (intCurrent & 0x03) << 6;
				break;
                
			case 3:
				objResult[j++] |= intCurrent;
				break;
		}
		i++;
	}
    
	// mop things up if we ended on a boundary
	k = j;
	if (intCurrent == '=') {
		switch (i % 4) {
			case 1:
				// Invalid state
				free(objResult);
				return nil;
                
			case 2:
				k++;
				// flow through
			case 3:
				objResult[k] = 0;
		}
	}
    
	// Cleanup and setup the return NSData
	NSData * objData = [[[NSData alloc] initWithBytes:objResult length:j] autorelease];
	free(objResult);
	return objData;
}


@end
