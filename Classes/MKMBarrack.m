//
//  MKMBarrack.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMUser.h"

#import "MKMPolylogue.h"
#import "MKMChatroom.h"
#import "MKMMember.h"

#import "MKMProfile.h"

#import "MKMBarrack+LocalStorage.h"

#import "MKMBarrack.h"

typedef NSMutableDictionary<const MKMAddress *, MKMAccount *> AccountTableM;
typedef NSMutableDictionary<const MKMAddress *, MKMUser *> UserTableM;

typedef NSMutableDictionary<const MKMAddress *, MKMGroup *> GroupTableM;
typedef NSMutableDictionary<const MKMAddress *, MKMMember *> MemberTableM;
typedef NSMutableDictionary<const MKMAddress *, MemberTableM *> GroupMemberTableM;

typedef NSMutableDictionary<const MKMAddress *, const MKMMeta *> MetaTableM;

@interface MKMBarrack () {
    
    AccountTableM *_accountTable;
    UserTableM *_userTable;
    
    GroupTableM *_groupTable;
    GroupMemberTableM *_groupMemberTable;
    
    MetaTableM *_metaTable;
}

@end

/**
 Remove 1/2 objects from the dictionary
 
 @param mDict - mutable dictionary
 */
static inline void reduce_table(NSMutableDictionary *mDict) {
    NSArray *keys = [mDict allKeys];
    MKMAddress *addr;
    for (NSUInteger index = 0; index < keys.count; index += 2) {
        addr = [keys objectAtIndex:index];
        [mDict removeObjectForKey:addr];
    }
}

@implementation MKMBarrack

SingletonImplementations(MKMBarrack, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _accountTable = [[AccountTableM alloc] init];
        _userTable = [[UserTableM alloc] init];
        
        _groupTable = [[GroupTableM alloc] init];
        _groupMemberTable = [[GroupMemberTableM alloc] init];
        
        _metaTable = [[MetaTableM alloc] init];
        
        // delegates
        _accountDelegate = nil;
        _userDataSource = nil;
        _userDelegate = nil;
        
        _groupDataSource = nil;
        _groupDelegate = nil;
        _memberDelegate = nil;
        _chatroomDataSource = nil;
        
        _entityDataSource = nil;
        _profileDataSource = nil;
    }
    return self;
}

- (void)reduceMemory {
    reduce_table(_accountTable);
    reduce_table(_userTable);
    
    reduce_table(_groupTable);
    reduce_table(_groupMemberTable);
    
    reduce_table(_metaTable);
}

- (void)addAccount:(MKMAccount *)account {
    if ([account isKindOfClass:[MKMUser class]]) {
        // add to user table
        [self addUser:(MKMUser *)account];
    } else if (account.ID.isValid) {
        if (account.dataSource == nil) {
            account.dataSource = self;
        }
        [_accountTable setObject:account forKey:account.ID.address];
    }
}

- (void)addUser:(MKMUser *)user {
    if (user.ID.isValid) {
        if (user.dataSource == nil) {
            user.dataSource = self;
        }
        const MKMAddress *key = user.ID.address;
        [_userTable setObject:user forKey:key];
        // erase from account table
        if ([_accountTable objectForKey:key]) {
            [_accountTable removeObjectForKey:key];
        }
    }
}

- (void)addGroup:(MKMGroup *)group {
    if (group.ID.isValid) {
        if (group.dataSource == nil) {
            group.dataSource = self;
        }
        [_groupTable setObject:group forKey:group.ID.address];
    }
}

- (void)addMember:(MKMMember *)member {
    const MKMID *groupID = member.groupID;
    if (groupID.isValid && member.ID.isValid) {
        if (member.dataSource == nil) {
            member.dataSource = self;
        }
        
        MemberTableM *table;
        table = [_groupMemberTable objectForKey:groupID.address];
        if (!table) {
            table = [[MemberTableM alloc] init];
            [_groupMemberTable setObject:table forKey:groupID.address];
        }
        [table setObject:member forKey:member.ID.address];
    }
}

- (BOOL)setMeta:(const MKMMeta *)meta forID:(const MKMID *)ID {
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
        return YES;
    } else {
        NSAssert(false, @"meta error: %@, ID = %@", meta, ID);
        return NO;
    }
}

#pragma mark - MKMMetaDataSource

- (const MKMMeta *)metaForID:(const MKMID *)ID {
    const MKMMeta *meta;
    
    // (a) get from meta cache
    meta = [_metaTable objectForKey:ID.address];
    if (meta) {
        return meta;
    }
    
    // (b) get from meta data source
    NSAssert(_metaDataSource, @"meta data source not set");
    meta = [_metaDataSource metaForID:ID];
    if (meta) {
        [self setMeta:meta forID:ID];
        return meta;
    }
    
    // (c) get from local storage
    meta = [self loadMetaForID:ID];
    if (meta) {
        [self setMeta:meta forID:ID];
        return meta;
    }
    
    NSLog(@"meta not found: %@", ID);
    return nil;
}

#pragma mark - MKMEntityDataSource

- (const MKMMeta *)metaForEntity:(const MKMEntity *)entity {
    const MKMMeta *meta;
    const MKMID *ID = entity.ID;
    
    // (a) get from meta cache
    meta = [_metaTable objectForKey:ID.address];
    if (meta) {
        return meta;
    }
    
    // (b) get from entity data source
    NSAssert(_entityDataSource, @"entity data source not set");
    meta = [_entityDataSource metaForEntity:entity];
    if (meta) {
        [self setMeta:meta forID:ID];
        return meta;
    }
    
    // (c) get from meta data source
    NSAssert(_metaDataSource, @"meta data source not set");
    meta = [_metaDataSource metaForID:ID];
    if (meta) {
        [self setMeta:meta forID:ID];
        return meta;
    }
    
    // (d) get from local storage
    meta = [self loadMetaForID:ID];
    if (meta) {
        [self setMeta:meta forID:ID];
        return meta;
    }
    
    NSLog(@"meta not found: %@", ID);
    return nil;
}

- (NSString *)nameOfEntity:(const MKMEntity *)entity {
    // (a) get from entity data source
    NSString *name = [_entityDataSource nameOfEntity:entity];
    if (name.length > 0) {
        return name;
    }
    
    // (b) get from profile
    MKMProfile *profile = [_profileDataSource profileForID:entity.ID];
    return profile.name;
}

#pragma mark - MKMAccountDelegate

- (MKMAccount *)accountWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error: %@", ID);
    MKMAccount *account;
    
    // (a) get from account cache
    account = [_accountTable objectForKey:ID.address];
    if (account) {
        return account;
    }
    // (b) get from user cache
    account = [_userTable objectForKey:ID.address];
    if (account) {
        return account;
    }
    
    // (c) get from account delegate
    NSAssert(_accountDelegate, @"account delegate not set");
    account = [_accountDelegate accountWithID:ID];
    if (account) {
        [self addAccount:account];
        return account;
    }
    
    // (d) create directly
    account = [[MKMAccount alloc] initWithID:ID];
    [self addAccount:account];
    return account;
}

#pragma mark - MKMUserDataSource

- (NSInteger)numberOfContactsInUser:(const MKMUser *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource numberOfContactsInUser:user];
}

- (const MKMID *)user:(const MKMUser *)user contactAtIndex:(NSInteger)index {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource user:user contactAtIndex:index];
}

#pragma mark - MKMUserDelegate

- (MKMUser *)userWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"user ID error: %@", ID);
    MKMUser *user;
    
    // (a) get from user cache
    user = [_userTable objectForKey:ID.address];
    if (user) {
        return user;
    }
    
    // (b) get from user delegate
    NSAssert(_userDelegate, @"user delegate not set");
    user = [_userDelegate userWithID:ID];
    if (user) {
        [self addUser:user];
        return user;
    }
    
    // (c) create it directly
    user = [[MKMUser alloc] initWithID:ID];
    [self addUser:user];
    return user;
}

- (BOOL)user:(const MKMUser *)user addContact:(const MKMID *)contact {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(MKMNetwork_IsPerson(contact.type), @"contact error: %@", contact);
    NSAssert(_userDelegate, @"user delegate not set");
    return [_userDelegate user:user addContact:contact];
}

- (BOOL)user:(const MKMUser *)user removeContact:(const MKMID *)contact {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(MKMNetwork_IsPerson(contact.type), @"contact error: %@", contact);
    NSAssert(_userDelegate, @"user delegate not set");
    return [_userDelegate user:user removeContact:contact];
}

#pragma mark MKMGroupDataSource

- (const MKMID *)founderOfGroup:(const MKMGroup *)group {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource founderOfGroup:group];
}

- (const MKMID *)ownerOfGroup:(const MKMGroup *)group {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource ownerOfGroup:group];
}

- (NSInteger)numberOfMembersInGroup:(const MKMGroup *)group {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource numberOfMembersInGroup:group];
}

- (const MKMID *)group:(const MKMGroup *)group memberAtIndex:(NSInteger)index {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource group:group memberAtIndex:index];
}

#pragma mark MKMGroupDelegate

- (MKMGroup *)groupWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    MKMGroup *group;
    
    // (a) get from group cache
    group = [_groupTable objectForKey:ID.address];
    if (group) {
        return group;
    }
    
    // (b) get from group delegate
    NSAssert(_groupDelegate, @"group delegate not set");
    group = [_groupDelegate groupWithID:ID];
    if (group) {
        [self addGroup:group];
        return group;
    }
    
    // (c) create directly
    if (ID.type == MKMNetwork_Polylogue) {
        group = [[MKMPolylogue alloc] initWithID:ID];
    } else if (ID.type == MKMNetwork_Chatroom) {
        group = [[MKMChatroom alloc] initWithID:ID];
    } else {
        NSAssert(false, @"group ID type not support: %d", ID.type);
    }
    [self addGroup:group];
    return group;
}

- (BOOL)group:(const MKMGroup *)group addMember:(const MKMID *)member {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(MKMNetwork_IsCommunicator(member.type), @"member error: %@", member);
    NSAssert(_groupDelegate, @"group delegate not set");
    return [_groupDelegate group:group addMember:member];
}

- (BOOL)group:(const MKMGroup *)group removeMember:(const MKMID *)member {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(MKMNetwork_IsCommunicator(member.type), @"member error: %@", member);
    NSAssert(_groupDelegate, @"group delegate not set");
    return [_groupDelegate group:group removeMember:member];
}

#pragma mark MKMMemberDelegate

- (MKMMember *)memberWithID:(const MKMID *)ID groupID:(const MKMID *)gID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"member ID error: %@", ID);
    NSAssert(MKMNetwork_IsGroup(gID.type), @"group ID error: %@", gID);
    
    MemberTableM *table = [_groupMemberTable objectForKey:gID.address];
    MKMMember *member;
    
    // (a) get from group member cache
    member = [table objectForKey:ID.address];
    if (member) {
        return member;
    }
    
    // (b) get from group member delegate
    NSAssert(_memberDelegate, @"member delegate not set");
    member = [_memberDelegate memberWithID:ID groupID:gID];
    if (member) {
        [self addMember:member];
        return member;
    }
    
    // (c) create directly
    member = [[MKMMember alloc] initWithGroupID:gID accountID:ID];
    [self addMember:member];
    return member;
}
                     
#pragma mark MKMChatroomDataSource

- (NSInteger)numberOfAdminsInChatroom:(const MKMChatroom *)grp {
    NSAssert(grp.ID.type == MKMNetwork_Chatroom, @"not a chatroom: %@", grp);
    NSAssert(_chatroomDataSource, @"chatroom data source not set");
    return [_chatroomDataSource numberOfAdminsInChatroom:grp];
}

- (const MKMID *)chatroom:(const MKMChatroom *)grp adminAtIndex:(NSInteger)index {
    NSAssert(grp.ID.type == MKMNetwork_Chatroom, @"not a chatroom: %@", grp);
    NSAssert(_chatroomDataSource, @"chatroom data source not set");
    return [_chatroomDataSource chatroom:grp adminAtIndex:index];
}

#pragma mark - MKMProfileDataSource

- (MKMProfile *)profileForID:(const MKMID *)ID {
    //NSAssert(_profileDataSource, @"profile data source not set");
    MKMProfile *profile = [_profileDataSource profileForID:ID];
    //NSAssert(profile, @"failed to get profile for ID: %@", ID);
    return profile;
}

@end
