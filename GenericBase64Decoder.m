#import "GenericBase64Decoder.h"


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
