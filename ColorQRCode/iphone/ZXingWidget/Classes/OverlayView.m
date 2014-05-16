// -*- Mode: ObjC; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

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

#import "OverlayView.h"

static const CGFloat kPadding = 10;
static const CGFloat kLicenseButtonPadding = 10;

@interface OverlayView()
@property (nonatomic,assign) UIButton *cancelButton;
@property (nonatomic,assign) UIButton *okButton;
@property (nonatomic,assign) UIButton *lockButton;
@property (nonatomic,assign) UIButton *unlockButton;
@property (nonatomic,assign) UIButton *licenseButton;
@property (nonatomic,retain) UILabel *instructionsLabel;
@end


@implementation OverlayView

@synthesize delegate, oneDMode;
@synthesize points = _points;
@synthesize cancelButton;
@synthesize okButton;
@synthesize lockButton;
@synthesize unlockButton;
@synthesize licenseButton;
@synthesize cropRect;
@synthesize instructionsLabel;
@synthesize displayedMessage;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)theFrame cancelEnabled:(BOOL)isCancelEnabled oneDMode:(BOOL)isOneDModeEnabled {
  return [self initWithFrame:theFrame cancelEnabled:isCancelEnabled oneDMode:isOneDModeEnabled showLicense:YES];
}

- (id) initWithFrame:(CGRect)theFrame cancelEnabled:(BOOL)isCancelEnabled oneDMode:(BOOL)isOneDModeEnabled showLicense:(BOOL)showLicenseButton {
  self = [super initWithFrame:theFrame];
  if( self ) {

    CGFloat rectSize = self.frame.size.width - kPadding * 2;
    if (!oneDMode) {
      cropRect = CGRectMake(kPadding, (self.frame.size.height - rectSize) / 2, rectSize, rectSize);
    } else {
      CGFloat rectSize2 = self.frame.size.height - kPadding * 2;
      cropRect = CGRectMake(kPadding, kPadding, rectSize, rectSize2);		
    }

    self.backgroundColor = [UIColor clearColor];
    self.oneDMode = isOneDModeEnabled;
    if (isCancelEnabled) {
      UIButton *butt = [UIButton buttonWithType:UIButtonTypeRoundedRect]; 
      self.cancelButton = butt;
      [cancelButton setTitle:NSLocalizedStringWithDefaultValue(@"OverlayView cancel button title", nil, [NSBundle mainBundle], @"Cancel", @"Cancel") forState:UIControlStateNormal];
      if (oneDMode) {
        [cancelButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        
        [cancelButton setFrame:CGRectMake(20, 175, 45, 130)];
      }
      else {
          CGSize theSize = CGSizeMake(100, 50);
          CGRect theRect = CGRectMake((theFrame.size.width/2 - theSize.width) / 2 + theFrame.size.width/2, cropRect.origin.y + cropRect.size.height + 20, theSize.width, theSize.height);
          [cancelButton setFrame:theRect];
          
      }
        
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        UIButton *butt2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.okButton = butt2;
        [okButton setTitle:@"Save Image" forState:UIControlStateNormal];
        CGSize theSize2 = CGSizeMake(100, 50);
        CGRect theRect2 = CGRectMake((theFrame.size.width/2 - theSize2.width) / 2, cropRect.origin.y + cropRect.size.height + 20, theSize2.width, theSize2.height);
        [okButton setFrame:theRect2];
        
        [okButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:okButton];
        
/*        UIButton *butt3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.lockButton = butt3;
        [lockButton setTitle:@"Lock EV" forState:UIControlStateNormal];
        CGSize theSize3 = CGSizeMake(100, 50);
        CGRect theRect3 = CGRectMake((theFrame.size.width/2 - theSize3.width) / 2, cropRect.origin.y - 70, theSize3.width, theSize3.height);        
        [lockButton setFrame:theRect3];
        [lockButton addTarget:self action:@selector(lockexposure:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:lockButton];

        UIButton *butt4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.unlockButton = butt4;
        [unlockButton setTitle:@"Unlock EV" forState:UIControlStateNormal];
        CGSize theSize4 = CGSizeMake(100, 50);
        CGRect theRect4 = CGRectMake((theFrame.size.width/2 - theSize4.width) / 2 + theFrame.size.width/2, cropRect.origin.y - 70, theSize4.width, theSize4.height);
        [unlockButton setFrame:theRect4];
        [unlockButton addTarget:self action:@selector(unlockexposure:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:unlockButton]; */

        
      [self addSubview:imageView];
        
        
    }
      
/*    if (showLicenseButton) {
        self.licenseButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        
        CGRect lbFrame = [licenseButton frame];
        lbFrame.origin.x = self.frame.size.width - licenseButton.frame.size.width - kLicenseButtonPadding;
        lbFrame.origin.y = self.frame.size.height - licenseButton.frame.size.height - kLicenseButtonPadding;
        [licenseButton setFrame:lbFrame];
        [licenseButton addTarget:self action:@selector(showLicenseAlert:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:licenseButton];
    } */
  }
  return self;
}

- (void)cancel:(id)sender {
	// call delegate to cancel this scanner
	if (delegate != nil) {
		[delegate cancelled];
	}
}

- (void)confirm:(id)sender {
	// call delegate to cancel this scanner
	if (delegate != nil) {
		[delegate confirmed];
	}
}

- (void)lockexposure:(id)sender {
	// call delegate to cancel this scanner
	if (delegate != nil) {
		[delegate lockexposured];
	}
}

- (void)unlockexposure:(id)sender {
	// call delegate to cancel this scanner
	if (delegate != nil) {
		[delegate unlockexposured];
	}
}


- (void)showLicenseAlert:(id)sender {
    NSString *title = NSLocalizedStringWithDefaultValue(@"OverlayView license alert title", nil, [NSBundle mainBundle], @"License", @"License");
    NSString *message = NSLocalizedStringWithDefaultValue(@"OverlayView license alert message", nil, [NSBundle mainBundle], @"Scanning functionality provided by ZXing library, licensed under Apache 2.0 license.", @"Scanning functionality provided by ZXing library, licensed under Apache 2.0 license.");
    NSString *cancelTitle = NSLocalizedStringWithDefaultValue(@"OverlayView license alert cancel title", nil, [NSBundle mainBundle], @"OK", @"OK");
    NSString *viewTitle = NSLocalizedStringWithDefaultValue(@"OverlayView license alert view title", nil, [NSBundle mainBundle], @"View License", @"View License");

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:viewTitle, nil];
    [av show];
    [av release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apache.org/licenses/LICENSE-2.0.html"]];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
	[imageView release];
	[_points release];
  [instructionsLabel release];
  [displayedMessage release];
	[super dealloc];
}


- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context {
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
	CGContextStrokePath(context);
}

- (CGPoint)map:(CGPoint)point {
    CGPoint center;
    center.x = cropRect.size.width/2;
    center.y = cropRect.size.height/2;
    float x = point.x - center.x;
    float y = point.y - center.y;
    int rotation = 90;
    switch(rotation) {
    case 0:
        point.x = x;
        point.y = y;
        break;
    case 90:
        point.x = -y;
        point.y = x;
        break;
    case 180:
        point.x = -x;
        point.y = -y;
        break;
    case 270:
        point.x = y;
        point.y = -x;
        break;
    }
    point.x = point.x + center.x;
    point.y = point.y + center.y;
    return point;
}

#define kTextMargin 10

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
  if (displayedMessage == nil) {
    self.displayedMessage = NSLocalizedStringWithDefaultValue(@"OverlayView displayed message", nil, [NSBundle mainBundle], @"Place the QRCode inside the viewfinder rectangle to scan it.", @"Place the QRCode inside the viewfinder rectangle to scan it.");
  }
	CGContextRef c = UIGraphicsGetCurrentContext();
  
	if (nil != _points) {
    //		[imageView.image drawAtPoint:cropRect.origin];
	}
	
	CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
	CGContextSetStrokeColor(c, white);
	CGContextSetFillColor(c, white);
	[self drawRect:cropRect inContext:c];
	
  //	CGContextSetStrokeColor(c, white);
	//	CGContextSetStrokeColor(c, white);
	CGContextSaveGState(c);
	if (oneDMode) {
        NSString *text = NSLocalizedStringWithDefaultValue(@"OverlayView 1d instructions", nil, [NSBundle mainBundle], @"Place a red line over the bar code to be scanned.", @"Place a red line over the bar code to be scanned.");
        UIFont *helvetica15 = [UIFont fontWithName:@"Helvetica" size:15];
        CGSize textSize = [text sizeWithFont:helvetica15];
        
		CGContextRotateCTM(c, M_PI/2);
        // Invert height and width, because we are rotated.
        CGPoint textPoint = CGPointMake(self.bounds.size.height / 2 - textSize.width / 2, self.bounds.size.width * -1.0f + 20.0f);
        [text drawAtPoint:textPoint withFont:helvetica15];
	}
	else {
//    UIFont *font = [UIFont systemFontOfSize:18];
//    CGSize constraint = CGSizeMake(rect.size.width  - 2 * kTextMargin, cropRect.origin.y);
//    CGSize displaySize = [self.displayedMessage sizeWithFont:font constrainedToSize:constraint];
//    CGRect displayRect = CGRectMake((rect.size.width - displaySize.width) / 2 , cropRect.origin.y - displaySize.height, displaySize.width, displaySize.height);
//    [self.displayedMessage drawInRect:displayRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	}
	CGContextRestoreGState(c);
	int offset = rect.size.width / 2;
	if (oneDMode) {
		CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
		CGContextSetStrokeColor(c, red);
		CGContextSetFillColor(c, red);
		CGContextBeginPath(c);
		//		CGContextMoveToPoint(c, rect.origin.x + kPadding, rect.origin.y + offset);
		//		CGContextAddLineToPoint(c, rect.origin.x + rect.size.width - kPadding, rect.origin.y + offset);
		CGContextMoveToPoint(c, rect.origin.x + offset, rect.origin.y + kPadding);
		CGContextAddLineToPoint(c, rect.origin.x + offset, rect.origin.y + rect.size.height - kPadding);
		CGContextStrokePath(c);
	}
	if( nil != _points ) {
		CGFloat blue[4] = {0.0f, 1.0f, 0.0f, 1.0f};
		CGContextSetStrokeColor(c, blue);
		CGContextSetFillColor(c, blue);
		if (oneDMode) {
			CGPoint val1 = [self map:[[_points objectAtIndex:0] CGPointValue]];
			CGPoint val2 = [self map:[[_points objectAtIndex:1] CGPointValue]];
			CGContextMoveToPoint(c, offset, val1.x);
			CGContextAddLineToPoint(c, offset, val2.x);
			CGContextStrokePath(c);
		}
		else {
			CGRect smallSquare = CGRectMake(0, 0, 10, 10);
			for( NSValue* value in _points ) {
				CGPoint point = [self map:[value CGPointValue]];
				smallSquare.origin = CGPointMake(
                                         cropRect.origin.x + point.x - smallSquare.size.width / 2,
                                         cropRect.origin.y + point.y - smallSquare.size.height / 2);
				[self drawRect:smallSquare inContext:c];
			}
		}
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 - (void) setImage:(UIImage*)image {
 //if( nil == imageView ) {
// imageView = [[UIImageView alloc] initWithImage:image];
// imageView.alpha = 0.5;
// } else {
 imageView.image = image;
 //}
 
 //CGRect frame = imageView.frame;
 //frame.origin.x = self.cropRect.origin.x;
 //frame.origin.y = self.cropRect.origin.y;
 //imageView.frame = CGRectMake(0,0, 30, 50);
 
 //[_points release];
 //_points = nil;
 //self.backgroundColor = [UIColor clearColor];
 
 //[self setNeedsDisplay];
 }
 */

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*) image {
	return imageView.image;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPoints:(NSMutableArray*)pnts {
    [pnts retain];
    [_points release];
    _points = pnts;
	
    if (pnts != nil) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    }
    [self setNeedsDisplay];
}

- (void) setPoint:(CGPoint)point {
    if (!_points) {
        _points = [[NSMutableArray alloc] init];
    }
    if (_points.count > 3) {
        [_points removeObjectAtIndex:0];
    }
    [_points addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplay];
}


@end
