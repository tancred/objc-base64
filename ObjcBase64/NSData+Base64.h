#import <Foundation/Foundation.h>

/*
 * Returns decoded data, or nil if decoding fails.
 * Use the error reporting version if it's important to know the failure reason.
 */

@interface NSData (Base64)
- (NSData *)dataByDecodingBase64;
- (NSData *)dataByDecodingBase64:(NSError **)error;
@end
