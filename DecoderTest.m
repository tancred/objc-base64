#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>


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
@property int c1;
@property int c2;
@property int c3;
@property int c4;
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


// internal
#define TokenIsAlpha(t)	((t) >= GenericBase64DecoderTokenAlphaFirst && (t) <= GenericBase64DecoderTokenAlphaLast)


@implementation GenericBase64Decoder

- (void)input:(int)token {
	switch (self.state) {
		case GenericBase64DecoderStateBlock:
			if (token == GenericBase64DecoderTokenEOF) {
				self.state = GenericBase64DecoderStateEnd;
				return;
			}
			self.state = GenericBase64DecoderStateChar1;
			[self input:token];
			return;

		case GenericBase64DecoderStateChar1:
			if (TokenIsAlpha(token)) {
				self.c1 = token;
				self.state = GenericBase64DecoderStateChar2;
				return;
			}
			break;

		case GenericBase64DecoderStateChar2:
			if (TokenIsAlpha(token)) {
				self.c2 = token;
				self.state = GenericBase64DecoderStateChar3;
				return;
			}
			break;

		case GenericBase64DecoderStateChar3:
			if (TokenIsAlpha(token)) {
				self.c3 = token;
				self.state = GenericBase64DecoderStateChar4;
				return;
			} else if (token == GenericBase64DecoderTokenEOF) {
				self.state = GenericBase64DecoderStateBlock;
				[self input:token];
				return;
			}
			break;

		case GenericBase64DecoderStateChar4:
			if (TokenIsAlpha(token)) {
				self.c4 = token;
				self.state = GenericBase64DecoderStateBlock;
				return;
			} else if (token == GenericBase64DecoderTokenEOF) {
				self.state = GenericBase64DecoderStateBlock;
				[self input:token];
				return;
			}
			break;

		case GenericBase64DecoderStateIllegal:
			/* intentional fallthrough */
		case GenericBase64DecoderStateEnd:
			return;
	}

	self.state = GenericBase64DecoderStateIllegal;
}

@end
