#import "NSData+Base64.h"
#import "GenericBase64Decoder.h"


static int ByteToBase64Token(char c);


@implementation NSData (Base64)

- (NSData *)dataByDecodingBase64:(NSError **)error {
	NSUInteger length = [self length];
	if (length == 0) return [NSData data];

	__block NSMutableData *decoded = [NSMutableData new];
	GenericBase64Decoder *decoder = [GenericBase64Decoder new];
	decoder.output = ^(char *b, NSUInteger len) {
		[decoded appendBytes:b length:len];
	};

	const char *encoded = [self bytes];
	for (NSUInteger i=0; i<length; i++) {
		[decoder input:ByteToBase64Token(encoded[i])];
		if (decoder.state == GenericBase64DecoderStateIllegal) break;
	}

	[decoder input:GenericBase64DecoderTokenEOF];

	return decoded;
}

@end


static int ByteToBase64Token(char c) {
	if (c >= 'A' && c <= 'Z') return c - 'A';
	if (c >= 'a' && c <= 'z') return c - 'a' + 26;
	if (c >= '0' && c <= '9') return c - '0' + 52;
	if (c == '+') return 62;
	if (c == '/') return 63;
	return GenericBase64DecoderTokenOther;
}
