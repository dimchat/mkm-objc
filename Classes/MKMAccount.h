//
//  MKMAccount.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMAccount : MKMEntity

/**
 *  Verify data with signature, use meta.key
 *
 * @param data - message data
 * @param signature - message signature
 * @return true on correct
 */
- (BOOL)verify:(const NSData *)data withSignature:(const NSData *)signature;

/**
 *  Encrypt data, try profile.key first, if not found, use meta.key
 *
 * @param plaintext - message data
 * @return encrypted data
 */
- (NSData *)encrypt:(const NSData *)plaintext;

@end

NS_ASSUME_NONNULL_END
