//
//  MKMUser+History.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMHistoryOperation.h"
#import "MKMHistoryTransaction.h"
#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMConsensus.h"

#import "MKMUser+History.h"

@implementation MKMUser (History)

- (MKMHistoryBlock *)registerWithMessage:(nullable const NSString *)hello {
    NSAssert(self.privateKey, @"private key not set");
    
    MKMHistoryBlock *record;
    MKMHistoryTransaction *event;
    MKMHistoryOperation *op;
    
    // create operation with command: "register"
    op = [[MKMHistoryOperation alloc] initWithCommand:@"register" time:nil];
    if (hello.length > 0) {
        [op setObject:hello forKey:@"message"];
    }
    
    // create event(Transaction) with operation
    event = [[MKMHistoryTransaction alloc] initWithOperation:op];
    
    // create record(Block) with events
    NSData *hash = nil;
    NSData *CT = nil;
    record = [[MKMHistoryBlock alloc] initWithTransactions:@[event]
                                                    merkle:hash
                                                 signature:CT
                                                  recorder:self.ID];
    [record signWithPrivateKey:self.privateKey];
    
    return record;
}

- (MKMHistoryBlock *)suicideWithMessage:(nullable const NSString *)lastWords {
    NSAssert(self.privateKey, @"private key not set");
    
    MKMHistory *history = MKMHistoryForID(_ID);
    MKMHistoryBlock *lastBlock = history.blocks.lastObject;
    lastBlock = [MKMHistoryBlock blockWithBlock:lastBlock];
    NSData *CT = lastBlock.signature;
    NSAssert(CT, @"last block error: %@", lastBlock);
    
    MKMHistoryBlock *record;
    MKMHistoryTransaction *ev1, *ev2;
    MKMHistoryOperation *op1, *op2;
    
    // create event1(Transaction) with operation: "link"
    op1 = [[MKMHistoryOperation alloc] initWithPreviousSignature:CT time:nil];
    ev1 = [[MKMHistoryTransaction alloc] initWithOperation:op1];
    
    // create event2(Transaction) with operation: "suicide"
    op2 = [[MKMHistoryOperation alloc] initWithCommand:@"suicide" time:nil];
    if (lastWords.length > 0) {
        [op2 setObject:lastWords forKey:@"message"];
    }
    ev2 = [[MKMHistoryTransaction alloc] initWithOperation:op2];
    
    // create record(Block) with events
    NSData *hash = nil;
    CT = nil;
    record = [[MKMHistoryBlock alloc] initWithTransactions:@[ev1, ev2]
                                                    merkle:hash
                                                 signature:CT
                                                  recorder:self.ID];
    [record signWithPrivateKey:self.privateKey];
    
    return record;
}

@end
