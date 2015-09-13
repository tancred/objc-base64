#import <Foundation/Foundation.h>

typedef NS_ENUM(int, GenericBase64DecoderState) {
	GenericBase64DecoderStateBlock,
	GenericBase64DecoderStateChar1,
	GenericBase64DecoderStateChar2,
	GenericBase64DecoderStateChar3,
	GenericBase64DecoderStateChar4,
	GenericBase64DecoderStateIllegal,
	GenericBase64DecoderStateEnd,
};

typedef NS_ENUM(int, GenericBase64DecoderToken) {
	GenericBase64DecoderTokenAlphaFirst = 0,
	GenericBase64DecoderTokenAlphaLast = 63,
	GenericBase64DecoderTokenEOF = 64,
};


@interface GenericBase64Decoder : NSObject
@property GenericBase64DecoderState state;
@property(copy) void (^output)(char *bytes, NSUInteger len);
- (void)input:(int)token;
@end
