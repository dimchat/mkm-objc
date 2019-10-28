//
//  MKMLocalUser.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"

#import "MKMLocalUser.h"

@implementation MKMLocalUser

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = [[desc data] jsonDictionary];
    NSMutableDictionary *info = [dict mutableCopy];
    [info setObject:@(self.contacts.count) forKey:@"contacts"];
    return [info jsonString];
}

- (NSData *)sign:(NSData *)data {
    NSAssert(self.dataSource, @"user data source not set yet");
    MKMPrivateKey *key = [self.dataSource privateKeyForSignatureOfUser:_ID];
    NSAssert(key, @"failed to get private key for signature: %@", _ID);
    return [key sign:data];
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    NSAssert(self.dataSource, @"user data source not set yet");
    NSArray<MKMPrivateKey *> *keys = [self.dataSource privateKeysForDecryptionOfUser:_ID];
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

- (NSArray<MKMID *> *)contacts {
    NSAssert(self.dataSource, @"user data source not set yet");
    NSArray *list = [self.dataSource contactsOfUser:_ID];
    return [list copy];
}

- (BOOL)existsContact:(MKMID *)ID {
    NSAssert(self.dataSource, @"user data source not set yet");
    NSArray<MKMID *> *contacts = [self contacts];
    NSInteger count = [contacts count];
    if (count <= 0) {
        return NO;
    }
    MKMID *contact;
    while (--count >= 0) {
        contact = [contacts objectAtIndex:count];
        if ([contact isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

@end
