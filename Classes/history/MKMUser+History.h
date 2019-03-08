//
//  MKMUser+History.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMUser.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMHistoryBlock;

@interface MKMUser (History)

/**
 Create register record for the account

 @param hello - say hello to the world
 @return HistoryBlock
 */
- (MKMHistoryBlock *)registerWithMessage:(nullable const NSString *)hello;

/**
 Delete the account, FOREVER!
 
 @param lastWords - last message to the world
 @return HistoryBlock
 */
- (MKMHistoryBlock *)suicideWithMessage:(nullable const NSString *)lastWords;

@end

NS_ASSUME_NONNULL_END
