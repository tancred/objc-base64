#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NSData+Base64.h"


@interface NSDataDecoderTest : XCTestCase
@end


#define STR2DATA(str) [NSData dataWithBytes:(str) length:strlen((str))]
#define STR2DATAl(str,len) [NSData dataWithBytes:(str) length:(len)]


#define AssertDecodeWorks(encoded,expected) do { \
	NSError *decodeError = nil; \
	NSData *actual = [encoded dataByDecodingBase64:&decodeError]; \
	XCTAssertEqualObjects(actual, expected); \
	XCTAssertNil(decodeError); \
} while (0)


@implementation NSDataDecoderTest

- (void)testEmpty {
	AssertDecodeWorks([NSData data], [NSData data]);
}

- (void)testDecodeBlock {
	AssertDecodeWorks(STR2DATA("AAAA"), STR2DATAl("\0\0\0", 3));
	AssertDecodeWorks(STR2DATA("AAAB"), STR2DATAl("\0\0\x01", 3));
	AssertDecodeWorks(STR2DATA("AAAZ"), STR2DATAl("\0\0\x19", 3));
	AssertDecodeWorks(STR2DATA("AAAa"), STR2DATAl("\0\0\x1a", 3));
	AssertDecodeWorks(STR2DATA("AAAz"), STR2DATAl("\0\0\x33", 3));
	AssertDecodeWorks(STR2DATA("AAA0"), STR2DATAl("\0\0\x34", 3));
	AssertDecodeWorks(STR2DATA("AAA9"), STR2DATAl("\0\0\x3d", 3));
	AssertDecodeWorks(STR2DATA("AAA+"), STR2DATAl("\0\0\x3e", 3));
	AssertDecodeWorks(STR2DATA("AAA/"), STR2DATAl("\0\0\x3f", 3));

	AssertDecodeWorks(STR2DATA("Aa0+"), STR2DATAl("\x01\xad\x3e", 3));
	AssertDecodeWorks(STR2DATA("Yy9/"), STR2DATAl("\x63\x2f\x7f", 3));
	AssertDecodeWorks(STR2DATA("PQfg"), STR2DATAl("\x3d\x07\xe0", 3));
	AssertDecodeWorks(STR2DATA("IPf+"), STR2DATAl("\x20\xf7\xfe", 3));
	AssertDecodeWorks(STR2DATA("BQg/"), STR2DATAl("\x05\x08\x3f", 3));
}

- (void)testErrorOnIllegalInput {
	NSError *error = nil;
	XCTAssertNil([STR2DATA(",") dataByDecodingBase64:&error]);
	XCTAssertNotNil(error);
}

@end
