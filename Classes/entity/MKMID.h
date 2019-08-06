//
//  MKMID.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAddress.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  ID for entity (Account/Group)
 *
 *      data format: "name@address[/terminal]"
 *
 *      fileds:
 *          name     - entity name, the seed of fingerprint to build address
 *          address  - a string to identify an entity
 *          terminal - entity login resource(device), OPTIONAL
 */
@interface MKMID : MKMString

@property (readonly, strong, nonatomic, nullable) NSString *name;
@property (readonly, strong, nonatomic) MKMAddress *address;

@property (readonly, nonatomic) MKMNetworkType type; // Network ID
@property (readonly, nonatomic) UInt32 number;       // search number

@property (strong, nonatomic, nullable) NSString *terminal;

@property (readonly, nonatomic, getter=isValid) BOOL valid;

/**
 *  Initialize an ID with string form "name@address[/terminal]"
 *
 * @param aString - ID string
 * @return ID object
 */
- (instancetype)initWithString:(NSString *)aString;

/**
 *  Initialize an ID with username & address
 *
 * @param seed - username
 * @param addr - hash(fingerprint)
 * @return ID object
 */
- (instancetype)initWithName:(nullable NSString *)seed
                     address:(MKMAddress *)addr;

/**
 *  For BTC address
 */
- (instancetype)initWithAddress:(MKMAddress *)addr;

/**
 *  ID without terminal
 *
 * @return ID object
 */
- (instancetype)naked;

@end

// convert String to ID
#define MKMIDFromString(ID)                                                    \
            [MKMID getInstance:(ID)]                                           \
                                                 /* EOF 'MKMIDFromString(ID)' */

#define MKMAnyone()                                                            \
            MKMIDFromString(@"anyone@anywhere")                                \
                                                         /* EOF 'MKMAnyone()' */
#define MKMEveryone()                                                          \
            MKMIDFromString(@"everyone@everywhere")                            \
                                                       /* EOF 'MKMEveryone()' */

#define MKMIsAnyone(ID)                                                        \
            (MKMNetwork_IsPerson([(ID) type]) && [MKMAnyone() isEqual:(ID)])   \
                                                       /* EOF 'MKMIsAnyone()' */
#define MKMIsEveryone(ID)                                                      \
            (MKMNetwork_IsGroup([(ID) type]) && [MKMEveryone() isEqual:(ID)])  \
                                                      /* EOF 'MKMIsEveryone() */
#define MKMIsBroadcast(ID)                                                     \
            (MKMNetwork_IsGroup([(ID) type]) ?                                 \
                [MKMEveryone() isEqual:(ID)] : MKMIsAnyone(ID))                \
                                                    /* EOF 'MKMIsBroadcast()' */

@interface MKMID (Runtime)

+ (nullable instancetype)getInstance:(id)ID;

@end

NS_ASSUME_NONNULL_END
