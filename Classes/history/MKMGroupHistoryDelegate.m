//
//  MKMGroupHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMEntity.h"
#import "MKMGroup.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMBarrack.h"

#import "MKMGroupHistoryDelegate.h"

@interface MKMGroup (Hacking)

@property (strong, nonatomic) const MKMID *founder;

@end

@implementation MKMGroupHistoryDelegate

- (BOOL)evolvingEntity:(const MKMEntity *)entity
        canWriteRecord:(const MKMHistoryBlock *)record {
    // call super check
    if (![super evolvingEntity:entity canWriteRecord:record]) {
        return NO;
    }
    
    MKMID *recorder = [MKMID IDWithID:record.recorder];
    NSAssert([recorder isValid], @"recorder error: %@", recorder);
    
    NSAssert([entity isKindOfClass:[MKMGroup class]], @"entity must be a group: %@", entity);
    MKMGroup *social = (MKMGroup *)entity;
    NSArray *members = social.members;
    NSAssert(members.count > 0, @"members cannot be empty");
    
    // check member confirms for each transaction
    // it must be confirmed by more than 50% members to write history record
    for (id tx in record.transactions) {
        NSInteger confirm_count = 1; // include the recorder as default
        MKMHistoryTransaction *event;
        event = [MKMHistoryTransaction transactionWithTransaction:tx];
        for (MKMAddress *addr in event.confirmations) {
            // is it the recorder?
            if ([recorder.address isEqual:addr]) {
                // the recorder not need to confirm, skip it
                continue;
            }
            // is it a member?
            for (id m in members) {
                MKMID *mid = [MKMID IDWithID:m];
                if ([mid.address isEqual:addr]) {
                    // address match a member
                    NSData *confirm = [event confirmationForID:mid];
                    MKMPublicKey *PK = MKMPublicKeyForID(mid);
                    if ([PK verify:record.signature withSignature:confirm]) {
                        ++confirm_count;
                    } else {
                        NSAssert(false, @"confirmation error");
                    }
                    // address processing finished
                    break;
                }
            }
            // go next confirmation
        }
        // must more than 50%, include the recorder
        if (confirm_count * 2 <= members.count) {
            NSAssert(false, @"confirmations not enough for %@", tx);
            return NO;
        }
    }
    
    BOOL isOwner = [social.owner isEqual:recorder];
    BOOL isMember = [social existsMember:recorder];
    
    // 1. owner
    if (isOwner) {
        // owner can do anything!
        return YES;
    }
    
    // 2. member
    if (isMember) {
        // allow all members to write history record,
        // let the subclass to reduce it
        return YES;
    }
    
    // 3. others
    if (!isOwner && !isMember) {
        // if someone want to join the group,
        // he must ask the owner or any member to help
        // to write a record in the history
        return NO;
    }
    
    // let the subclass to extend the permission control
    return YES;
}

- (BOOL)evolvingEntity:(const MKMEntity *)entity
           canRunEvent:(const MKMHistoryTransaction *)event
              recorder:(const MKMID *)recorder {
    // call super check
    if (![super evolvingEntity:entity canRunEvent:event recorder:recorder]) {
        return NO;
    }
    
    // check commander
    const MKMID *commander = event.commander;
    if (!commander) {
        commander = recorder;
    }
    
    MKMHistoryOperation *operation = event.operation;
    operation = [MKMHistoryOperation operationWithOperation:operation];
    
    NSAssert([entity isKindOfClass:[MKMGroup class]], @"entity must be a group: %@", entity);
    MKMGroup *social = (MKMGroup *)entity;
    
    BOOL isOwner = [social.owner isEqual:commander];
    BOOL isMember = [social existsMember:commander];
    
    const NSString *op = operation.command;
    // first record
    if (social.founder == nil) {
        if ([op isEqualToString:@"found"] ||
            [op isEqualToString:@"create"]) {
            // only founder
            if (![social.founder isEqual:commander]) {
                NSAssert(false, @"only founder can create");
                return NO;
            }
        } else {
            NSAssert(false, @"first record must be 'found' or 'create'.");
            return NO;
        }
    } else if ([op isEqualToString:@"abdicate"]) {
        // only owner
        if (!isOwner) {
            NSAssert(false, @"only owner can abdicate");
            return NO;
        }
    } else if ([op isEqualToString:@"name"] ||
               [op isEqualToString:@"setName"]) {
        // all members
        //    let the subclass to reduce it
        if (!isMember) {
            return NO;
        }
    } else if ([op isEqualToString:@"invite"]) {
        // all members
        //    let the subclass to reduce it
        if (!isMember) {
            return NO;
        }
    } else if ([op isEqualToString:@"expel"]) {
        // all members
        //    let the subclass to reduce it
        if (!isMember) {
            return NO;
        }
    } else if ([op isEqualToString:@"join"]) {
        // others
        if (isMember) {
            NSAssert(false, @"you are already a member");
            return NO;
        }
    } else if ([op isEqualToString:@"quit"]) {
        // all members except owner
        //    forbide the owner to quit directly
        if (isOwner) {
            NSAssert(false, @"owner cannot quit, abdicate first");
            return NO;
        }
        if (!isMember) {
            NSAssert(false, @"you are not a member");
            return NO;
        }
    }
    
    // let the subclass to extend the permission list
    return YES;
}

- (void)evolvingEntity:(MKMEntity *)entity
               execute:(const MKMHistoryOperation *)operation
             commander:(const MKMID *)commander {
    // call super execute
    [super evolvingEntity:entity execute:operation commander:commander];
    
    NSAssert([entity isKindOfClass:[MKMGroup class]], @"entity must be a group: %@", entity);
    MKMGroup *social = (MKMGroup *)entity;
    
    const NSString *op = operation.command;
    if ([op isEqualToString:@"found"] ||
        [op isEqualToString:@"create"]) {
        NSAssert(social.founder == nil, @"founder should not be set yet");
        // founder
        MKMID *founder = [operation objectForKey:@"founder"];
        NSAssert(founder, @"founder cannot be empty");
        founder = [MKMID IDWithID:founder];
        social.founder = founder;
        
        // first owner
        NSAssert(!social.owner, @"owner should not be set yet");
        MKMID *owner = [operation objectForKey:@"owner"];
        if (owner) {
            owner = [MKMID IDWithID:owner];
            // TODO: set owner
            //social.owner = owner;
        } else {
            // TODO: founder is the first owner as default
            //social.owner = founder;
        }
    } else if ([op isEqualToString:@"abdicate"]) {
        NSAssert([social.owner isEqual:commander], @"permission denied");
        // abdicate the ownership
        MKMID *owner = [operation objectForKey:@"owner"];
        if (owner) {
            owner = [MKMID IDWithID:owner];
            // TODO: change owner
            //social.owner = owner;
        }
    } else if ([op isEqualToString:@"invite"]) {
        // invite user to member
        MKMID *user = [operation objectForKey:@"user"];
        if (!user) {
            user = [operation objectForKey:@"member"];
        }
        if (user) {
            user = [MKMID IDWithID:user];
            // TODO: invite
            //[social addMember:user];
        }
    } else if ([op isEqualToString:@"expel"]) {
        // expel member
        MKMID *member = [operation objectForKey:@"member"];
        if (member) {
            member = [MKMID IDWithID:member];
            // TODO: expel
            //[social removeMember:member];
        }
    } else if ([op isEqualToString:@"join"]) {
        // TODO: join
        //[social addMember:commander];
    } else if ([op isEqualToString:@"quit"]) {
        // TODO: quit
        //[social removeMember:commander];
    } else if ([op isEqualToString:@"name"] ||
               [op isEqualToString:@"setName"]) {
        // set name
        NSString *name = [operation objectForKey:@"name"];
        if (name) {
            // TODO: set name
            //social.name = name;
        }
    }
}

@end
