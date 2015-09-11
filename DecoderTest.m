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
	XCTAssertEqual(self.decoder.c1, 7);
}

- (void)testChar2ToChar3 {
	self.decoder.state = GenericBase64DecoderStateChar2;
	[self.decoder input:7];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateChar3);
	XCTAssertEqual(self.decoder.c2, 7);
}

- (void)testChar3ToChar4 {
	self.decoder.state = GenericBase64DecoderStateChar3;
	[self.decoder input:7];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateChar4);
	XCTAssertEqual(self.decoder.c3, 7);
}

- (void)testChar4ToBlock {
	self.decoder.state = GenericBase64DecoderStateChar4;
	[self.decoder input:7];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateBlock);
	XCTAssertEqual(self.decoder.c4, 7);
}

- (void)testBlockForwardsToChar2 {
	[self.decoder input:1];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateChar2);
	XCTAssertEqual(self.decoder.c1, 1);
}

- (void)testBlockToBlock {
	[self.decoder input:1];
	[self.decoder input:2];
	[self.decoder input:3];
	[self.decoder input:4];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateBlock);
	XCTAssertEqual(self.decoder.c1, 1);
	XCTAssertEqual(self.decoder.c2, 2);
	XCTAssertEqual(self.decoder.c3, 3);
	XCTAssertEqual(self.decoder.c4, 4);
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
	XCTAssertEqual(self.decoder.c3, 0);
}

- (void)testChar4ToEndOnEOF {
	self.decoder.state = GenericBase64DecoderStateChar4;
	[self.decoder input:GenericBase64DecoderTokenEOF];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateEnd);
	XCTAssertEqual(self.decoder.c4, 0);
}

- (void)testChar1Illegal {
	self.decoder.state = GenericBase64DecoderStateChar1;
	[self.decoder input:GenericBase64DecoderTokenEOF];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
	XCTAssertEqual(self.decoder.c1, 0);
}

- (void)testChar2Illegal {
	self.decoder.state = GenericBase64DecoderStateChar2;
	[self.decoder input:GenericBase64DecoderTokenEOF];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
	XCTAssertEqual(self.decoder.c2, 0);
}

- (void)testChar3Illegal {
	self.decoder.state = GenericBase64DecoderStateChar3;
	[self.decoder input:65];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
	XCTAssertEqual(self.decoder.c3, 0);
}

- (void)testChar4Illegal {
	self.decoder.state = GenericBase64DecoderStateChar4;
	[self.decoder input:65];
	XCTAssertEqual(self.decoder.state, GenericBase64DecoderStateIllegal);
	XCTAssertEqual(self.decoder.c4, 0);
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

@end
