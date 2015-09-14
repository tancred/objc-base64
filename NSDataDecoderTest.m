#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NSData+Base64.h"


@interface NSDataDecoderTest : XCTestCase
@end


@implementation NSDataDecoderTest

- (void)testEmpty {
	XCTAssertEqualObjects([[NSData data] dataByDecodingBase64:NULL], [NSData data]);
}

@end
