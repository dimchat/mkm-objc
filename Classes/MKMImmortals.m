// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  MKMImmortals.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMImmortals.h"

@interface MKMUser (Hacking)

@property (strong, nonatomic) MKMPrivateKey *privateKey;

@end

@interface MKMImmortals () {
    
    NSMutableDictionary<MKMAddress *, MKMMeta *> *_metaTable;
    NSMutableDictionary<MKMAddress *, MKMProfile *> *_profileTable;
    
    NSMutableDictionary<MKMAddress *, MKMUser *> *_userTable;
}

@end

@implementation MKMImmortals

- (instancetype)init {
    if (self = [super init]) {
        _metaTable    = [[NSMutableDictionary alloc] initWithCapacity:2];
        _profileTable = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        _userTable    = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        [self _loadBuiltInAccount:@"mkm_hulk"];
        [self _loadBuiltInAccount:@"mkm_moki"];
    }
    return self;
}

- (void)_loadBuiltInAccount:(NSString *)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];//[NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        NSAssert(false, @"file not exists: %@", path);
        return ;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // ID
    MKMID *ID = MKMIDFromString([dict objectForKey:@"ID"]);
    NSAssert([ID isValid], @"ID error: %@", ID);
    
    // meta
    MKMMeta *meta = MKMMetaFromDictionary([dict objectForKey:@"meta"]);
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
    } else {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
    }
    
    // private key
    MKMPrivateKey *SK = [dict objectForKey:@"privateKey"];
    SK = MKMPrivateKeyFromDictionary(SK);
    if ([meta matchID:ID] && [meta.key isMatch:SK]) {
        // store private key into keychain
        [SK saveKeyWithIdentifier:ID.address];
    } else {
        NSAssert(false, @"keys not match: %@, meta: %@", SK, meta);
        SK = nil;
    }
    
    // profile
    MKMProfile *profile = MKMProfileFromDictionary([dict objectForKey:@"profile"]);
    if ([profile verify:meta.key]) {
        [_profileTable setObject:profile forKey:ID.address];
    } else if (![profile sign:SK]) {
        NSAssert(false, @"profile not fould: %@", dict);
    }
    
    // create user
    MKMUser *user = [[MKMUser alloc] initWithID:ID];
    user.dataSource = self;
    //user.privateKey = SK;
    [_userTable setObject:user forKey:ID.address];
    
    NSLog(@"loaded immortal account: %@", [user description]);
}

- (nullable MKMUser *)userWithID:(MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"user ID error: %@", ID);
    return [_userTable objectForKey:ID.address];
}

#pragma mark - Delegates

- (nullable MKMMeta *)metaForID:(MKMID *)ID {
    NSAssert([ID isValid], @"ID invalid: %@", ID);
    return [_metaTable objectForKey:ID.address];
}

- (nullable __kindof MKMProfile *)profileForID:(MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"user ID error: %@", ID);
    return [_profileTable objectForKey:ID.address];
}

- (nullable MKMPrivateKey *)privateKeyForSignatureOfUser:(MKMID *)user {
    return [MKMPrivateKey loadKeyWithIdentifier:user.address];
}

- (nullable NSArray<MKMPrivateKey *> *)privateKeysForDecryptionOfUser:(MKMID *)user {
    MKMPrivateKey *key = [MKMPrivateKey loadKeyWithIdentifier:user.address];
    return [[NSArray alloc] initWithObjects:key, nil];
}

- (nullable NSArray<MKMID *> *)contactsOfUser:(MKMID *)user {
    NSMutableArray<MKMID *> *list = [[NSMutableArray alloc] initWithCapacity:2];
    [list addObject:MKMIDFromString(MKM_MONKEY_KING_ID)];
    [list addObject:MKMIDFromString(MKM_IMMORTAL_HULK_ID)];
    return list;
}

@end
