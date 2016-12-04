//
//  ViewController.m
//  computerVisionProject
//
//  Created by Valerie on 11/26/16.
//  Copyright © 2016 BrandonSpitler. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//loops over arrays of letters tests if that locations is in the image
//if it is in the array already it returns the pixel to skip to to avoid the letter
-(int)skipPixelAtLocationX:(int)x andY:(int)y withenRangeMinX:(NSMutableArray*)minX maxX:(NSMutableArray*)maxX minY:(NSMutableArray*)minY maxY:(NSMutableArray*) maxY withLength:(int)length{
    
    
    for(int i=0;i<length;i++){
        if(x>=[[minX objectAtIndex:i] intValue]){
            if(y>=[[minY objectAtIndex:i] intValue]){
                if(x<=[[maxX objectAtIndex:i] intValue]){
                    if(y<=[[maxY objectAtIndex:i] intValue]){
                        return [[maxY objectAtIndex:i] intValue];
                    }
                }
            }
        }
    }
    return y;//return x if not in range
}
//#define debugGrayScale
-(uint32_t)grayScalePixel:(uint8_t *)pixel{
#ifdef debugGrayScale
    NSLog(@"%hhu",pixel[1]);
    NSLog(@"%hhu",pixel[2]);
    NSLog(@"%hhu",pixel[3]);
#endif
    return (.2*pixel[1]+.6*pixel[2]+.2*pixel[3]);
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    int x;
    int y;
    NSMutableArray *minX=[NSMutableArray array];
    NSMutableArray *maxX=[NSMutableArray array];
    NSMutableArray *minY=[NSMutableArray array];
    NSMutableArray *maxY=[NSMutableArray array];
    int numberOfLetters=0;
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage * image=info[UIImagePickerControllerOriginalImage];
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    //_imageView.image=image;
    CGSize imageSize=image.size;
    uint32_t *pixels=(uint32_t *)malloc(imageSize.width * imageSize.height *sizeof(uint32_t));
    memset(pixels, 0, imageSize.width * imageSize.height *sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, imageSize.width, imageSize.height, 8, imageSize.width * sizeof(uint32_t), colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(context, imageRect, [image CGImage]);
    //grey scale image
    for (int i = 0; i<imageSize.height-1;i++){
        for(int j=0; j<imageSize.width-1;j++){
                uint8_t *currentPixel=(uint8_t * )&pixels[i * (NSUInteger)imageSize.width + j];
                uint32_t grayPixel = [self grayScalePixel: currentPixel];
            //NSLog(@"%d",grayPixel);
            if(grayPixel<100){
                
            
                currentPixel[1]=255;
                currentPixel[2]=255;
                currentPixel[3]=255;
            }else{
                currentPixel[1]=0;
                currentPixel[2]=0;
                currentPixel[3]=0;
            }
        }
    }

    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    
    //Releasing resources to free up memory
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    //Creating UIImage for return value
    //UIImage* newUIImage = [UIImage imageWithCGImage:newCGImage scale:(CGFloat)[inputImg scale] orientation:UIImageOrientationUp];
    _imageView.image = [UIImage imageWithCGImage:newCGImage];
    
    //Releasing the CGImage
    CGImageRelease(newCGImage);
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)useCamera:(id)sender {
    if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
        imagePicker.delegate=self;
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes=@[(NSString *) kUTTypeImage];
        
        imagePicker.allowsEditing = NO;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia=YES;
        
        
        
        
    }
}

- (IBAction)useCameraRoll:(id)sender {
}
@end
