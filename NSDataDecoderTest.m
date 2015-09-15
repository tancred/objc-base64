#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NSData+Base64.h"


@interface NSDataDecoderTest : XCTestCase
@end


#define STR2DATA(str) [NSData dataWithBytes:(str) length:strlen((str))]
#define STR2DATAl(str,len) [NSData dataWithBytes:(str) length:(len)]


@implementation NSDataDecoderTest

- (void)testEmpty {
	XCTAssertEqualObjects([[NSData data] dataByDecodingBase64:NULL], [NSData data]);
}

- (void)testDecodeBlock {
	NSError *error = nil;
	XCTAssertEqualObjects([STR2DATA("AAAA") dataByDecodingBase64:&error], STR2DATAl("\0\0\0", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("AAAB") dataByDecodingBase64:&error], STR2DATAl("\0\0\x01", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("AAAZ") dataByDecodingBase64:&error], STR2DATAl("\0\0\x19", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("AAAa") dataByDecodingBase64:&error], STR2DATAl("\0\0\x1a", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("AAAz") dataByDecodingBase64:&error], STR2DATAl("\0\0\x33", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("AAA0") dataByDecodingBase64:&error], STR2DATAl("\0\0\x34", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("AAA9") dataByDecodingBase64:&error], STR2DATAl("\0\0\x3d", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("AAA+") dataByDecodingBase64:&error], STR2DATAl("\0\0\x3e", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("AAA/") dataByDecodingBase64:&error], STR2DATAl("\0\0\x3f", 3), @"error: %@", error);

	XCTAssertEqualObjects([STR2DATA("Aa0+") dataByDecodingBase64:&error], STR2DATAl("\x01\xad\x3e", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("Yy9/") dataByDecodingBase64:&error], STR2DATAl("\x63\x2f\x7f", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("PQfg") dataByDecodingBase64:&error], STR2DATAl("\x3d\x07\xe0", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("IPf+") dataByDecodingBase64:&error], STR2DATAl("\x20\xf7\xfe", 3), @"error: %@", error);
	XCTAssertEqualObjects([STR2DATA("BQg/") dataByDecodingBase64:&error], STR2DATAl("\x05\x08\x3f", 3), @"error: %@", error);
}

@end
