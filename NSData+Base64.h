#import <Foundation/Foundation.h>

@interface NSData (Base64)
- (NSData *)dataByDecodingBase64:(NSError **)error;
@end
