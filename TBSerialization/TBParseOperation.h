//
//  TBParseOperation.h
//  TBPersistence
//
//  Created by Theodore Calmes on 11/13/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "TBSerialization.h"

@class TBRemoteObject;

@protocol TBSerializable;

/** `TBParseOperation` is meant to be subclassed. You should override `-main` with your own. In main you should place the parse logic which will parse `parseObject` to whatever `destinationClass` you choose using the given `parseContext`.
 */

@interface TBParseOperation : NSOperation <NSCoding>

@property (assign, nonatomic, readonly) Class<TBSerializable> destinationClass;
@property (strong, nonatomic) NSManagedObjectContext *parseContext;
@property (strong, nonatomic) id parseObject;

- (id)initWithDestinationClass:(Class<TBSerializable>)destinationClass;

@end
