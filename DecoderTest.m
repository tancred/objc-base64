#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>


typedef NS_ENUM(int, GenericBase64DecoderState) {
	GenericBase64DecoderStateStart,
};


@interface GenericBase64Decoder : NSObject
@property GenericBase64DecoderState state;
@property(copy) void (^output)(char *bytes, NSUInteger numberOfBytes);
- (void)input:(int)token;
@end

#define STR2DATA(s) [NSData dataWithBytes:(s) length:strlen((s))]

@interface DecoderTest : XCTestCase
@property(strong) GenericBase64Decoder *decoder;
@property(strong) NSMutableData *encoded;
@end


@implementation DecoderTest

- (void)setUp {
	self.encoded = [NSMutableData new];
	self.decoder = [GenericBase64Decoder new];

	__block NSMutableData *destination = self.encoded;
	self.decoder.output = ^(char *bytes, NSUInteger len) {
		[destination appendBytes:bytes length:len];
	};
}

- (void)tearDown {
	self.decoder = nil;
	self.encoded = nil;
}

- (void)testSomething {
	[self.decoder input:'a'];
	XCTAssertEqualObjects(self.encoded, STR2DATA("abbb"));
}

@end


@implementation GenericBase64Decoder

- (void)input:(int)token {
	char c = (char)(token & 0xff);
	if (self.output) self.output(&c, 1);
	if (self.output) self.output("bbb", 3);
}

@end
