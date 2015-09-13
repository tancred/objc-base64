#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "GenericBase64Decoder.h"


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

- (void)testChar1ToChar2 {
	self.decoder.state = GenericBase64DecoderStateChar1;
	[self.decoder input:7];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateChar2);
}

- (void)testChar2ToChar3 {
	self.decoder.state = GenericBase64DecoderStateChar2;
	[self.decoder input:7];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateChar3);
}

- (void)testChar3ToChar4 {
	self.decoder.state = GenericBase64DecoderStateChar3;
	[self.decoder input:7];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateChar4);
}

- (void)testChar4ToBlock {
	self.decoder.state = GenericBase64DecoderStateChar4;
	[self.decoder input:7];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateBlock);
}

- (void)testBlockForwardsToChar2 {
	[self.decoder input:1];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateChar2);
}

- (void)testBlockToBlock {
	[self.decoder input:1];
	[self.decoder input:2];
	[self.decoder input:3];
	[self.decoder input:4];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateBlock);
}

- (void)testBlockToEndOnEOF {
	self.decoder.state = GenericBase64DecoderStateBlock;
	[self.decoder input:GenericBase64DecoderTokenEOF];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateEnd);
}

- (void)testChar3ToEndOnEOF {
	self.decoder.state = GenericBase64DecoderStateChar3;
	[self.decoder input:GenericBase64DecoderTokenEOF];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateEnd);
}

- (void)testChar4ToEndOnEOF {
	self.decoder.state = GenericBase64DecoderStateChar4;
	[self.decoder input:GenericBase64DecoderTokenEOF];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateEnd);
}

- (void)testChar1Illegal {
	self.decoder.state = GenericBase64DecoderStateChar1;
	[self.decoder input:GenericBase64DecoderTokenEOF];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
}

- (void)testChar2Illegal {
	self.decoder.state = GenericBase64DecoderStateChar2;
	[self.decoder input:GenericBase64DecoderTokenEOF];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
}

- (void)testChar3Illegal {
	self.decoder.state = GenericBase64DecoderStateChar3;
	[self.decoder input:65];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
}

- (void)testChar4Illegal {
	self.decoder.state = GenericBase64DecoderStateChar4;
	[self.decoder input:65];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
}

- (void)testIllegalIsTerminal {
	self.decoder.state = GenericBase64DecoderStateIllegal;
	[self.decoder input:2];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
}

- (void)testEndIsTerminal {
	self.decoder.state = GenericBase64DecoderStateEnd;
	[self.decoder input:2];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateEnd);
}

- (void)testDecode2CharBlock {
	__block NSMutableData *decoded = [NSMutableData new];
	self.decoder.output = ^(char *bytes, NSUInteger len) {
		[decoded appendBytes:bytes length:len];
	};
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:GenericBase64DecoderTokenEOF];

	XCTAssertEqualObjects(decoded, [NSData dataWithBytes:"\x86" length:1]);
}

- (void)testDecode3CharBlock {
	__block NSMutableData *decoded = [NSMutableData new];
	self.decoder.output = ^(char *bytes, NSUInteger len) {
		[decoded appendBytes:bytes length:len];
	};
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:GenericBase64DecoderTokenEOF];

	XCTAssertEqualObjects(decoded, [NSData dataWithBytes:"\x86\x18" length:2]);
}

- (void)testDecode4CharBlock {
	__block NSMutableData *decoded = [NSMutableData new];
	self.decoder.output = ^(char *bytes, NSUInteger len) {
		[decoded appendBytes:bytes length:len];
	};
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:GenericBase64DecoderTokenEOF];

	XCTAssertEqualObjects(decoded, [NSData dataWithBytes:"\x86\x18\x61" length:3]);
}

- (void)testDecodeEmitsOnNewBlock {
	// Note: testing an implementation detail. Maybe we should provide a -flush method?
	__block NSMutableData *decoded = [NSMutableData new];
	self.decoder.output = ^(char *bytes, NSUInteger len) {
		[decoded appendBytes:bytes length:len];
	};
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:33];
	[self.decoder input:0];

	XCTAssertEqualObjects(decoded, [NSData dataWithBytes:"\x86\x18\x61" length:3]);
}

@end
