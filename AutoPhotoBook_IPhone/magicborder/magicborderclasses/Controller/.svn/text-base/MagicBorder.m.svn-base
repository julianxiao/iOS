//
//  MagicBorder.m
//  MagicPhotoBook
//
//  Created by Fujunhua on 10-3-13.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "MagicBorder.h"
#import "Utils.h"
#import <stdlib.h>
#import <time.h>

@implementation MagicBorder

@synthesize _borderXML, _bmapWidth, _bmapHeight, _bmd, _imageUR, _textureURL, _imageMode, _ppi, _layoutAreaAlpha, _version, _setScale;
@synthesize sourceChanged, borderXMLChanged, imageChanged, virtualSizeChanged, ppiChanged, layoutAreaAlphaChanged, setScaleChanged;
@synthesize densityBMD, drawWidth, drawHeight;
@synthesize listViews;
@synthesize backgroundname;
@synthesize dversion, viewRect, _virtualWidth, _virtualHeight;
@synthesize design,tbxml;

//const CGFloat		_virtualWidth	  = 16;//16;//11;
//const CGFloat		_virtualHeight	  = 28;//28;//8.5;
const int			DRAW_OFFSET		  = 0;

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self != nil)
	{
		//[self prepare];
	}
	return self;
}

- (void) prepare{
	if (dversion < 0) {
		dversion = [self generateRandomNumber:9];
	}
	_virtualWidth = viewRect.size.width/_ppi;
	_virtualHeight = viewRect.size.height/_ppi;
	self.listViews = [[[NSMutableArray alloc] init] autorelease];
	[self loadXmlFile];
	//[self performSelectorInBackground: @selector(composeThread:) withObject: self];
	[self composeThread: self];
}

- (void) composeThread: (id) target{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CGRect r = CGRectMake(0, 0, 0, 0);
	[target composeBorder:_ppi Rect:r DensityMap:FALSE DoCutout:FALSE LayoutAreaChanged:FALSE];
	[target setNeedsDisplay];
	[pool release];
}

-(void)dealloc
{
	[tbxml release];
	[design release];
	[_borderXML release];
	[_bmd release];
	[_imageUR release];
	[_textureURL release];
	[_imageMode release];
	[densityBMD release];
	[listViews release];
	[backgroundname release];
	[super dealloc];
}

- (void) loadXmlFile
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.design = [[[Design alloc] init] autorelease]; 
	
	// Load and parse the books.xml file
	self.tbxml = [TBXML tbxmlWithXMLData:_borderXML];
	
	// Obtain root element
	TBXMLElement * aDesign = tbxml.rootXMLElement;
	// if root element is valid
	if (aDesign) {
		// get the name attribute from the author element
		design.name = [TBXML valueOfAttributeNamed:@"name" forElement:aDesign];
		// get the icon attribute from the author element
		design.icon = [TBXML valueOfAttributeNamed:@"icon" forElement:aDesign];
		// get the style attribute from the author element
		design.style = [TBXML valueOfAttributeNamed:@"style" forElement:aDesign];
		// get the layout attribute from the author element
		design.layout = [TBXML valueOfAttributeNamed:@"layout" forElement:aDesign];
		// get the layoutDensityAmp attribute from the author element
		design.layoutDensityAmp = [TBXML valueOfAttributeNamed:@"layoutDensityAmp" forElement:aDesign];
		// get the layoutDensityBlur attribute from the author element
		design.layoutDensityBlur = [TBXML valueOfAttributeNamed:@"layoutDensityBlur" forElement:aDesign];
		// get the layoutDensityChannel attribute from the author element
		design.layoutDensityChannel = [TBXML valueOfAttributeNamed:@"layoutDensityChannel" forElement:aDesign];
		// get the layoutDensityOffset attribute from the author element
		design.layoutDensityOffset = [TBXML valueOfAttributeNamed:@"layoutDensityOffset" forElement:aDesign];
		// get the maxItemSize attribute from the author element
		design.maxItemSize = [TBXML valueOfAttributeNamed:@"maxItemSize" forElement:aDesign];
		// get the minItemSize attribute from the author element
		design.minItemSize = [TBXML valueOfAttributeNamed:@"minItemSize" forElement:aDesign];
		// get the sparseFactor attribute from the author element
		design.sparseFactor = [TBXML valueOfAttributeNamed:@"sparseFactor" forElement:aDesign];
		// get the scaleWithItems attribute from the author element
		design.scaleWithItems = [TBXML valueOfAttributeNamed:@"scaleWithItems" forElement:aDesign];
		// get the leftMargin attribute from the author element
		design.leftMargin = [TBXML valueOfAttributeNamed:@"leftMargin" forElement:aDesign];
		// get the rightMargin attribute from the author element
		design.rightMargin = [TBXML valueOfAttributeNamed:@"rightMargin" forElement:aDesign];
		// get the topMargin attribute from the author element
		design.topMargin = [TBXML valueOfAttributeNamed:@"topMargin" forElement:aDesign];
		// get the bottomMargin attribute from the author element
		design.bottomMargin = [TBXML valueOfAttributeNamed:@"bottomMargin" forElement:aDesign];
		// get the itemGap attribute from the author element
		design.itemGap = [TBXML valueOfAttributeNamed:@"itemGap" forElement:aDesign];
		// get the type attribute from the author element
		design.type = [TBXML valueOfAttributeNamed:@"type" forElement:aDesign];
		// get the width attribute from the author element
		design.width = [TBXML valueOfAttributeNamed:@"width" forElement:aDesign];
		// get the height attribute from the author element
		design.height = [TBXML valueOfAttributeNamed:@"height" forElement:aDesign];
		// get the x attribute from the author element
		design.x = [TBXML valueOfAttributeNamed:@"x" forElement:aDesign];
		// get the y attribute from the author element
		design.y = [TBXML valueOfAttributeNamed:@"y" forElement:aDesign];
		// get the version attribute from the author element
		design.version = [TBXML valueOfAttributeNamed:@"version" forElement:aDesign];
		// get the numRandomVersions attribute from the author element
		design.numRandomVersions = [TBXML valueOfAttributeNamed:@"numRandomVersions" forElement:aDesign];
		// get the numModes attribute from the author element
		design.numModes = [TBXML valueOfAttributeNamed:@"numModes" forElement:aDesign];
		// get the defaultNumItems attribute from the author element
		design.defaultNumItems = [TBXML valueOfAttributeNamed:@"defaultNumItems" forElement:aDesign];
		// get the mode attribute from the author element
		design.mode = [TBXML valueOfAttributeNamed:@"mode" forElement:aDesign];
		
		// search the aDesign's child elements for a versionMenu element
		TBXMLElement * versionMenu = [TBXML childElementNamed:@"versionMenu" parentElement:aDesign];
		
		// if a versionMenu element was found
		if (versionMenu != nil) {
			
			// instantiate a VersionMenu object
			VersionMenu * aVersionMenu = [[VersionMenu alloc] init];
			
			// extract the id attribute from the versionMenu element
			aVersionMenu.vid = [TBXML valueOfAttributeNamed:@"id" forElement:versionMenu];
			
			// search the versionMenu's child elements for a menuitem element
			TBXMLElement * menuitem = [TBXML childElementNamed:@"menuitem" parentElement:versionMenu];
			
			while (menuitem != nil) {
				// instantiate a Menuitem object
				Menuitem * aMenuitem = [[Menuitem alloc] init];
				
				// extract the label attribute from the menuitem element
				aMenuitem.label = [TBXML valueOfAttributeNamed:@"label" forElement:menuitem];
				
				// extract the imagesrc attribute from the menuitem element
				aMenuitem.imagesrc = [TBXML valueOfAttributeNamed:@"imagesrc" forElement:menuitem];
				
				[aVersionMenu.menuitems addObject:aMenuitem];
				
				[aMenuitem release];
				
				// find the next sibling element named "menuitem"
				menuitem = [TBXML nextSiblingNamed:@"menuitem" searchFromElement:menuitem];
			}
			
			[design setVersionMenu:aVersionMenu]; 
			[aVersionMenu release];
			
		}
		
		// search the aDesign's child elements for a frame element
		TBXMLElement * frame = [TBXML childElementNamed:@"frame" parentElement:aDesign];
		
		// if a frame element was found
		if (frame != nil) {
			// instantiate a Frame object
			Frame * aFrame = [[Frame alloc] init];
			// extract the faceScale attribute from the frame element
			aFrame.faceScale = [TBXML valueOfAttributeNamed:@"faceScale" forElement:frame];
			// extract the facecount attribute from the frame element
			aFrame.facecount = [TBXML valueOfAttributeNamed:@"facecount" forElement:frame];
			// extract the id attribute from the frame element
			aFrame.fid = [TBXML valueOfAttributeNamed:@"id" forElement:frame];
			// extract the minCount attribute from the frame element
			aFrame.minCount = [TBXML valueOfAttributeNamed:@"minCount" forElement:frame];
			// extract the order attribute from the frame element
			aFrame.order = [TBXML valueOfAttributeNamed:@"order" forElement:frame];
			// extract the probability attribute from the frame element
			aFrame.probability = [TBXML valueOfAttributeNamed:@"probability" forElement:frame];
			// extract the scale attribute from the frame element
			aFrame.scale = [TBXML valueOfAttributeNamed:@"scale" forElement:frame];
			// extract the faceScale attribute from the frame element
			aFrame.faceScale = [TBXML valueOfAttributeNamed:@"faceScale" forElement:frame];
			// extract the shiftX attribute from the frame element
			aFrame.shiftX = [TBXML valueOfAttributeNamed:@"shiftX" forElement:frame];
			// extract the shiftY attribute from the frame element
			aFrame.shiftY = [TBXML valueOfAttributeNamed:@"shiftY" forElement:frame];
			// extract the tilt attribute from the frame element
			aFrame.tilt = [TBXML valueOfAttributeNamed:@"tilt" forElement:frame];
			// extract the weight attribute from the frame element
			aFrame.weight = [TBXML valueOfAttributeNamed:@"weight" forElement:frame];
			// extract the padAlpha attribute from the frame element
			aFrame.padAlpha = [TBXML valueOfAttributeNamed:@"padAlpha" forElement:frame];
			// extract the group attribute from the frame element
			aFrame.group = [TBXML valueOfAttributeNamed:@"group" forElement:frame];
			// search the versionMenu's child elements for a menuitem element
			TBXMLElement * border = [TBXML childElementNamed:@"border" parentElement:frame];
			
			while (border != nil) {
				// instantiate a Border object
				Border * aBorder = [[Border alloc] init];
				
				// extract the path attribute from the border element
				aBorder.path = [TBXML valueOfAttributeNamed:@"path" forElement:border];
				
				// extract the cutout attribute from the border element
				aBorder.cutout = [TBXML valueOfAttributeNamed:@"cutout" forElement:border];
				
				[aFrame.borders addObject:aBorder];
				
				[aBorder release];
				
				// find the next sibling element named "menuitem"
				border = [TBXML nextSiblingNamed:@"border" searchFromElement:border];
			}
			
			[design setFrame:aFrame]; 
			[aFrame release];
		}
		
		// search the aDesign's child elements for a Element element
		TBXMLElement * element = [TBXML childElementNamed:@"Element" parentElement:aDesign];
		
		while (element != nil) {
			// instantiate a Element object
			Element * aElement = [[Element alloc] init];
			
			// extract the position attribute from the element element
			aElement.position = [TBXML valueOfAttributeNamed:@"position" forElement:element];
			
			// extract the type attribute from the element element
			aElement.type = [TBXML valueOfAttributeNamed:@"type" forElement:element];
			
			// extract the style attribute from the element element
			aElement.style = [TBXML valueOfAttributeNamed:@"style" forElement:element];
			// extract the width attribute from the element element
			aElement.width = [TBXML valueOfAttributeNamed:@"width" forElement:element];
			// extract the height attribute from the element element
			aElement.height = [TBXML valueOfAttributeNamed:@"height" forElement:element];
			// extract the x attribute from the element element
			aElement.x = [TBXML valueOfAttributeNamed:@"x" forElement:element];
			// extract the y attribute from the element element
			aElement.y = [TBXML valueOfAttributeNamed:@"y" forElement:element];
			// extract the layoutDensity attribute from the element element
			aElement.layoutDensity = [TBXML valueOfAttributeNamed:@"layoutDensity" forElement:element];
			// extract the group attribute from the element element
			aElement.group = [TBXML valueOfAttributeNamed:@"group" forElement:element];
			// extract the mode attribute from the element element
			aElement.mode = [TBXML valueOfAttributeNamed:@"mode" forElement:element];
			// extract the marginpusher attribute from the element element
			aElement.marginpusher = [TBXML valueOfAttributeNamed:@"marginpusher" forElement:element];
			// extract the alignment attribute from the element element
			aElement.alignment = [TBXML valueOfAttributeNamed:@"alignment" forElement:element];
			// search the element's child elements for a image element
			TBXMLElement * image = [TBXML childElementNamed:@"image" parentElement:element];
			
			while (image != nil) {
				
				Image * aImage = [[Image alloc] init];
				
				// extract the source attribute from the image element
				aImage.source = [TBXML valueOfAttributeNamed:@"source" forElement:image];
				// extract the width attribute from the image element
				aImage.width = [TBXML valueOfAttributeNamed:@"width" forElement:image];
				
				// extract the height attribute from the image element
				aImage.height = [TBXML valueOfAttributeNamed:@"height" forElement:image];
				
				[aElement.images addObject:aImage];
				
				[aImage release];
				
				// find the next sibling element named "image"
				image = [TBXML nextSiblingNamed:@"image" searchFromElement:image];
			}
			
			while ([aElement.images count]<9){
				Image * aImage = [[Image alloc] init];
				[aElement.images addObject:aImage];
				[aImage release];
			}
			
			[design.elements addObject:aElement];
			
			[aElement release];
			
			// find the next sibling element named "Element"
			element = [TBXML nextSiblingNamed:@"Element" searchFromElement:element];
		}
		
		// search the aDesign's child elements for a Element element
		TBXMLElement * text = [TBXML childElementNamed:@"text" parentElement:aDesign];
		
		while (text != nil) {
			// instantiate a TextX object
			Text * aText = [[Text alloc] init];
			
			// extract the group attribute from the text element
			aText.group = [TBXML valueOfAttributeNamed:@"group" forElement:text];
			
			// extract the mode attribute from the text element
			aText.mode = [TBXML valueOfAttributeNamed:@"mode" forElement:text];
			// extract the id attribute from the text element
			aText.tid = [TBXML valueOfAttributeNamed:@"id" forElement:text];
			// extract the position attribute from the text element
			aText.position = [TBXML valueOfAttributeNamed:@"position" forElement:text];
			// extract the type attribute from the text element
			aText.type = [TBXML valueOfAttributeNamed:@"type" forElement:text];
			// extract the fontSize attribute from the text element
			aText.fontSize = [TBXML valueOfAttributeNamed:@"fontSize" forElement:text];
			// extract the fontWeight attribute from the text element
			aText.fontWeight = [TBXML valueOfAttributeNamed:@"fontWeight" forElement:text];
			// extract the fontStyle attribute from the text element
			aText.fontStyle = [TBXML valueOfAttributeNamed:@"fontStyle" forElement:text];
			// extract the fontFamily attribute from the text element
			aText.fontFamily = [TBXML valueOfAttributeNamed:@"fontFamily" forElement:text];
			// extract the fontColor attribute from the text element
			aText.fontColor = [TBXML valueOfAttributeNamed:@"fontColor" forElement:text];
			// extract the areaAlpha attribute from the text element
			aText.areaAlpha = [TBXML valueOfAttributeNamed:@"areaAlpha" forElement:text];
			// extract the textAlign attribute from the text element
			aText.textAlign = [TBXML valueOfAttributeNamed:@"textAlign" forElement:text];
			// extract the text attribute from the text element
			//aText.text = [TBXML valueOfAttributeNamed:@"text" forElement:text];
			// extract the width attribute from the text element
			aText.width = [TBXML valueOfAttributeNamed:@"width" forElement:text];
			// extract the height attribute from the text element
			aText.height = [TBXML valueOfAttributeNamed:@"height" forElement:text];
			// extract the x attribute from the text element
			aText.x = [TBXML valueOfAttributeNamed:@"x" forElement:text];
			// extract the y attribute from the text element
			aText.y = [TBXML valueOfAttributeNamed:@"y" forElement:text];
			// search the text's child elements for a textArea element
			TBXMLElement * textArea = [TBXML childElementNamed:@"textArea" parentElement:text];
			
			while (textArea != nil) {
				
				[aText.textAreaFontColors addObject:[TBXML valueOfAttributeNamed:@"fontColor" forElement:textArea]];
				
				// find the next sibling element named "textArea"
				textArea = [TBXML nextSiblingNamed:@"textArea" searchFromElement:textArea];
			}
			
			[design.texts addObject:aText];
			
			[aText release];
			// find the next sibling element named "text"
			text = [TBXML nextSiblingNamed:@"text" searchFromElement:text];
		}		
	}
	
	// release resources
	self.tbxml = nil;
	[pool release];
}

-(int)generateRandomNumber:(int)maxnum{
	 //生成0－maxnum之间的随机数
	 srandom(time(NULL));
	 return random() % 8;
}
/*
-(UIImage *)getImageFromImage:(CGRect)newRect{
	
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"string_narrow.png" ofType:nil];
	UIImage *bigImage = [[UIImage alloc] initWithContentsOfFile: imagePath];
	
	CGImageRef imageRef = bigImage.CGImage;
	
	CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, newRect);
	
	
	CGSize size;
	
	size.width = 5.0;
	
	size.height = 5.0;
	
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextDrawTiledImage(context, newRect, subImageRef);
	
	UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
	
	UIGraphicsEndImageContext();
	
	
	return smallImage;
	
}*/

-(void)drawInContext:(CGContextRef)context
{
	if (self.backgroundname == nil) {
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
		return;
	}
	
	CGContextClearRect(context, self.frame);
	CGContextClipToRect(context, viewRect);
	
	//UIImage *ui = [self getImageFromImage:CGRectMake(10, 10, 5, 200)];
	//[ui drawInRect:CGRectMake(10, 10, 5, 200)];
	/*
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:self.backgroundname ofType:nil];
	UIImage *img = [[UIImage alloc] initWithContentsOfFile: imagePath];
	CGImageRef image = [Utils scaleCGImage:[img CGImage] withPrefix: CGSizeMake(20, 20)];
	[img release];
	CGContextDrawTiledImage(context, CGRectMake(0, 0, 20, 20), image);
	//CGImageRelease(image);
	*/
	NSString *imagePath = nil;
	UIImage *img = nil;
	CGImageRef image = nil;
	for (int i=0;i<[self.listViews count];i++) {
		DrawingObject *draw = [self.listViews objectAtIndex:i];
		if ([draw.imgname isEqualToString:self.backgroundname]) {
			imagePath = [[NSBundle mainBundle] pathForResource:draw.imgname ofType:nil];
			img = [[UIImage alloc] initWithContentsOfFile:imagePath];
			CGSize size = CGSizeMake(img.size.width*draw.mat.a, img.size.height*draw.mat.a);
			size.width = ceil(size.width);
			size.height = ceil(size.height);
			image = [Utils scaleCGImage:[img CGImage] withPrefix: size];
			[img release];
			
			img = [[UIImage alloc] initWithCGImage: image];
			CGImageRelease(image);
			image = nil;
			[img drawInRect:draw.box];
			[img drawAsPatternInRect:viewRect];
			[img release];
		}else{
		imagePath = [[NSBundle mainBundle] pathForResource:draw.imgname ofType:nil];
		img = [[UIImage alloc] initWithContentsOfFile:imagePath];
		CGSize size = CGSizeMake(img.size.width*draw.mat.a, img.size.height*draw.mat.a);
		size.width = ceilf(size.width);
		size.height = ceilf(size.height);
		image = [Utils scaleCGImage:[img CGImage] withPrefix: size];
		[img release];
		img = [[UIImage alloc] initWithCGImage: image];
		CGImageRelease(image);
		image = nil;
		[img drawInRect:draw.box];
		[img release];
		}
	}
}

-(BOOL)checkMode:(Element *)e Design:(Design *)d{
	NSString *currentMode = @"0";
	if (d.mode != nil) {
		currentMode = d.mode;
	}else {
		d.mode = currentMode;
	}
	
	NSString *elemMode = @"0";
	if (e.mode != nil) {
		elemMode = e.mode;
	}

	return (([currentMode isEqualToString:elemMode]) || ([elemMode isEqualToString:@""]));
}


-(void)setDesignVersion:(Design *)d isRandomize:(BOOL)randomize {
}

-(void)composeBorder:(CGFloat)thisPPI Rect:(CGRect)rect DensityMap:(BOOL)densityMap DoCutout:(BOOL)doCutout LayoutAreaChanged:(BOOL)layoutAreaChanged{
	_bmapWidth = ceilf(_virtualWidth * thisPPI);
	_bmapHeight = ceilf(_virtualHeight * thisPPI);
	//if (rect == nil) {
		rect = CGRectMake(0, 0, _bmapWidth, _bmapHeight);
	//}
	
	CGRect box = CGRectMake(0, 0, _bmapWidth, _bmapHeight);
	[self composeElement:self Box:box Design:design DensityMap:densityMap DoCutout:doCutout];
}

-(CGFloat)getImageScaleX:(Element *)elem{
	CGFloat imageXscale = 1;
	if ([elem.images count]>0){
		Image *image = [elem.images objectAtIndex:dversion];
		if (image.width != nil) {
			imageXscale = [image.width floatValue]/ [image.contentWidth floatValue];
		}
	}
	return imageXscale;
}

-(CGFloat)getImageScaleY:(Element *)elem{
	CGFloat imageYscale = 1;
	if ([elem.images count]>0){
		Image *image = [elem.images objectAtIndex:dversion];
		if (image.height != nil) {
			imageYscale = [image.height floatValue]/ [image.contentHeight floatValue];
		}
	}
	return imageYscale;
}

-(CGRect)transformBox:(CGRect)box Matrix:(CGAffineTransform)matrix{
	CGFloat x = box.origin.x;
	CGFloat y = box.origin.y;
	CGFloat width = box.size.width;
	CGFloat height = box.size.height;
	CGFloat right = box.origin.x+width;
	CGFloat bottom = box.origin.y+height;
	
	// left top;
	CGFloat xtl = x*matrix.a+y*matrix.c+matrix.tx;
	CGFloat ytl = x*matrix.b+y*matrix.d+matrix.ty;
	
	//right top
	CGFloat xtr = right*matrix.a+y*matrix.c+matrix.tx;
	CGFloat ytr = right*matrix.b+y*matrix.d+matrix.ty;
	
	//bottom left;
	CGFloat xbl = x*matrix.a+bottom*matrix.c+matrix.tx;
	CGFloat ybl = x*matrix.b+bottom*matrix.d+matrix.ty;
	
	//bottom right
	CGFloat xbr = right*matrix.a+bottom*matrix.c+matrix.tx;
	CGFloat ybr = right*matrix.b+bottom*matrix.d+matrix.ty;
	
	CGFloat x0 = fminf(fminf(xtl, xtr),fminf(xbl, xbr));
	CGFloat y0 = fminf(fminf(ytl, ytr),fminf(ybl, ybr));
	CGFloat x1 = fmaxf(fmaxf(xtl, xtr),fmaxf(xbl, xbr));
	CGFloat y1 = fmaxf(fmaxf(ytl, ytr),fmaxf(ybl, ybr));
	CGFloat width0 = x1-x0;
	CGFloat height0 = y1-y0;
	CGRect newBox = CGRectMake(x0, y0, width0, height0);
	
	return newBox;
	
}

-(CGAffineTransform)cornerFixedTransformWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)elem{
	CGFloat oriPageWidth = [d.width floatValue];
	CGFloat oriPageHeight = [d.height floatValue];
	CGAffineTransform matrix = CGAffineTransformIdentity;
	if ([elem.position isEqualToString:@"bottomLeft"]) {
		matrix.tx = 0;
		matrix.ty =pageBox.size.height-oriPageHeight;
	}else if ([elem.position isEqualToString:@"topLeft"]) {
		matrix.tx = 0;
		matrix.ty = 0;
	}else if ([elem.position isEqualToString:@"topRight"]) {
		matrix.tx = pageBox.size.width-oriPageWidth;
		matrix.ty = 0;
	}else if ([elem.position isEqualToString:@"bottomRight"]) {
		matrix.tx = pageBox.size.width-oriPageWidth;
		matrix.ty = pageBox.size.height-oriPageHeight;
	}
	
	return matrix;
	
}

-(DrawingObject *)getDrawingParamsWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)elem {
	CGRect box= CGRectMake([elem.x floatValue], [elem.y floatValue], [elem.width floatValue], [elem.height floatValue]);
	
	BOOL repeat=false;
	CGAffineTransform mat = CGAffineTransformIdentity;
	
	DrawingObject *params = [[DrawingObject alloc] init];
	[params setBox:box];
	[params setRepeat:false];
	[params setMat:CGAffineTransformIdentity];
	
	// get element box transform (where the element should be drawn on the page)
	mat = [self transformGrammaWithDegin:d PageBox:pageBox Elment:elem];
	//NSLog(@"#############1box.size.height>>>>%f",box.size.height);
	box = [self transformBox:box Matrix:mat];
	//NSLog(@"#############2box.size.height>>>>%f",box.size.height);
	// get image pattern transform (where the image should go)
	mat.a = mat.a * [self getImageScaleX:elem];
	mat.d = mat.d * [self getImageScaleY:elem];
	mat.tx = box.origin.x;
	mat.ty = box.origin.y;
	// get repeat count for perfectFit repeating elements
	
	if ([elem.type isEqualToString:@"repeating"]) {
		box = [self getRepeatingBoxSizeWithDesign:pageBox Design:d Element:elem Box:box];
		//NSLog(@"#############3box.size.height>>>>%f",box.size.height);
		if ([elem.style isEqualToString:@"texture"] || [elem.style isEqualToString:@"looseFit"]) {
			if ([elem.alignment isEqualToString:@"horizontal"] || [elem.alignment isEqualToString:@"vertical"]) {
				repeat = false;
			}else {
				repeat = true;
			}
			
		}
	}
	
	params.box = box;
	params.repeat = repeat;
	params.mat = mat;
	
	return params;
	
}

-(CGAffineTransform)cornerFlexTransformWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)elem{
	CGAffineTransform matrix = CGAffineTransformIdentity;
	CGAffineTransform xMatrix = CGAffineTransformIdentity;
	CGAffineTransform yMatrix = CGAffineTransformIdentity;
	//CGFloat xScale = pageBox.size.width/[d.width floatValue];
	//CGFloat yScale = pageBox.size.height/[d.height floatValue];
	if ([elem.position isEqualToString:@"bottomLeft"]) {
		xMatrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:@"left" Elment:elem];
		yMatrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:@"bottom" Elment:elem];
	}
	if ([elem.position isEqualToString:@"bottomRight"]) {
		xMatrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:@"right" Elment:elem];
		yMatrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:@"bottom" Elment:elem];
	}
	if ([elem.position isEqualToString:@"topLeft"]) {
		xMatrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:@"left" Elment:elem];
		yMatrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:@"top" Elment:elem];
	}
	if ([elem.position isEqualToString:@"topRight"]) {
		xMatrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:@"right" Elment:elem];
		yMatrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:@"top" Elment:elem];
	}
	
	matrix.a=xMatrix.a;
	matrix.tx=xMatrix.tx;
	matrix.d=yMatrix.d;
	matrix.ty=yMatrix.ty;
	return matrix;
}

-(CGAffineTransform)transformGrammaWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)elem{
	CGAffineTransform matrix = CGAffineTransformIdentity;
	CGAffineTransform xmat = CGAffineTransformIdentity;
	CGAffineTransform ymat = CGAffineTransformIdentity;
	NSArray *position = nil;
	NSString *xposition = nil;
	NSString *yposition = nil;
	if ([elem.type isEqualToString:@"corner_fixed"]) {
		//NSLog(@"corner_fixed>>>>>>>>>>>>>>>>>>>>");
		matrix = [self cornerFixedTransformWithDegin:d PageBox:pageBox Elment:elem];
	}else if ([elem.type isEqualToString:@"corner"]) {
		//NSLog(@"corner>>>>>>>>>>>>>>>>>>>>");
		matrix = [self cornerFlexTransformWithDegin:d PageBox:pageBox Elment:elem];
	}else if ([elem.type isEqualToString:@"background"]) {
		//NSLog(@"background>>>>>>>>>>>>>>>>>>>>");
		if (elem.position != nil) {
			position = [elem.position componentsSeparatedByString:@"/-/"];	
		}
		if ([position count] == 2) { //define different fit in x and y direction
			xposition = [position objectAtIndex:0];
			yposition = [position objectAtIndex:1];
			elem.position = xposition;
			xmat = [self backgroundTransformWithDegin:d PageBox:pageBox Elment:elem];
			elem.position = yposition;
			ymat = [self backgroundTransformWithDegin:d PageBox:pageBox Elment:elem];
			matrix.a=xmat.a;
			matrix.tx=xmat.tx;
			matrix.d=ymat.d;
			matrix.ty=ymat.ty;
		}else {
			matrix = [self backgroundTransformWithDegin:d PageBox:pageBox Elment:elem];
		}
	}else if ([elem.type isEqualToString:@"foreground"]) {
		matrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:elem.position Elment:elem];
	}else if ([elem.type isEqualToString:@"repeating"]) {
		//NSLog(@"repeating>>>>>>>>>>>>>>>>>>>>");
		position = [elem.position componentsSeparatedByString:@"/-/"];
		if ([position count] == 2) { //define different fit in x and y direction
			xposition = [position objectAtIndex:0];
			yposition = [position objectAtIndex:1];
			xmat = [self foregroundTransformWithDegin:d PageBox:pageBox Position:xposition Elment:elem];
			ymat = [self foregroundTransformWithDegin:d PageBox:pageBox Position:yposition Elment:elem];
			matrix.a=xmat.a;
			matrix.tx=xmat.tx;
			matrix.d=ymat.d;
			matrix.ty=ymat.ty;
		}else {
			matrix = [self foregroundTransformWithDegin:d PageBox:pageBox Position:elem.position Elment:elem];
		}
		
	}
	return matrix;
}


-(CGRect)getRepeatingBoxSizeWithDesign:(CGRect)rootBox Design:(Design *)d Element:(Element *)elem Box:(CGRect)box {
	//CGFloat xScale = rootBox.size.width /[d.width floatValue];
	//CGFloat yScale = rootBox.size.height /[d.height floatValue];
	
	CGAffineTransform mat = CGAffineTransformIdentity;
	CGRect patternFillingBox = CGRectMake([elem.x floatValue], [elem.y floatValue], [elem.width floatValue], [elem.height floatValue]);
	NSString *strposition = elem.position;
	NSArray *position = nil;
	if (strposition != nil) {
		position = [strposition componentsSeparatedByString:@"/-/"];	
	}
	
	if ([position count] == 2) { //define different fit in x and y direction
		NSString *xposition = [position objectAtIndex:0];
		NSString *yposition = [position objectAtIndex:1];
		elem.position = xposition;
		CGAffineTransform xmat = [self backgroundTransformWithDegin:d PageBox:rootBox Elment:elem];
		elem.position = yposition;
		CGAffineTransform ymat = [self backgroundTransformWithDegin:d PageBox:rootBox Elment:elem];
		mat.a = xmat.a;
		mat.tx=xmat.tx;
		mat.d=ymat.d;
		mat.ty=ymat.ty;
	}else {
		mat=[self backgroundTransformWithDegin:d PageBox:rootBox Elment:elem];
	}
	patternFillingBox = [self transformBox:patternFillingBox Matrix:mat];
	//NSLog(@"2patternFillingBox.size.height>>>>>>>>>>>%f",patternFillingBox.size.height);
	NSString *alignment = elem.alignment;
	if (![elem.style isEqualToString:@"texture"] && ([alignment isEqualToString:@"horizontal"] || [alignment isEqualToString:@"vertical"])) {
		if ([alignment isEqualToString:@"horizontal"]) { //doesn't change the hight as its height will be defined by the atom's height
			box.size.width=patternFillingBox.size.width;
			box.size.height = box.size.height;
			box.origin.x=patternFillingBox.origin.x;
		} else if([alignment isEqualToString:@"vertical"]){ //will not change width as its width will be defined by the atom's width;
			box.size.height=patternFillingBox.size.height;
			box.size.width = box.size.width;
			box.origin.y=patternFillingBox.origin.y;
		}
		
	}else if ([elem.style isEqualToString:@"texture"] || [alignment isEqualToString:@"both"] || [alignment isEqualToString:@""]) {
		box=patternFillingBox;
	}
	return box;
}

-(RepObject *)getRepeatingCountWithPageBox:(CGRect)pageBox Elment:(Element *)elem Matrix:(CGAffineTransform)mat Box:(CGRect)box{
	RepObject *rep = [[RepObject alloc] init];
	[rep setXcount:1];
	[rep setYcount:1];
	[rep setXstep:0];
	[rep setYstep:0];
	[rep setXstart:box.origin.x];
	[rep setYstart:box.origin.y];
	
	if (![elem.type isEqualToString:@"repeating"] || [elem.style isEqualToString:@"texture"] || 
		([elem.style isEqualToString:@"looseFit"] && [elem.alignment isEqualToString:@"both"]) || 
		([elem.style isEqualToString:@"looseFit"] && elem.alignment == nil)) {
		return rep;
	}
	Image *image = [elem.images objectAtIndex:dversion];
	CGFloat w = mat.a * [image.contentWidth floatValue];
	CGFloat h = mat.d * [image.contentHeight floatValue];
	CGFloat xstep = 0.0f;
	CGFloat ystep = 0.0f;
	int oddXCount = -1;
	int oddYCount = -1;
	
	if (elem.xstep != nil) {
		xstep=(mat.a/[self getImageScaleX:elem]) * [elem.xstep floatValue] - w;
		//NSLog(@"#######xstep>>>>>>>>>%f",xstep);
	}
	
	if (elem.ystep != nil) {
		ystep=(mat.d/[self getImageScaleY:elem]) * [elem.ystep floatValue] - h;
		//NSLog(@"#######ystep>>>>>>>>>%f",ystep);
	}
	
	if (elem.oddXCount != nil) {
		if ([[elem.oddXCount substringToIndex:1] isEqualToString:@"1"] || [[elem.oddXCount substringToIndex:1] isEqualToString:@"t"] || [[elem.oddXCount substringToIndex:1] isEqualToString:@"T"]) {
			oddXCount = 1;
		}else {
			oddXCount = 0;
		}
		
	}
	
	if (elem.oddYCount != nil) {
		if ([[elem.oddYCount substringToIndex:1] isEqualToString:@"1"] || [[elem.oddYCount substringToIndex:1] isEqualToString:@"t"] || [[elem.oddYCount substringToIndex:1] isEqualToString:@"T"]) {
			oddYCount = 1;
		}else {
			oddYCount = 0;
		}
		
	}
	
	xstep = fmaxf(xstep, -w/2);
	ystep = fmaxf(ystep, -h/2);
	NSString *style = elem.style;
	NSArray *fitStyle = nil;
	if (style != nil) {
		fitStyle = [style componentsSeparatedByString:@"/-/"];	
	}
	NSString *xFitStyle = nil;
	NSString *yFitStyle = nil;
	if ([fitStyle count] !=2) {
		xFitStyle = [fitStyle objectAtIndex:0];
		yFitStyle = [fitStyle objectAtIndex:0];
	}else {
		xFitStyle = [fitStyle objectAtIndex:0];
		yFitStyle = [fitStyle objectAtIndex:1];
	}
	
	if ([xFitStyle isEqualToString:@"perfectFit"] || [yFitStyle isEqualToString:@"perfectFit"]) {
		if ([xFitStyle isEqualToString:@"perfectFit"] && ([elem.alignment isEqualToString:@"horizontal"] || [elem.alignment isEqualToString:@"both"])) {
			// newchange (whole "if" block)
			if (oddXCount >= 0) {
				rep.xcount = fmaxf(floorf((box.size.width+xstep)/(w+xstep)/2)*2+oddXCount, 0);
			}else {
				rep.xcount = fmaxf(floorf((box.size.width+xstep)/(w+xstep)), 0);
			}
			if (rep.xcount > 1) {
				rep.xstep = (box.size.width-w)/(rep.xcount-1);
			}else {
				rep.xstart+=(box.size.width-w)*0.5;
			}
			box.size.width = w;
		}
		
		if ([yFitStyle isEqualToString:@"perfectFit"] && ([elem.alignment isEqualToString:@"vertical"] || [elem.alignment isEqualToString:@"both"])) {
			if (oddYCount >= 0) {
				rep.ycount = fmaxf(floorf((box.size.height+ystep)/(h+ystep)/2)*2+oddYCount, 0);
			}else {
				rep.ycount = fmaxf(floorf((box.size.height+ystep)/(h+ystep)), 0);
			}
			
			if (rep.ycount > 1) {
				rep.ystep = (box.size.height-h)/(rep.ycount-1);
			}else if(rep.ycount == 1) {
				rep.ystart+=(box.size.height-h)*0.5;
			}
			box.size.height = h;
		}
	}
	
	if ([xFitStyle isEqualToString:@"tightFit"] || [yFitStyle isEqualToString:@"tightFit"]) {
		CGFloat startx =0.0f;
		CGFloat endx =0.0f;
		if ([xFitStyle isEqualToString:@"tightFit"] && ([elem.alignment isEqualToString:@"horizontal"] || [elem.alignment isEqualToString:@"both"])) {
			startx = box.origin.x+w;
			endx = box.origin.x+box.size.width;;
			rep.xcount = 0;
			while ((startx<endx) && (startx<pageBox.size.width)) {
				rep.xcount=rep.xcount+1;;
				startx=startx+xstep+w;
			}
			if (xstep == 0) {
				rep.xstep=w;
			}else {
				rep.xstep=xstep+w;
				box.size.width = w;
			}
		}
		
		CGFloat starty =0.0f;
		CGFloat endy =0.0f;
		if ([yFitStyle isEqualToString:@"tightFit"] && ([elem.alignment isEqualToString:@"vertical"] || [elem.alignment isEqualToString:@"both"])) {
			starty = box.origin.y+h;
			endy = box.origin.y+box.size.height;
			rep.ycount = 0;
			while ((starty <endy) && (starty< pageBox.size.height)) {
				rep.ycount=rep.ycount+1;;
				starty=starty+ystep+h;
			}
			if (ystep == 0) {
				rep.ystep=h;
			}else {
				rep.ystep=ystep+h;
				box.size.height = h;
			}
			
		}
	}
	
	if ([xFitStyle isEqualToString:@"continuousFit"] || [yFitStyle isEqualToString:@"continuousFit"]) {
		if ([xFitStyle isEqualToString:@"continuousFit"] && ([elem.alignment isEqualToString:@"horizontal"] || [elem.alignment isEqualToString:@"both"])) {
			if (oddXCount >= 0) {
				rep.xcount = fmaxf(floorf((box.size.width+xstep)/(w+xstep)/2)*2+oddXCount, 1);
			}else {
				rep.xcount = fmaxf(floorf((box.size.width+xstep)/(w+xstep)), 1);
			}
			CGFloat ratio = xstep/w;
			CGFloat w1 = box.size.width/(rep.xcount+(rep.xcount-1)*ratio);
			CGFloat xstep1 = ratio*w1;
			rep.xstep = w1+xstep1;
			box.size.width = w1;
			mat.a = mat.a * (rep.xstep / (w+xstep));
		}
		
		if ([yFitStyle isEqualToString:@"continuousFit"] && ([elem.alignment isEqualToString:@"vertical"] || [elem.alignment isEqualToString:@"both"])) {
			if (oddYCount >= 0) {
				rep.ycount = fmaxf(floorf((box.size.height+ystep)/(h+ystep)/2)*2+oddYCount, 1);
			}else {
				rep.ycount = fmaxf(floorf((box.size.height+ystep)/(h+ystep)), 1);
			}
			CGFloat ratio = ystep/h;
			CGFloat h1 = box.size.height/(rep.ycount+(rep.ycount-1)*ratio);
			CGFloat ystep1 = ratio*h1;
			rep.ystep = h1+ystep1;
			box.size.height = h1;
			mat.d = mat.d * (rep.ystep / (h+ystep));
		}
	}
	
	if ([xFitStyle isEqualToString:@"looseFit"] || [xFitStyle isEqualToString:@"texture"] || [yFitStyle isEqualToString:@"looseFit"] || [yFitStyle isEqualToString:@"texture"]) {
		if (([xFitStyle isEqualToString:@"looseFit"] || [xFitStyle isEqualToString:@"texture"]) && ([elem.alignment isEqualToString:@"horizontal"] || [elem.alignment isEqualToString:@"both"])) {
			rep.xcount=fmaxf(ceilf((box.size.width+xstep)*mat.a*mat.a/(w+xstep)), 0);
			//NSLog(@"xcount>>>>>>%f",rep.xcount);
			rep.xstep = xstep+w;
			box.size.width = w;
		}else if (([yFitStyle isEqualToString:@"looseFit"] || [yFitStyle isEqualToString:@"texture"]) || ([elem.alignment isEqualToString:@"vertical"] || [elem.alignment isEqualToString:@"both"])) {
			//NSLog(@"ystep>>>>>>%f",ystep);
			//NSLog(@"box.size.height>>>>>>%f",box.size.height);
			//NSLog(@"mat.d>>>>>>%f",mat.d);
			//NSLog(@"h>>>>>>%f",h);
			rep.ycount = fmaxf(ceilf((box.size.height+ystep)*mat.d*mat.d/(h+ystep)), 0);
			//NSLog(@"ycount>>>>>>%f",rep.ycount);
			rep.ystep = ystep+h;
			box.size.height = h;
		}
	}
	
	return rep;
}

-(CGAffineTransform)foregroundTransformWithDegin:(Design *)d PageBox:(CGRect)pageBox Position:(NSString *)position Elment:(Element *)e{
	CGFloat oriPageWidth = [d.width floatValue];
	CGFloat oriPageHeight = [d.height floatValue];
	CGFloat pageXScale = pageBox.size.width / [d.width floatValue];
	CGFloat pageYScale = pageBox.size.height / [d.height floatValue];
	CGAffineTransform matrix = CGAffineTransformIdentity;
	matrix.a = fminf(pageXScale, pageYScale);
	matrix.d = fminf(pageXScale, pageYScale);
	CGFloat addedScale = 1.0f;
	if(e.setScale != nil){
		addedScale = [e.setScale floatValue];
		matrix.a=matrix.a*addedScale;
		matrix.d=matrix.d*addedScale;
	}
	CGFloat w = [e.width floatValue];
	CGFloat h = [e.height floatValue];
	if ([e.images count]>0) {
		Image *image = [e.images objectAtIndex:dversion];
		if (image.width != nil) {
			w = [image.width floatValue];
		}
		if (image.height != nil) {
			h = [image.height floatValue];
		}
	}
	CGFloat newPos = 0.0f;
	CGFloat newDeltaScale = fminf(pageXScale, pageYScale)*addedScale;
	if (pageXScale <= pageYScale) {
		if ([position isEqualToString:@"middle"] || [position isEqualToString:@"left"] || [position isEqualToString:@"right"]) {
			if (oriPageHeight == h) {
				newPos = [e.y floatValue] / oriPageHeight * pageBox.size.height;
			}else {
				newPos =  [e.y floatValue] / (oriPageHeight - h) * (pageBox.size.height - h*matrix.d);
			}
			
		}else if ([position isEqualToString:@"bottom"]) { //preserve distance to the bottom edge
			newPos=pageBox.size.height-h*matrix.d-newDeltaScale*(oriPageHeight-h-[e.y floatValue]);
		}else if ([position isEqualToString:@"top"]) { //preserve delTop;
			newPos=[e.y floatValue]*newDeltaScale; 
		}
		matrix.ty=newPos-[e.y floatValue]*matrix.d;
		
		if ([position isEqualToString:@"left"]) {
			newPos=newDeltaScale*[e.x floatValue];
		}else if ([position isEqualToString:@"right"]) {
			newPos=pageBox.size.width-w*matrix.a-newDeltaScale*(oriPageWidth-w-[e.x floatValue]);
		}else {
			if (oriPageWidth == w) {
				newPos=[e.x floatValue]/oriPageWidth*pageBox.size.width; 
			}else {
				newPos=[e.x floatValue]/(oriPageWidth - w)*(pageBox.size.width-w*matrix.a); 
			}
			
		}
		matrix.tx=newPos-[e.x floatValue]*matrix.a;
		
	} else if (pageXScale > pageYScale) {
		if ([position isEqualToString:@"middle"] || [position isEqualToString:@"top"] || [position isEqualToString:@"bottom"]) {
			//FOR Tx:
			if (oriPageWidth == w){
				newPos = [e.x floatValue] / oriPageWidth *pageBox.size.width;
			}else {
				newPos =  [e.x floatValue] / (oriPageWidth - w) * (pageBox.size.width - w*matrix.d);
			}
			
		}else if ([position isEqualToString:@"left"]) {
			newPos=[e.x floatValue]*newDeltaScale;
		} else if ([position isEqualToString:@"right"]) {
			newPos=pageBox.size.width-w*matrix.a-newDeltaScale*(oriPageWidth-w-[e.x floatValue]);
		}
		matrix.tx = newPos - [e.x floatValue] * matrix.d;
		
		//FOR Ty:
		if([position isEqualToString:@"top"]) {
			newPos=newDeltaScale*[e.y floatValue];
		}
		else if ([position isEqualToString:@"bottom"]) {
			newPos=pageBox.size.height-h*matrix.d-newDeltaScale*(oriPageHeight-h-[e.y floatValue]);
		}else {
			if(oriPageHeight==h)
				newPos=[e.y floatValue]/oriPageHeight*pageBox.size.height;
			else
				newPos=[e.y floatValue]/(oriPageHeight-h)*(pageBox.size.height-h*matrix.d);
		}
		matrix.ty=newPos-[e.y floatValue]*matrix.d;
	}
	
	return matrix;
}

-(CGAffineTransform)backgroundTransformWithDegin:(Design *)d PageBox:(CGRect)pageBox Elment:(Element *)e{
	CGFloat xScale = pageBox.size.width / [d.width floatValue];
	CGFloat yScale = pageBox.size.height / [d.height floatValue];
	NSString *position = e.position;
	CGFloat oriPageWidth = [d.width floatValue];
	CGFloat oriPageHeight = [d.height floatValue];
	CGFloat w = [e.width floatValue];
	CGFloat h = [e.height floatValue];
	CGAffineTransform matrix = CGAffineTransformIdentity;
	CGFloat addedScale = 1.0f;
	CGFloat newPos = 0.0f;
	if ([e.position isEqualToString:@"area"]) {
		matrix.a = xScale;
		matrix.d = yScale;
		return matrix;
	}
	
	CGFloat newDeltaScale = fminf(xScale, yScale)*addedScale;
	CGFloat yScaleNew = (pageBox.size.height - (oriPageHeight -h)*newDeltaScale)/h;
	CGFloat xScaleNew = (pageBox.size.width - (oriPageWidth -w)*newDeltaScale)/w;
	if (xScale <= yScale) {
		CGFloat newXScale = xScale*addedScale;
		if ([position isEqualToString:@"left"] || [position isEqualToString:@"right"]) {
			matrix.a = newXScale;
			matrix.d = yScaleNew;
			newPos = newDeltaScale*[e.y floatValue];
		}else if([position isEqualToString:@"middle"]){
			matrix.a = xScaleNew;
			matrix.d = yScaleNew;
			newPos = newDeltaScale*[e.y floatValue];
		}else if([position isEqualToString:@"top"] || [position isEqualToString:@"bottom"]){
			matrix.a = xScaleNew;
			matrix.d = newXScale;
			if([position isEqualToString:@"top"]){
				newPos = newDeltaScale*[e.y floatValue];
			}else if ([position isEqualToString:@"bottom"]) {
				newPos = pageBox.size.height - h*matrix.d - newDeltaScale*(oriPageHeight-h-[e.y floatValue]);
			}
		}
		//FOR Ty:
		matrix.ty = newPos-[e.y floatValue]*matrix.d;
		//FOR Tx:
		if ([position isEqualToString:@"left"]) {
			newPos = newDeltaScale*[e.x floatValue];
		}else if ([position isEqualToString:@"right"]) { //keep distance to the right edge;
			newPos = pageBox.size.width-w*matrix.a-newDeltaScale*(oriPageWidth-w-[e.x floatValue]);
		}else {
			if (w == oriPageWidth) {
				newPos = [e.x floatValue]*oriPageWidth/pageBox.size.width;
			}else {
				newPos = [e.x floatValue]/(oriPageWidth-w)*(pageBox.size.width-w*matrix.a);
			}
		}
		matrix.tx = newPos-[e.x floatValue]*matrix.a;
		
	}
	else if(xScale > yScale) {
		CGFloat newYScale = yScale*addedScale;
		if([position isEqualToString:@"top"] || [position isEqualToString:@"bottom"]) {
			matrix.a = xScaleNew;  			    
			matrix.d = newYScale;
			newPos = newDeltaScale*[e.x floatValue];
		}else if ([position isEqualToString:@"middle"]) {
			matrix.a=xScaleNew;
			matrix.d=yScaleNew;
			newPos=newDeltaScale*[e.x floatValue];
		}else if ([position isEqualToString:@"left"] || [position isEqualToString:@"right"]) {
			matrix.a = newYScale;
			matrix.d = yScaleNew;
			if([position isEqualToString:@"left"]){
				newPos = newDeltaScale*[e.x floatValue];
			}else if ([position isEqualToString:@"right"]) {
				newPos = pageBox.size.width - w*matrix.a - newDeltaScale*(oriPageWidth-w-[e.x floatValue]);
			}
		}
		
		//FOR Tx:
		matrix.tx=newPos-[e.x floatValue]*matrix.a;
		//FOR Ty:
		if([position isEqualToString:@"top"])
			newPos=newDeltaScale*[e.y floatValue];
		else if ([position isEqualToString:@"bottom"])
			newPos=pageBox.size.height-h*matrix.d-newDeltaScale*(oriPageHeight-h-[e.y floatValue]);
		else
		{
			if(h==oriPageHeight)
				newPos=[e.y floatValue]/oriPageHeight*pageBox.size.height;
			else
				newPos=[e.y floatValue]/(oriPageHeight-h)*(pageBox.size.height-h*matrix.d);
		}	
		
		matrix.ty=newPos-[e.y floatValue]*matrix.d;	
	}
	return matrix;
	
}

-(void)composeElement:(UIView *)can Box:(CGRect)box Design:(Design *)d DensityMap:(BOOL)densityMap DoCutout:(BOOL)doCutout{
	//CGFloat pageWidth = box.size.width;
	//CGFloat pageheight = box.size.height;
	NSString *imagePath = nil;
	for (int i=0; i < [d.elements count]; i++) {
		if (([[[d.elements objectAtIndex:i] layoutDensity] intValue] >= 0) || (!densityMap) || ([self checkMode:[d.elements objectAtIndex:i] Design:d])) {
			Element *e = [d.elements objectAtIndex:i];
			Image *image = [e.images objectAtIndex:dversion];
			NSArray *myArray = [image.source componentsSeparatedByString: @"/"];
			imagePath = [[NSBundle mainBundle] pathForResource:(NSString*)[myArray lastObject] ofType:nil];
			UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
			NSString *tmpWidth = [[NSString alloc]initWithFormat:@"%f",img.size.width];
			[image setContentWidth:tmpWidth];
			if (image.width == nil) {
				[image setWidth:tmpWidth];
			}
			[tmpWidth release];
			NSString *tmpHeight = [[NSString alloc]initWithFormat:@"%f",img.size.height];
			[image setContentHeight:tmpHeight];
			if (image.height == nil) {
				[image setHeight:tmpHeight];
			}
			[tmpHeight release];
			DrawingObject *params = [self getDrawingParamsWithDegin:d PageBox:box Elment:e];
			CGAffineTransform mat = params.mat;
			CGRect pbox = params.box;
			RepObject *rep = [self getRepeatingCountWithPageBox:box Elment:e Matrix:mat Box:pbox];
			CGFloat x = rep.xstart+box.origin.x;
			CGFloat y = rep.ystart+box.origin.y;
			CGRect r = CGRectMake(x, y, params.box.size.width, params.box.size.height);
			[params setBox:r];
			// draw the graphics. The iteration is for perfectFit repeated element.
			for (int j=0; j<rep.xcount; j++) {
				for (int k=0; k<rep.ycount; k++) {
					pbox.origin.x = params.box.origin.x + rep.xstep * j;
					pbox.origin.y = params.box.origin.y + rep.ystep * k + DRAW_OFFSET;
					mat.tx = pbox.origin.x;
					mat.ty = pbox.origin.y;
					// limit box size for looseFit items
					if ([e.style isEqualToString:@"looseFit"]) {
						if (k>=rep.ycount-1) {
							pbox.size.height=params.box.size.height - k*rep.ystep;
						}
						if (j>=rep.xcount-1) {
							pbox.size.width=params.box.size.width-j*rep.xstep;
						}
					}
					if (image.source != nil){
						
						DrawingObject *d = [[DrawingObject alloc] init];
						[d setBox:pbox];
						[d setMat:mat];
						[d setImgname:(NSString*)[myArray lastObject]];
						if ([e.type isEqualToString:@"foreground"] || [e.type isEqualToString:@"background"] || [e.type isEqualToString:@"corner"] || ([e.type isEqualToString:@"repeating"] && [e.alignment isEqualToString:@"vertical"] && (e.marginpusher == nil))) {
							if (([e.type isEqualToString:@"repeating"] && [e.alignment isEqualToString:@"vertical"] && (e.marginpusher == nil))) {
								[d setRepeat:NO];
							}else {
								[d setRepeat:YES];
							}
							
							
							[self.listViews addObject:d];
						}
						if ([e.position isEqualToString:@"area"] && [e.type isEqualToString:@"repeating"]) {
							self.backgroundname = (NSString*)[myArray lastObject];
							[self.listViews addObject:d];
						}
						
						[d release];
					}
				}
			}
			[rep release];
			[params release];
			
		}
	}
}

@end
