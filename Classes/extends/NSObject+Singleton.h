//
//  NSObject+Singleton.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#ifndef NSObject_Singleton_h
#define NSObject_Singleton_h

#define SingletonDispatchOnce(block)                           \
            static dispatch_once_t onceToken;                  \
            dispatch_once(&onceToken, block)                   \
                        /* EOF 'SingletonDispatchOnce(block)' */

#define SingletonImplementations_Main(Class, factory)          \
        static Class *s_shared##Class = nil;                   \
        + (instancetype)allocWithZone:(struct _NSZone *)zone { \
            SingletonDispatchOnce(^{                           \
                s_shared##Class = [super allocWithZone:zone];  \
            });                                                \
            return s_shared##Class;                            \
        }                                                      \
        + (instancetype)factory {                              \
            SingletonDispatchOnce(^{                           \
                s_shared##Class = [[self alloc] init];         \
            });                                                \
            return s_shared##Class;                            \
        }                                                      \
       /* EOF 'SingletonImplementations_Main(Class, factory)' */

#define SingletonImplementations_Copy(Class)                   \
        - (id)copy {                                           \
            return s_shared##Class;                            \
        }                                                      \
        - (id)mutableCopy {                                    \
            return s_shared##Class;                            \
        }                                                      \
                     /* EOF 'SingletonImplementations_Copy()' */

#if __has_feature(objc_arc) // ARC

#define SingletonImplementations(Class, factory)               \
        SingletonImplementations_Main(Class, factory)          \
        SingletonImplementations_Copy(Class)                   \
            /* EOF 'SingletonImplementations(Class, factory)' */

#else // MRC

#define SingletonImplementations_MRC(Class)                    \
        - (instancetype)retain {                               \
            return s_shared##Class;                            \
        }                                                      \
        - (oneway void)release {                               \
        }                                                      \
        - (instancetype)autorelease {                          \
            return s_shared##Class;                            \
        }                                                      \
        - (NSUInteger)retainCount {                            \
            return MAXFLOAT;                                   \
        }                                                      \
                      /* EOF 'SingletonImplementations_MRC()' */

#define SingletonImplementations(Class, factory)               \
        SingletonImplementations_Main(Class, factory)          \
        SingletonImplementations_Copy(Class)                   \
        SingletonImplementations_MRC(Class)                    \
            /* EOF 'SingletonImplementations(Class, factory)' */

#endif /* __has_feature(objc_arc) */

#endif /* NSObject_Singleton_h */
