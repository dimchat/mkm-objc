//
//  MKMUser.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"

#import "MKMUser.h"

@interface MKMUser ()

@property (strong, nonatomic) MKMPrivateKey *privateKey;

@end

@implementation MKMUser

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID {
    if (self = [super initWithID:ID]) {
        // lazy
        _privateKey = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMUser *user = [super copyWithZone:zone];
    if (user) {
        user.privateKey = _privateKey;
    }
    return user;
}

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = [[desc data] jsonDictionary];
    NSMutableDictionary *info = [dict mutableCopy];
    [info setObject:@(self.contacts.count) forKey:@"contacts"];
    return [info jsonString];
}

- (MKMPrivateKey *)privateKey {
    if (!_privateKey) {
        // try to load private key from the keychain
        _privateKey = [MKMPrivateKey loadKeyWithIdentifier:_ID.address];
        NSAssert(_privateKey, @"failed to load private key: %@", _ID);
    }
    return _privateKey;
}

- (NSArray<const MKMID *> *)contacts {
    NSMutableArray<const MKMID *> *list;
    NSInteger count = [_dataSource numberOfContactsInUser:self];
    list = [[NSMutableArray alloc] initWithCapacity:count];
    const MKMID *ID;
    for (NSInteger index = 0; index < count; ++index) {
        ID = [_dataSource user:self contactAtIndex:index];
        [list addObject:ID];
    }
    return list;
}

- (BOOL)existsContact:(const MKMID *)contact {
    NSInteger count = [_dataSource numberOfContactsInUser:self];
    if (count <= 0) {
        return NO;
    }
    const MKMID *ID;
    while (--count >= 0) {
        ID = [_dataSource user:self contactAtIndex:count];
        if ([ID isEqual:contact]) {
            return YES;
        }
    }
    return NO;
}

@end
