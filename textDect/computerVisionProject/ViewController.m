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
-(int) sweepOfList: (int*)connectedList andSize:(int *)numberOfLetters andHeight:(NSInteger)height andWidth:(NSInteger)width {
    int flag=0;
    for (int i = 1; i<height-2;i++){
        for(int j=1; j<width-2;j++){
            int max=connectedList[i * (NSUInteger)width + j];
            
            if(max!=0){
            //NSLog(@"%d",max);
            for(int z=i-1;z<=i+1;z++){
                for(int f=j-1;f<=j+1;f++){
                    if(connectedList[z * (NSUInteger)width + f]>max){
                        flag=1;
                        max=connectedList[z * (NSUInteger)width + f];
                    }
                }
            }
            connectedList[i * (NSUInteger)width + j]=max;
            //NSLog(@"max is %d ", max);
            }
           
        }
    }
    return flag;
}

-(int)isInArrayArray: (int*)connectedNumberArray ofSize:(int)nsize numberToFind:(int)numberToFind{
    for(int i=0;i<nsize;i++){
        if(connectedNumberArray[i]==numberToFind){
            return i;
        }
    }
    return -1;
}
-(int)findNumberOfLetters:(int *)connectedNumberArray andHeight:(NSInteger)height andWidth:(NSInteger)width{
    NSMutableArray *connectNumbers=[NSMutableArray array];
    int numberOfLetters=0;
    Boolean isInArray;
    for (int i = 1; i<height-3;i++){
        for(int j=1; j<width-2;j++){
            isInArray=false;
           // NSLog(@"i is %d, and j is %d",i,j);
            int numberToFind=connectedNumberArray[i * (NSUInteger)width + j];
            if(numberToFind!=0){
            for(int z=0;z<numberOfLetters;z++){
                if([[connectNumbers objectAtIndex:z] intValue]==numberToFind){
                    isInArray=true;
                }
            }
            if(isInArray==false){
                [connectNumbers addObject:[NSNumber numberWithInt:numberToFind]];
                numberOfLetters++;
            }
            }
            
        }
    }
    return numberOfLetters;
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage * image=info[UIImagePickerControllerOriginalImage];
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    //_imageView.image=image;
    CGSize imageSize=image.size;
    uint32_t *pixels=(uint32_t *)malloc(imageSize.width * imageSize.height *sizeof(uint32_t));
    memset(pixels, 0, imageSize.width * imageSize.height *sizeof(uint32_t));
    int *connectedList=(int *)malloc(imageSize.width * imageSize.height *sizeof(uint32_t));
    memset(connectedList,0,imageSize.width * imageSize.height *sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, imageSize.width, imageSize.height, 8, imageSize.width * sizeof(uint32_t), colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    int numberOfPixels=0;
    CGContextDrawImage(context, imageRect, [image CGImage]);
    //grey scale image
    for (int i = 0; i<imageSize.height-1;i++){
        for(int j=0; j<imageSize.width-1;j++){
            uint8_t *currentPixel=(uint8_t * )&pixels[i * (NSUInteger)imageSize.width + j];
            uint32_t grayPixel = [self grayScalePixel: currentPixel];
            currentPixel[1]=grayPixel;
            currentPixel[2]=grayPixel;
            currentPixel[3]=grayPixel;
            if(grayPixel<50){
                currentPixel[1]=0;
                currentPixel[2]=0;
                currentPixel[3]=0;
                numberOfPixels++;
                connectedList[i * (NSUInteger)imageSize.width + j]=numberOfPixels;
               // NSLog(@"connected List is %d",connectedList[i * (NSUInteger)imageSize.width + j]);
            }else{
                connectedList[i * (NSUInteger)imageSize.width + j]=0;
                currentPixel[1]=255;
                currentPixel[2]=255;
                currentPixel[3]=255;
            }
        }
    }
    int didChange=1;
    NSLog(@"after grey scale");
    int numberOfLetters;
    int index=0;
    while(didChange!=0){
        didChange=[self sweepOfList:connectedList andSize:&numberOfLetters andHeight:imageSize.height andWidth:imageSize.width];
        index++;
    }
    NSLog(@"there are %d index",index);
    numberOfLetters=[self findNumberOfLetters:connectedList andHeight:imageSize.height andWidth:imageSize.width];
    NSLog(@"there are %d letters",numberOfLetters);
    
    int *maxX=(int *)malloc(numberOfLetters*sizeof(int));
    memset(maxX,INT_MIN,numberOfLetters*sizeof(int));
    
    int *minX=(int *)malloc(numberOfLetters*sizeof(int));
    memset(minX,INT_MAX,numberOfLetters*sizeof(int));
    
    int *maxY=(int *)malloc(numberOfLetters*sizeof(int));
    memset(maxY,INT_MIN,numberOfLetters*sizeof(int));
    
    int *minY=(int *)malloc(numberOfLetters*sizeof(int));
    memset(minY,INT_MAX,numberOfLetters*sizeof(int));
    
    int *connectNumber=(int *)malloc(numberOfLetters*sizeof(int));
    memset(connectNumber,0,numberOfLetters*sizeof(int));
    
    
    int letter=-1;
    for (int i = 5; i<imageSize.height-5;i++){
        for(int j=5; j<imageSize.width-5;j++){
            int curNumber=connectedList[i * (NSUInteger)imageSize.width + j];
            if((curNumber!=0)){
            int curLetter=[self isInArrayArray:connectNumber ofSize:numberOfLetters numberToFind:curNumber];
            //NSLog(@"letterId is %d",curLetter);
            if(curLetter==-1){
                letter++;
                connectNumber[letter]=connectedList[i * (NSUInteger)imageSize.width + j];
                curLetter=letter;
            }
            if(connectedList[i * (NSUInteger)imageSize.width + j]!=0){
                if(maxY[curLetter]<j){
                    maxY[curLetter]=j;
                }
                if(minY[curLetter]>j){
                    minY[curLetter]=j;
                }
                if(maxX[curLetter]<i){
                    maxX[curLetter]=i;
                }
                if(minX[curLetter]>i){
                    minX[curLetter]=i;
                }
            }
            }
        }
    }
    //red box letter
    for(int i=0;i<numberOfLetters;i++){
        NSLog(@"i is %d minY is %d maxY is %d minX %d is maxX is %d",i,minY[i],maxY[i],minX[i],maxX[i]);
        for(int n=minY[i];n<maxY[i];n++){
            
                int z=minX[i];
                uint8_t *currentPixel=(uint8_t * )&pixels[z * (NSUInteger)imageSize.width + n];
                currentPixel[1]=255;
                currentPixel[2]=0;
                currentPixel[3]=0;
                z=maxX[i];
                currentPixel=(uint8_t * )&pixels[z * (NSUInteger)imageSize.width + n];
                currentPixel[1]=255;
                currentPixel[2]=0;
                currentPixel[3]=0;

            
        }
        for(int n=minX[i];n<=maxX[i];n++){
            int z=minY[i];
            uint8_t *currentPixel=(uint8_t * )&pixels[n * (NSUInteger)imageSize.width + z];
            currentPixel[1]=255;
            currentPixel[2]=0;
            currentPixel[3]=0;
            z=maxY[i];
            currentPixel=(uint8_t * )&pixels[n * (NSUInteger)imageSize.width + z];
            currentPixel[1]=255;
            currentPixel[2]=0;
            currentPixel[3]=0;
        }
    }
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    
    //Releasing resources to free up memory
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    free(connectNumber);
    free(minX);
    free(minY);
    free(maxY);
    free(maxX);
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
