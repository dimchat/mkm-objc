//
//  MKMImmortals.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPrivateKey.h"
#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMBarrack.h"

//#if DEBUG
//#import "DKDClient.h"
//#endif

#import "MKMImmortals.h"

@interface MKMImmortals () {
    
    NSMutableDictionary<const MKMAddress *, const MKMMeta *> *_metaTable;
    NSMutableDictionary<const MKMAddress *, MKMProfile *> *_profileTable;
    
    NSMutableDictionary<const MKMAddress *, MKMUser *> *_userTable;
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
    MKMID *ID = [dict objectForKey:@"ID"];
    ID = [MKMID IDWithID:ID];
    NSAssert(ID.isValid, @"ID error");
    
    // meta
    MKMMeta *meta = [dict objectForKey:@"meta"];
    meta = [MKMMeta metaWithMeta:meta];
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
        [MKMFacebook() setMeta:meta forID:ID];
    } else {
        NSAssert(false, @"meta error");
    }
    
    // profile
    MKMProfile *profile = [dict objectForKey:@"profile"];
    profile = [MKMProfile profileWithProfile:profile];
    if (profile) {
        [_profileTable setObject:profile forKey:ID.address];
    } else {
        NSAssert(false, @"profile error");
    }
    
    // private key
    MKMPrivateKey *SK = [dict objectForKey:@"privateKey"];
    SK = [MKMPrivateKey keyWithKey:SK];
    if ([meta matchID:ID] && [meta.key isMatch:SK]) {
        // store private key into keychain
        //[SK saveKeyWithIdentifier:ID.address];
    } else {
        NSAssert(false, @"keys not match");
        SK = nil;
    }
    
    // create user
    MKMUser *user = [[MKMUser alloc] initWithID:ID];
    //user.privateKey = SK;
    [_userTable setObject:user forKey:ID.address];
    
//#if DEBUG
//    [[DKDClient sharedInstance] addUser:user];
//#endif
}

#pragma mark - Delegates

- (const MKMMeta *)metaForID:(const MKMID *)ID {
    NSAssert([ID isValid], @"ID invalid");
    return [_metaTable objectForKey:ID.address];
}

- (const MKMMeta *)metaForEntity:(const MKMEntity *)entity {
    const MKMID *ID = entity.ID;
    NSAssert([ID isValid], @"entity ID invalid");
    return [_metaTable objectForKey:ID.address];
}

- (NSString *)nameOfEntity:(const MKMEntity *)entity {
    MKMProfile *profile = [self profileForID:entity.ID];
    return profile.name;
}

- (MKMAccount *)accountWithID:(const MKMID *)ID {
    if (MKMNetwork_IsPerson(ID.type)) {
        return [self userWithID:ID];
    } else {
        // not a person account
        NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error");
        return nil;
    }
}

- (MKMUser *)userWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"user ID error");
    return [_userTable objectForKey:ID.address];
}

- (void)user:(const MKMUser *)user addContact:(const MKMID *)contact {
    NSLog(@"user %@ add contact %@", user, contact);
}

- (void)user:(const MKMUser *)user removeContact:(const MKMID *)contact {
    NSLog(@"user %@ remove contact %@", user, contact);
}

- (MKMProfile *)profileForID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"account ID error");
    return [_profileTable objectForKey:ID.address];
}

@end
