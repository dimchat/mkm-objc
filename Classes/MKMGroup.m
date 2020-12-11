// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  MKMGroup.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDataParser.h"

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMProfile.h"

#import "MKMGroup.h"

@interface MKMGroup () {
    
    id<MKMID> _founder;
}

@property (strong, nonatomic) id<MKMID> founder;

@end

@implementation MKMGroup

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID {
    if (self = [super initWithID:ID]) {
        _founder = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMGroup *group = [super copyWithZone:zone];
    if (group) {
        group.founder = _founder;
    }
    return group;
}

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = MKMJSONDecode(MKMUTF8Encode(desc));
    NSMutableDictionary *info;
    if ([dict isKindOfClass:[NSMutableDictionary class]]) {
        info = (NSMutableDictionary *)dict;
    } else {
        info = [dict mutableCopy];
    }
    [info setObject:@(self.members.count) forKey:@"members"];
    return MKMUTF8Decode(MKMJSONEncode(info));
}

- (id<MKMID>)founder {
    if (!_founder) {
        NSAssert(self.dataSource, @"group data source not set yet");
        _founder = [self.dataSource founderOfGroup:_ID];
        if (!_founder && MKMIDIsBroadcast(_ID)) {
            // founder of broadcast group
            NSString *founder;
            NSString *name = [_ID name];
            NSUInteger len = [name length];
            if (len == 0 || (len == 8 && [name isEqualToString:@"everyone"])) {
                // Consensus: the founder of group 'everyone@everywhere'
                //            'Albert Moky'
                founder = @"moky@anywhere";
            } else {
                // DISCUSS: who should be the founder of group 'xxx@everywhere'?
                //          'anyone@anywhere', or 'xxx.founder@anywhere'
                founder = [name stringByAppendingString:@".founder@anywhere"];
            }
            _founder = MKMIDFromString(founder);
        }
    }
    return _founder;
}

- (id<MKMID>)owner {
    NSAssert(self.dataSource, @"group data source not set yet");
    id<MKMID> admin = [self.dataSource ownerOfGroup:_ID];
    if (!admin && MKMIDIsBroadcast(_ID)) {
        // owner of broadcast group
        NSString *owner;
        NSString *name = [_ID name];
        NSUInteger len = [name length];
        if (len == 0 || (len == 8 && [name isEqualToString:@"everyone"])) {
            // Consensus: the owner of group 'everyone@everywhere'
            //            'anyone@anywhere'
            owner = @"anyone@anywhere";
        } else {
            // DISCUSS: who should be the owner of group 'xxx@everywhere'?
            //          'anyone@anywhere', or 'xxx.owner@anywhere'
            owner = [name stringByAppendingString:@".owner@anywhere"];
        }
        admin = MKMIDFromString(owner);
    }
    return admin;
}

- (NSArray<id<MKMID>> *)members {
    NSAssert(self.dataSource, @"group data source not set yet");
    NSArray *list = [self.dataSource membersOfGroup:_ID];
    // check for broadcast
    if (!list && MKMIDIsBroadcast(_ID)) {
        NSString *member;
        NSString *owner;
        NSString *name = [_ID name];
        NSUInteger len = [name length];
        if (len == 0 || (len == 8 && [name isEqualToString:@"everyone"])) {
            // Consensus: the member of group 'everyone@everywhere'
            //            'anyone@anywhere'
            member = @"anyone@anywhere";
            owner = @"anyone@anywhere";
        } else {
            // DISCUSS: who should be the member of group 'xxx@everywhere'?
            //          'anyone@anywhere', or 'xxx.member@anywhere'
            member = [name stringByAppendingString:@".member@anywhere"];
            owner = [name stringByAppendingString:@".owner@anywhere"];
        }
        // add owner first
        NSMutableArray *mArray = [[NSMutableArray alloc] init];
        id<MKMID>admin = MKMIDFromString(owner);
        if (admin) {
            [mArray addObject:admin];
        }
        id<MKMID>ID = MKMIDFromString(member);
        if (ID && ![ID isEqual:admin]) {
            [mArray addObject:ID];
        }
        list = mArray;
    } else {
        list = [list mutableCopy];
    }
    return list;
}

@end
