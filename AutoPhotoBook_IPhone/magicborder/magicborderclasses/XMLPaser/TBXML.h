
// ================================================================================================
//  Defines
// ================================================================================================
#define MAX_ELEMENTS 100
#define MAX_ATTRIBUTES 100

#define TBXML_ATTRIBUTE_NAME_START 0
#define TBXML_ATTRIBUTE_NAME_END 1
#define TBXML_ATTRIBUTE_VALUE_START 2
#define TBXML_ATTRIBUTE_VALUE_END 3
#define TBXML_ATTRIBUTE_CDATA_END 4

// ================================================================================================
//  Structures
// ================================================================================================
typedef struct _TBXMLAttribute {
	char * name;
	char * value;
	struct _TBXMLAttribute * next;
} TBXMLAttribute;

typedef struct _TBXMLElement {
	char * name;
	char * text;
	
	TBXMLAttribute * firstAttribute;
	
	struct _TBXMLElement * parentElement;
	
	struct _TBXMLElement * firstChild;
	struct _TBXMLElement * currentChild;
	
	struct _TBXMLElement * nextSibling;
	struct _TBXMLElement * previousSibling;
	
} TBXMLElement;

typedef struct _TBXMLElementBuffer {
	TBXMLElement * elements;
	struct _TBXMLElementBuffer * next;
	struct _TBXMLElementBuffer * previous;
} TBXMLElementBuffer;

typedef struct _TBXMLAttributeBuffer {
	TBXMLAttribute * attributes;
	struct _TBXMLAttributeBuffer * next;
	struct _TBXMLAttributeBuffer * previous;
} TBXMLAttributeBuffer;

// ================================================================================================
//  TBXML Public Interface
// ================================================================================================
@interface TBXML : NSObject {
	
@private
	TBXMLElement * rootXMLElement;
	
	TBXMLElementBuffer * currentElementBuffer;
	TBXMLAttributeBuffer * currentAttributeBuffer;
	
	long currentElement;
	long currentAttribute;
	
	char * bytes;
	long bytesLength;
}

@property (nonatomic, readonly) TBXMLElement * rootXMLElement;

+ (id)tbxmlWithURL:(NSURL*)aURL;
+ (id)tbxmlWithXMLString:(NSString*)aXMLString;
+ (id)tbxmlWithXMLData:(NSData*)aData;
+ (id)tbxmlWithXMLFile:(NSString*)aXMLFile;
+ (id)tbxmlWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension;

- (id)initWithURL:(NSURL*)aURL;
- (id)initWithXMLString:(NSString*)aXMLString;
- (id)initWithXMLData:(NSData*)aData;
- (id)initWithXMLFile:(NSString*)aXMLFile;
- (id)initWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension;

@end

// ================================================================================================
//  TBXML Static Functions Interface
// ================================================================================================

@interface TBXML (StaticFunctions)

+ (NSString*) elementName:(TBXMLElement*)aXMLElement;
+ (NSString*) textForElement:(TBXMLElement*)aXMLElement;
+ (NSString*) valueOfAttributeNamed:(NSString *)aName forElement:(TBXMLElement*)aXMLElement;

+ (NSString*) attributeName:(TBXMLAttribute*)aXMLAttribute;
+ (NSString*) attributeValue:(TBXMLAttribute*)aXMLAttribute;

+ (TBXMLElement*) nextSiblingNamed:(NSString*)aName searchFromElement:(TBXMLElement*)aXMLElement;
+ (TBXMLElement*) childElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

@end
