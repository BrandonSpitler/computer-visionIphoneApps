//
//  ViewController.h
//  computerVisionProject
//
//  Created by Valerie on 11/26/16.
//  Copyright © 2016 BrandonSpitler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;
-(uint32_t)grayScalePixel:(uint8_t *)pixel;


@end

