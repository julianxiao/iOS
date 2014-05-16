// -*- mode:objc; c-basic-offset:2; indent-tabs-mode:nil -*-
/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXingWidgetController.h"
#import "Decoder.h"
#import "NSString+HTML.h"
#import "ResultParser.h"
#import "ParsedResult.h"
#import "ResultAction.h"
#import "TwoDDecoderResult.h"

#import "GPUImage.h"


#include <sys/types.h>
#include <sys/sysctl.h>

#import <AVFoundation/AVFoundation.h>

#define CAMERA_SCALAR 1.12412 // scalar = (480 / (2048 / 480))
#define FIRST_TAKE_DELAY 1.0
#define ONE_D_BAND_HEIGHT 10.0

@interface ZXingWidgetController ()

@property BOOL showCancel;
@property BOOL showLicense;
@property BOOL oneDMode;
@property BOOL isStatusBarHidden;
@property int filecounter;

- (void)initCapture;
- (void)stopCapture;

@end

@implementation ZXingWidgetController

#if HAS_AVFF
@synthesize captureSession;
@synthesize prevLayer;
#endif
@synthesize result, delegate, soundToPlay;
@synthesize overlayView;
@synthesize oneDMode, showCancel, showLicense, isStatusBarHidden;
@synthesize readers;


- (id)initWithDelegate:(id<ZXingDelegate>)scanDelegate showCancel:(BOOL)shouldShowCancel OneDMode:(BOOL)shouldUseoOneDMode {
    
  //  [self setTorch:TRUE];
    self.filecounter = 0;
    saveFile = FALSE;
    
  
    return [self initWithDelegate:scanDelegate showCancel:shouldShowCancel OneDMode:shouldUseoOneDMode showLicense:YES];
}

- (id)initWithDelegate:(id<ZXingDelegate>)scanDelegate showCancel:(BOOL)shouldShowCancel OneDMode:(BOOL)shouldUseoOneDMode showLicense:(BOOL)shouldShowLicense {
  self = [super init];
  if (self) {
    [self setDelegate:scanDelegate];
    self.oneDMode = shouldUseoOneDMode;
    self.showCancel = shouldShowCancel;
    self.showLicense = shouldShowLicense;
    self.wantsFullScreenLayout = YES;
    beepSound = -1;
    decoding = NO;
    OverlayView *theOverLayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds 
                                                       cancelEnabled:showCancel 
                                                            oneDMode:oneDMode
                                                         showLicense:shouldShowLicense];
    [theOverLayView setDelegate:self];
    self.overlayView = theOverLayView;
    [theOverLayView release];
      
      UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraViewTapAction:)];
      [self.overlayView addGestureRecognizer:tgr];
  }
  
  return self;
}



- (void)cameraViewTapAction:(UITapGestureRecognizer *)tgr
{
    if (tgr.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [tgr locationInView:self.overlayView];
        
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        CGPoint pointOfInterest = CGPointMake(.5f, .5f);
        NSLog(@"taplocation x = %f y = %f", location.x, location.y);
        CGSize frameSize = [[self overlayView] frame].size;
        

            location.x = frameSize.width - location.x;

        
        pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
 //               [device setFocusPointOfInterest:pointOfInterest];
                
 //               [device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeLocked])
                {
                    
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
   //                 [device setExposureMode:AVCaptureExposureModeLocked];
                }
                
                [device unlockForConfiguration];
                
                NSLog(@"exposure OK");
            } else {
                NSLog(@"ERROR = %@", error);
            }  
        }
    }
}

- (void)dealloc {
  if (beepSound != (SystemSoundID)-1) {
    AudioServicesDisposeSystemSoundID(beepSound);
  }
  
  [self stopCapture];

  [result release];
  [soundToPlay release];
  [overlayView release];
  [readers release];
  [super dealloc];
}

- (void)cancelled {
    

  [self stopCapture];
  if (!self.isStatusBarHidden) {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
  }

  wasCancelled = YES;
  if (delegate != nil) {
    [delegate zxingControllerDidCancel:self]; 
  } 
}

- (void)confirmed {
    decoding = YES;
    self.filecounter ++;
    saveFile = TRUE;

}

- (void)lockexposured {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            //               [device setFocusPointOfInterest:pointOfInterest];
            
            //               [device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeLocked])
            {
                
 //               [device setExposurePointOfInterest:pointOfInterest];
      //          [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                                 [device setExposureMode:AVCaptureExposureModeLocked];
            }
            
            [device unlockForConfiguration];
            
            NSLog(@"exposure OK");
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }

}

- (void)unlockexposured {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            //               [device setFocusPointOfInterest:pointOfInterest];
            
            //               [device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeLocked])
            {
                
                //               [device setExposurePointOfInterest:pointOfInterest];
                          [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
               // [device setExposureMode:AVCaptureExposureModeLocked];
            }
            
            [device unlockForConfiguration];
            
            NSLog(@"exposure OK");
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
    
}


- (NSString *)getPlatform {
  size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char *machine = malloc(size);
  sysctlbyname("hw.machine", machine, &size, NULL, 0);
  NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
  free(machine);
  return platform;
}

- (BOOL)fixedFocus {
  NSString *platform = [self getPlatform];
  if ([platform isEqualToString:@"iPhone1,1"] ||
      [platform isEqualToString:@"iPhone1,2"]) return YES;
  return NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.wantsFullScreenLayout = YES;
  if ([self soundToPlay] != nil) {
    OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)[self soundToPlay], &beepSound);
    if (error != kAudioServicesNoError) {
      NSLog(@"Problem loading nearSound.caf");
    }
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.isStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
  if (!isStatusBarHidden)
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

  decoding = YES;

  [self initCapture];
  [self.view addSubview:overlayView];
  
  [overlayView setPoints:nil];
  wasCancelled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  if (!isStatusBarHidden)
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [self.overlayView removeFromSuperview];
  [self stopCapture];
}

- (CGImageRef)CGImageRotated90:(CGImageRef)imgRef
{
  CGFloat angleInRadians = -90 * (M_PI / 180);
  CGFloat width = CGImageGetWidth(imgRef);
  CGFloat height = CGImageGetHeight(imgRef);
  
  CGRect imgRect = CGRectMake(0, 0, width, height);
  CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
  CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                 rotatedRect.size.width,
                                                 rotatedRect.size.height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
  CGContextSetAllowsAntialiasing(bmContext, FALSE);
  CGContextSetInterpolationQuality(bmContext, kCGInterpolationNone);
  CGColorSpaceRelease(colorSpace);
  //      CGContextTranslateCTM(bmContext,
  //                                                +(rotatedRect.size.width/2),
  //                                                +(rotatedRect.size.height/2));
  CGContextScaleCTM(bmContext, rotatedRect.size.width/rotatedRect.size.height, 1.0);
  CGContextTranslateCTM(bmContext, 0.0, rotatedRect.size.height);
  CGContextRotateCTM(bmContext, angleInRadians);
  //      CGContextTranslateCTM(bmContext,
  //                                                -(rotatedRect.size.width/2),
  //                                                -(rotatedRect.size.height/2));
  CGContextDrawImage(bmContext, CGRectMake(0, 0,
                                           rotatedRect.size.width,
                                           rotatedRect.size.height),
                     imgRef);
  
  CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
  CFRelease(bmContext);
  [(id)rotatedImage autorelease];
  
  return rotatedImage;
}

- (CGImageRef)CGImageRotated180:(CGImageRef)imgRef
{
  CGFloat angleInRadians = M_PI;
  CGFloat width = CGImageGetWidth(imgRef);
  CGFloat height = CGImageGetHeight(imgRef);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
  CGContextSetAllowsAntialiasing(bmContext, FALSE);
  CGContextSetInterpolationQuality(bmContext, kCGInterpolationNone);
  CGColorSpaceRelease(colorSpace);
  CGContextTranslateCTM(bmContext,
                        +(width/2),
                        +(height/2));
  CGContextRotateCTM(bmContext, angleInRadians);
  CGContextTranslateCTM(bmContext,
                        -(width/2),
                        -(height/2));
  CGContextDrawImage(bmContext, CGRectMake(0, 0, width, height), imgRef);
  
  CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
  CFRelease(bmContext);
  [(id)rotatedImage autorelease];
  
  return rotatedImage;
}

// DecoderDelegate methods

- (void)decoder:(Decoder *)decoder willDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset{
#ifdef DEBUG
  NSLog(@"DecoderViewController MessageWhileDecodingWithDimensions: Decoding image (%.0fx%.0f) ...", image.size.width, image.size.height);
#endif
}

- (void)decoder:(Decoder *)decoder
  decodingImage:(UIImage *)image
     usingSubset:(UIImage *)subset {
}

- (void)presentResultForString:(NSString *)resultString {
  self.result = [ResultParser parsedResultForString:resultString];
  if (beepSound != (SystemSoundID)-1) {
    AudioServicesPlaySystemSound(beepSound);
  }
    
  NSLog(@"result string = %@", self.result.stringForDisplay);
    
 // NSLog(@"result string = %@", resultString);

}

- (void)presentResultPoints:(NSArray *)resultPoints
                   forImage:(UIImage *)image
                usingSubset:(UIImage *)subset {
  // simply add the points to the image view
  NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:resultPoints];
  [overlayView setPoints:mutableArray];
  [mutableArray release];
}

- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)twoDResult {
  [self presentResultForString:[twoDResult text]];
  [self presentResultPoints:[twoDResult points] forImage:image usingSubset:subset];
  // now, in a selector, call the delegate to give this overlay time to show the points
    
    NSString *tmpString = [[twoDResult text] substringFromIndex:4];
    NSString *idString = @"id: ";
    NSString *displaytext = [idString stringByAppendingString:tmpString];
  [self performSelector:@selector(notifyDelegate:) withObject:[displaytext copy] afterDelay:0.0];
  decoder.delegate = nil;
}

- (void)notifyDelegate:(id)text {
  if (!isStatusBarHidden) [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [delegate zxingController:self didScanResult:text];
  [text release];
}

- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
  decoder.delegate = nil;
  [overlayView setPoints:nil];
}

- (void)decoder:(Decoder *)decoder foundPossibleResultPoint:(CGPoint)point {
  [overlayView setPoint:point];
}

/*
- (void)stopPreview:(NSNotification*)notification {
  // NSLog(@"stop preview");
}

- (void)notification:(NSNotification*)notification {
  // NSLog(@"notification %@", notification.name);
}
*/

#pragma mark - 
#pragma mark AVFoundation

#include <sys/types.h>
#include <sys/sysctl.h>

// Gross, I know. But you can't use the device idiom because it's not iPad when running
// in zoomed iphone mode but the camera still acts like an ipad.
#if HAS_AVFF
static bool isIPad() {
  static int is_ipad = -1;
  if (is_ipad < 0) {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0); // Get size of data to be returned.
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    NSString *machine = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
    free(name);
    is_ipad = [machine hasPrefix:@"iPad"];
  }
  return !!is_ipad;
}
#endif
    
- (void)initCapture {
#if HAS_AVFF
  AVCaptureDevice* inputDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  AVCaptureDeviceInput *captureInput =
    [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
  AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init]; 
  captureOutput.alwaysDiscardsLateVideoFrames = YES; 
  [captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
  NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
  NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
  NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
  [captureOutput setVideoSettings:videoSettings]; 
  self.captureSession = [[[AVCaptureSession alloc] init] autorelease];

  NSString* preset = 0;
  if (NSClassFromString(@"NSOrderedSet") && // Proxy for "is this iOS 5" ...
      [UIScreen mainScreen].scale > 1 &&
      isIPad() && 
      [inputDevice
        supportsAVCaptureSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
    // NSLog(@"960");
    preset = AVCaptureSessionPresetiFrame960x540;
  }
  if (!preset) {
    // NSLog(@"MED");
    preset = AVCaptureSessionPresetMedium;
  }
  self.captureSession.sessionPreset = preset;

  [self.captureSession addInput:captureInput];
  [self.captureSession addOutput:captureOutput];

  [captureOutput release];

/*
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(stopPreview:)
             name:AVCaptureSessionDidStopRunningNotification
           object:self.captureSession];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(notification:)
             name:AVCaptureSessionDidStopRunningNotification
           object:self.captureSession];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(notification:)
             name:AVCaptureSessionRuntimeErrorNotification
           object:self.captureSession];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(notification:)
             name:AVCaptureSessionDidStartRunningNotification
           object:self.captureSession];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(notification:)
             name:AVCaptureSessionWasInterruptedNotification
           object:self.captureSession];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(notification:)
             name:AVCaptureSessionInterruptionEndedNotification
           object:self.captureSession];
*/

  if (!self.prevLayer) {
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
  }
  // NSLog(@"prev %p %@", self.prevLayer, self.prevLayer);
  self.prevLayer.frame = self.view.bounds;
  self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  [self.view.layer addSublayer: self.prevLayer];

  [self.captureSession startRunning];
#endif
}

#if HAS_AVFF

- (UIImage *) convertToGreyscale:(UIImage *)inputImage {
    
/*    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, inputImage.size.width * inputImage.scale, inputImage.size.height * inputImage.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [inputImage CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:inputImage.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage; */
    
    CGImageRef imgRef = [inputImage CGImage];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    int totalBytes = bytesPerRow * height;
    
    //Allocate Image space
    uint8_t* rawData = malloc(totalBytes);
    
    //Create Bitmap of same size
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //Draw our image to the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
    //Perform Brightness Manipulation
    for ( int i = 0; i < totalBytes; i += 4 ) {
        
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
        
        *red = 255- *blue;
        *green = 255- *blue;
        *blue = 255- *blue;
        
  //      *red = MIN(255,MAX(0, roundf(contrastFactor*(*red - 127.5f)) + 128));
   //     *green = MIN(255,MAX(0, roundf(contrastFactor*(*green - 127.5f)) + 128));
    //    *blue = MIN(255,MAX(0, roundf(contrastFactor*(*blue - 127.5f)) + 128));
        

        
    }
    
    //Create Image
    CGImageRef newImg = CGBitmapContextCreateImage(context);
    
    //Release Created Data Structs
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
    
    //Create UIImage struct around image
    UIImage* image = [UIImage imageWithCGImage:newImg];
    
    //Release our hold on the image
    CGImageRelease(newImg);
    
    //return new image!
    return image;
    

    
 /*   CIImage *beginImage = [CIImage imageWithCGImage:[inputImage CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *colorMonochrome =
    [CIFilter filterWithName:@"CIColorMonochrome"];
    [colorMonochrome setDefaults];
    [colorMonochrome setValue: beginImage
                       forKey: @"inputImage"];
    [colorMonochrome setValue:
     [CIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f]
                       forKey: @"inputColor"];
    
    CIImage *outputImage = [colorMonochrome outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    
    CGImageRelease(cgimg);
    return newImg; */

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection 
{ 
  if (!decoding) {
    return;
  }
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
  /*Lock the image buffer*/
  CVPixelBufferLockBaseAddress(imageBuffer,0); 
  /*Get information about the image*/
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
  size_t width = CVPixelBufferGetWidth(imageBuffer); 
  size_t height = CVPixelBufferGetHeight(imageBuffer); 
    
  uint8_t* baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
  void* free_me = 0;
  if (true) { // iOS bug?
    uint8_t* tmp = baseAddress;
    int bytes = bytesPerRow*height;
    free_me = baseAddress = (uint8_t*)malloc(bytes);
    baseAddress[0] = 0xdb;
    memcpy(baseAddress,tmp,bytes);
  }

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
  CGContextRef newContext =
    CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,
                          kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst); 

  CGImageRef capture = CGBitmapContextCreateImage(newContext); 
  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  free(free_me);

  CGContextRelease(newContext); 
  CGColorSpaceRelease(colorSpace);

  CGRect cropRect = [overlayView cropRect];
  if (oneDMode) {
    // let's just give the decoder a vertical band right above the red line
    cropRect.origin.x = cropRect.origin.x + (cropRect.size.width / 2) - (ONE_D_BAND_HEIGHT + 1);
    cropRect.size.width = ONE_D_BAND_HEIGHT;
    // do a rotate
    CGImageRef croppedImg = CGImageCreateWithImageInRect(capture, cropRect);
    CGImageRelease(capture);
    capture = [self CGImageRotated90:croppedImg];
    capture = [self CGImageRotated180:capture];
    //              UIImageWriteToSavedPhotosAlbum([UIImage imageWithCGImage:capture], nil, nil, nil);
    CGImageRelease(croppedImg);
    CGImageRetain(capture);
    cropRect.origin.x = 0.0;
    cropRect.origin.y = 0.0;
    cropRect.size.width = CGImageGetWidth(capture);
    cropRect.size.height = CGImageGetHeight(capture);
  }

  // N.B.
  // - Won't work if the overlay becomes uncentered ...
  // - iOS always takes videos in landscape
  // - images are always 4x3; device is not
  // - iOS uses virtual pixels for non-image stuff

  {
    float height = CGImageGetHeight(capture);
    float width = CGImageGetWidth(capture);

    CGRect screen = UIScreen.mainScreen.bounds;
    float tmp = screen.size.width;
    screen.size.width = screen.size.height;;
    screen.size.height = tmp;

    cropRect.origin.x = (width-cropRect.size.width)/2;
    cropRect.origin.y = (height-cropRect.size.height)/2;
  }
  CGImageRef newImage = CGImageCreateWithImageInRect(capture, cropRect);
  CGImageRelease(capture);
  UIImage *scrn = [[UIImage alloc] initWithCGImage:newImage];
    
/*    Decoder *d = [[Decoder alloc] init];
    d.readers = readers;
    d.delegate = self;
    cropRect.origin.x = 0.0;
    cropRect.origin.y = 0.0;
    decoding = [d decodeImage:scrn cropRect:cropRect] == YES ? NO : YES;
    [d release];
    [scrn release]; */


 /*   GPUImageColorMatrixFilter *stillImageFilter2 = [[GPUImageColorMatrixFilter alloc] init];
    
    stillImageFilter2.intensity = 1.f;
    stillImageFilter2.colorMatrix = (GPUMatrix4x4){
        {-0.5f, 0.f, 0.f, 0.f},
        {0.f, -0.5f, 0.f, 0.f},
        {0.f, 0.f, 1.f, 0.f},
        {0.f, 0.f, 0.f, 1.f}
    };
   UIImage *filteredImage = [stillImageFilter2 imageByFilteringImage:scrn]; */
    
//    GPUImageColorInvertFilter *stillImageFilter = [[GPUImageColorInvertFilter alloc] init];
//   UIImage *filteredImage = [stillImageFilter imageByFilteringImage:scrn];
    
     UIImage *quickFilteredImage = [self convertToGreyscale:scrn];
    
    
/*    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:quickFilteredImage];
    GPUImageColorInvertFilter *stillImageFilter = [[GPUImageColorInvertFilter alloc] init];
    [stillImageSource addTarget:stillImageFilter];
    [stillImageSource processImage];
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentlyProcessedOutput]; */
    
    if(saveFile)
    {
    
        NSData *data1 = UIImageJPEGRepresentation(scrn, 1.0);
        NSData *data2 = UIImageJPEGRepresentation(quickFilteredImage, 1.0);
//        NSData *data3 = UIImageJPEGRepresentation(filteredImage, 1.0);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filename1 = [NSString stringWithFormat: @"CameraImage%d.jpg", self.filecounter];
        NSString *filename2 = [NSString stringWithFormat: @"ConvertedImage%d.jpg", self.filecounter];
        NSString *fullPath1 = [documentsDirectory stringByAppendingPathComponent:filename1];
        NSString *fullPath2 = [documentsDirectory stringByAppendingPathComponent:filename2];
//        NSString *fullPath3 = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%d-3.jpg", self.filecounter]];
        [fileManager createFileAtPath:fullPath1 contents:data1 attributes:nil];
        [fileManager createFileAtPath:fullPath2 contents:data2 attributes:nil];
//        [fileManager createFileAtPath:fullPath3 contents:data3 attributes:nil];
        saveFile = false;
    }
    

    
  CGImageRelease(newImage);
    
  Decoder *d = [[Decoder alloc] init];
  d.readers = readers;
  d.delegate = self;
  cropRect.origin.x = 0.0;  
  cropRect.origin.y = 0.0;
 // decoding = [d decodeImage:scrn cropRect:cropRect] == YES ? NO : YES;
    decoding = [d decodeImage:quickFilteredImage cropRect:cropRect] == YES ? NO : YES;
  [d release];
  [scrn release]; 
    
  //  [currentFilteredVideoFrame release];
} 
#endif


- (void)stopCapture {
    

    
  decoding = NO;
#if HAS_AVFF
  [captureSession stopRunning];
  AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
  [captureSession removeInput:input];
  AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[captureSession.outputs objectAtIndex:0];
  [captureSession removeOutput:output];
  [self.prevLayer removeFromSuperlayer];

  self.prevLayer = nil;
  self.captureSession = nil;
#endif
}


#pragma mark - Torch

- (void)setTorch:(BOOL)status {
#if HAS_AVFF
  Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
  if (captureDeviceClass != nil) {
    
    AVCaptureDevice *device = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [device lockForConfiguration:nil];
    if ( [device hasTorch] ) {
      if ( status ) {
        [device setTorchMode:AVCaptureTorchModeOn];
      } else {
        [device setTorchMode:AVCaptureTorchModeOff];
      }
    }
    [device unlockForConfiguration];
    
  }
#endif
}

- (BOOL)torchIsOn {
#if HAS_AVFF
  Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
  if (captureDeviceClass != nil) {
    
    AVCaptureDevice *device = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ( [device hasTorch] ) {
      return [device torchMode] == AVCaptureTorchModeOn;
    }
    [device unlockForConfiguration];
  }
#endif
  return NO;
}

@end
