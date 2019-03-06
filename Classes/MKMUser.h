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

@interface MKMUser : MKMAccount {
    
    MKMPrivateKey *_privateKey;
}

@property (readonly, strong, nonatomic) MKMPrivateKey *privateKey;

@property (readonly, strong, nonatomic) NSArray<const MKMID *> *contacts;

- (BOOL)existsContact:(const MKMID *)contact;

@end

#pragma mark - User Delegate

@protocol MKMUserDataSource <MKMAccountDataSource>

/**
 Get contacts count
 */
- (NSInteger)numberOfContactsInUser:(const MKMUser *)user;

/**
 Get contact ID at index
 */
- (MKMID *)user:(const MKMUser *)user contactAtIndex:(NSInteger)index;

@end

@protocol MKMUserDelegate <MKMAccountDelegate>

/**
 User factory
 */
- (MKMUser *)userWithID:(const MKMID *)ID;

/**
 Add contact for user
 */
- (void)user:(const MKMUser *)user addContact:(const MKMID *)contact;

/**
 Remove contact of user
 */
- (void)user:(const MKMUser *)user removeContact:(const MKMID *)contact;

@end

NS_ASSUME_NONNULL_END
