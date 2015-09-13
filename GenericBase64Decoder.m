#import "GenericBase64Decoder.h"


@interface GenericBase64Decoder ()
@property(nonatomic) char *decoded;
@property uint8_t ndecoded;
@end


#define TokenIsAlpha(t)	((t) >= GenericBase64DecoderTokenAlphaFirst && (t) <= GenericBase64DecoderTokenAlphaLast)


@implementation GenericBase64Decoder

- (id)init {
	if (!(self = [super init])) return nil;
	_decoded = (char *)malloc(3);
	return self;
}

- (void)dealloc {
	free(_decoded);
}

- (void)input:(int)token {
	switch (self.state) {
		case GenericBase64DecoderStateBlock:
			// Flush previously decoded block
			if (self.ndecoded > 0 && self.output) {
				self.output(_decoded, self.ndecoded);
			}
			self.ndecoded = 0;

			if (token == GenericBase64DecoderTokenEOF) {
				self.state = GenericBase64DecoderStateEnd;
				return;
			}

			self.state = GenericBase64DecoderStateChar1;
			[self input:token]; // putback
			return;

		case GenericBase64DecoderStateChar1:
			if (TokenIsAlpha(token)) {
				_decoded[0] = token & 0xff; // save(c1)
				self.state = GenericBase64DecoderStateChar2;
				return;
			}
			break;

		case GenericBase64DecoderStateChar2:
			if (TokenIsAlpha(token)) {
				_decoded[1] = token & 0xff; // save(c2)
				_decoded[0] = _decoded[0] << 2 | _decoded[1] >> 4; // write(c1,c2)
				self.ndecoded = 1;
				self.state = GenericBase64DecoderStateChar3;
				return;
			}
			break;

		case GenericBase64DecoderStateChar3:
			if (TokenIsAlpha(token)) {
				_decoded[2] = token & 0xff; // save(c3)
				_decoded[1] = _decoded[1] << 4 | _decoded[2] >> 2; // write(c2,c3)
				self.ndecoded = 2;
				self.state = GenericBase64DecoderStateChar4;
				return;
			} else if (token == GenericBase64DecoderTokenEOF) {
				self.state = GenericBase64DecoderStateBlock;
				[self input:token]; // putback
				return;
			}
			break;

		case GenericBase64DecoderStateChar4:
			if (TokenIsAlpha(token)) {
				_decoded[2] = _decoded[2] << 6 | token; // write(c3,c4)
				self.ndecoded = 3;
				self.state = GenericBase64DecoderStateBlock;
				return;
			} else if (token == GenericBase64DecoderTokenEOF) {
				self.state = GenericBase64DecoderStateBlock;
				[self input:token]; // putback
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
