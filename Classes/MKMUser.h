//
//  MKMUser.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPrivateKey;
@class MKMContact;

@interface MKMUser : MKMAccount

@property (readonly, copy, nonatomic) NSArray<const MKMID *> *contacts;

- (BOOL)existsContact:(const MKMID *)ID;

/**
 *  Sign data with user's private key
 *
 * @param data - message data
 * @return signature
 */
- (NSData *)sign:(const NSData *)data;

/**
 *  Decrypt data with user's private key
 *
 * @param ciphertext - encrypted data
 * @return plain text
 */
- (NSData *)decrypt:(const NSData *)ciphertext;

@end

#pragma mark - User Data Source

@protocol MKMUserDataSource <MKMEntityDataSource>

/**
 *  Get user's private key
 *
 * @param user - user ID
 * @return private key
 */
- (MKMPrivateKey *)privateKeyForSignatureOfUser:(const MKMID *)user;

/**
 *  Get user's private keys for decryption
 *
 * @param user - user ID
 * @return private key
 */
- (NSArray<MKMPrivateKey *> *)privateKeysForDecryptionOfUser:(const MKMID *)user;

/**
 *  Get contacts list
 *
 * @param user - user ID
 * @return contacts list (ID)
 */
- (NSArray<const MKMID *> *)contactsOfUser:(const MKMID *)user;

@end

NS_ASSUME_NONNULL_END
