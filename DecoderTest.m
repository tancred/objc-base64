#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>


typedef NS_ENUM(int, GenericBase64DecoderState) {
	GenericBase64DecoderStateBlock,
};


@interface GenericBase64Decoder : NSObject
@property GenericBase64DecoderState state;
- (void)input:(int)token;
@end


@interface DecoderTest : XCTestCase
@property(strong) GenericBase64Decoder *decoder;
@end


@implementation DecoderTest

- (void)setUp {
	self.decoder = [GenericBase64Decoder new];
}

- (void)tearDown {
	self.decoder = nil;
}

- (void)testInitialState {
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateBlock);
}

@end


@implementation GenericBase64Decoder

- (void)input:(int)token {
}

@end
