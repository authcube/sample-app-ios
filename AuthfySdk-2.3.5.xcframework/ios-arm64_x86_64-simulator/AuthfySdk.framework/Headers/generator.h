//
//  generator.h
//  authfy-risk-ios-sdk
//
//  Created by Juliano Lao on 06/08/22.
//
#import <Foundation/Foundation.h>

#ifndef generator_h
#define generator_h

@interface Generator : NSObject

- (NSArray *) enrollment_or_remove:(NSString *)url username:(NSString *)username client_id:(NSString *)client_id access_key:(NSString *)access_key;

- (NSString *) generator:(NSString *)secret period:(NSInteger)period;
- (NSString *) generator:(NSString *)secret period:(NSInteger)period now:(long)now;

// generator function for HOTP
- (NSString *) generatorHOTP:(NSString *)secret counter:(NSInteger)counter;

- (NSArray *) validate:(NSString *)url token:(NSString *)token username:(NSString *)username client_id:(NSString *)client_id access_key:(NSString *)access_key;

- (NSArray *) generateKeyPair:(NSString *)url kty:(NSString *)kty alg:(NSString *)alg ;

- (NSArray *) registerClient:(NSString *)url jwks:(NSString *)jwks;
- (NSArray *) sign:(NSString *)url identifier:(NSString *)identifier exp:(int)exp iat:(long)iat alg:(NSString *)alg key:(NSString *)key data:(NSString *)data;

- (NSString *) generate_ocra:(NSString *)secret question:(NSString *)question suite:(NSString *)suite;;
- (NSArray *) create_ocra:(NSString *)url username:(NSString *)username suite:(NSString *)suite question:(NSString *)question method:(NSString *)method client_id:(NSString *)client_id access_key:(NSString *)access_key;
- (NSArray *) verify_ocra:(NSString *)url username:(NSString *)username token:(NSString *)token client_id:(NSString *)client_id access_key:(NSString *)access_key;
@end

#endif /* generator_h */
