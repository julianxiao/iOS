//
//  MagicBorder.h
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-13.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzView.h"
#import "TBXML.h"
#import "Design.h"
#import "Element.h"
#import "Menuitem.h"
#import "Image.h"
#import "VersionMenu.h"
#import "Frame.h"
#import "Border.h"
#import "Text.h"
#import "RepObject.h"
#import "DrawingObject.h"

@interface MagicBorder : QuartzView {
	// private variables for public properties
	NSData		*_borderXML;
	CGFloat		_bmapWidth;
	CGFloat		_bmapHeight;
	UIImage		* _bmd;
	NSString	* _imageUR;
	NSString	* _textureURL;
	NSString	* _imageMode;
	CGFloat		_ppi;
	CGFloat		_layoutAreaAlpha;
	NSInteger	_version;
	NSInteger	_setScale;
	
	// private variables to keep track of status of properties
	BOOL		sourceChanged;
	BOOL		borderXMLChanged;
	BOOL		imageChanged;
	BOOL		virtualSizeChanged;
	BOOL		ppiChanged;
	BOOL		layoutAreaAlphaChanged;
	BOOL		setScaleChanged;
	
	// public variables
	UIImage		* densityBMD;
	CGFloat		drawWidth;
	CGFloat		drawHeight;
	CGFloat		_virtualWidth;
	CGFloat		_virtualHeight;
	TBXML * tbxml;
	Design * design;
	
	NSMutableArray *listViews;
	
	NSString *backgroundname;
	int			dversion;
	CGRect		viewRect;
}

@property (nonatomic, retain) NSData	*_borderXML;
@property (nonatomic, retain) Design	*design;
@property (nonatomic, retain) TBXML * tbxml;
@property (nonatomic, retain) UIImage	* _bmd;
@property (nonatomic, retain) NSString	* _imageUR;
@property (nonatomic, retain) NSString	* _textureURL;
@property (nonatomic, retain) NSString	* _imageMode;
@property (nonatomic, assign) CGFloat	_bmapWidth;
@property (nonatomic, assign) CGFloat	_bmapHeight;
@property (nonatomic, assign) CGFloat	_ppi;
@property (nonatomic, assign) CGFloat	_layoutAreaAlpha;
@property (nonatomic, assign) NSInteger	_version;
@property (nonatomic, assign) NSInteger	_setScale;
@property (nonatomic, assign) BOOL		sourceChanged;
@property (nonatomic, assign) BOOL		borderXMLChanged;
@property (nonatomic, assign) BOOL		imageChanged;
@property (nonatomic, assign) BOOL		virtualSizeChanged;
@property (nonatomic, assign) BOOL		ppiChanged;
@property (nonatomic, assign) BOOL		layoutAreaAlphaChanged;
@property (nonatomic, assign) BOOL		setScaleChanged;
@property (nonatomic, retain) UIImage	* densityBMD;
@property (nonatomic, assign) CGFloat	drawWidth;
@property (nonatomic, assign) CGFloat	drawHeight;
@property (nonatomic, retain) NSMutableArray *listViews;
@property (nonatomic, retain) NSString  *backgroundname;
@property (nonatomic, assign) int		dversion;
@property (nonatomic, assign) CGRect	viewRect;
@property (nonatomic, assign) CGFloat	_virtualWidth;
@property (nonatomic, assign) CGFloat	_virtualHeight;

- (void) prepare;
- (void) loadXmlFile;
- (void) composeThread: (id) target;
-(int)generateRandomNumber:(int)maxnum;
-(void)drawInContext:(CGContextRef)context;
-(void)setDesignVersion:(Design *)d isRandomize:(BOOL)randomize;
-(void)composeBorder:(CGFloat)thisPPI Rect:(CGRect)rect DensityMap:(BOOL)densityMap DoCutout:(BOOL)doCutout LayoutAreaChanged:(BOOL)layoutAreaChanged;
-(void)composeElement:(UIView *)can Box:(CGRect)box Design:(Design *)d DensityMap:(BOOL)densityMap DoCutout:(BOOL)doCutout;
-(BOOL)checkMode:(Element *)e Design:(Design *)d;
-(CGAffineTransform)cornerFixedTransformWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)elem;
-(CGAffineTransform)cornerFlexTransformWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)elem;
-(CGAffineTransform)backgroundTransformWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)e;
-(CGAffineTransform)foregroundTransformWithDegin:(Design *)d PageBox:(CGRect)pageBox Position:(NSString *)position Elment:(Element *)e;
-(CGAffineTransform)transformGrammaWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)elem;
-(CGRect)transformBox:(CGRect)box Matrix:(CGAffineTransform)matrix;
-(CGRect)getRepeatingBoxSizeWithDesign:(CGRect)rootBox Design:(Design *)d Element:(Element *)elem Box:(CGRect)box;
-(DrawingObject *)getDrawingParamsWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)elem;
-(RepObject *)getRepeatingCountWithPageBox:(CGRect)pageBox Elment:(Element *)elem Matrix:(CGAffineTransform)mat Box:(CGRect)box;

@end
