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
				char x = self.c1 << 2 | self.c2 >> 4;
				if (self.output) self.output(&x, 1);
				return;
			}
			break;

		case GenericBase64DecoderStateChar3:
			if (TokenIsAlpha(token)) {
				self.c3 = token;
				self.state = GenericBase64DecoderStateChar4;
				char x = self.c2 << 4 | self.c3 >> 2;
				if (self.output) self.output(&x, 1);
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
				char x = self.c3 << 6 | self.c4;
				if (self.output) self.output(&x, 1);
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
