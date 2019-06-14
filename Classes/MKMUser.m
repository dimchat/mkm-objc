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

@implementation MKMUser

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = [[desc data] jsonDictionary];
    NSMutableDictionary *info = [dict mutableCopy];
    [info setObject:@(self.contacts.count) forKey:@"contacts"];
    return [info jsonString];
}

- (NSData *)sign:(const NSData *)data {
    NSAssert(_dataSource, @"user data source not set yet");
    MKMPrivateKey *key = [_dataSource privateKeyForSignatureOfUser:_ID];
    return [key sign:data];
}

- (NSData *)decrypt:(const NSData *)ciphertext {
    NSAssert(_dataSource, @"user data source not set yet");
    NSArray<MKMPrivateKey *> *keys = [_dataSource privateKeysForDecryptionOfUser:_ID];
    NSData *plaintext = nil;
    for (MKMPrivateKey *key in keys) {
        plaintext = [key decrypt:ciphertext];
        if (plaintext != nil) {
            // OK!
            break;
        }
    }
    return plaintext;
}

#pragma mark Contacts of User

- (NSArray<const MKMID *> *)contacts {
    NSAssert(_dataSource, @"user data source not set yet");
    NSArray *list = [_dataSource contactsOfUser:_ID];
    return [list copy];
}

- (BOOL)existsContact:(const MKMID *)ID {
    NSAssert(_dataSource, @"user data source not set yet");
    NSArray<const MKMID *> *contacts = [self contacts];
    NSInteger count = [contacts count];
    if (count <= 0) {
        return NO;
    }
    const MKMID *contact;
    while (--count >= 0) {
        contact = [contacts objectAtIndex:count];
        if ([contact isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

@end
