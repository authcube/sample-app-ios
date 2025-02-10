//
//  Base32.h
//  authfy-risk-ios-sdk
//
//  Base32 -- RFC 4648 compatible implementation
//  see http://www.ietf.org/rfc/rfc4648.txt for more details
//
//  Created by Juliano Lao on 06/08/22, based on Dave Poirier project
//

#ifndef Base32Extras_h
#define Base32Extras_h

#import <Foundation/Foundation.h>

#define NSBase32StringEncoding  0x4D467E32

@interface NSString (Base32Extras)
+(NSString *)stringFromBase32String:(NSString *)base32String;
-(NSString *)base32String;
@end

@interface NSData (Base32Extras)
+(NSData *)dataWithBase32String:(NSString *)base32String;
-(NSString *)base32String;
@end

@interface MF_Base32Codec : NSObject
+(NSData *)dataFromBase32String:(NSString *)base32String;
+(NSString *)base32StringFromData:(NSData *)data;
@end

#endif /* Base32_h */
