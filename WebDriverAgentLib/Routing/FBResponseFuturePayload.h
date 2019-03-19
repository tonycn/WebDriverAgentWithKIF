//
//  FBResponseFuturePayload.h
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-19.
//

#import <Foundation/Foundation.h>

#import "FBResponsePayload.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBResponseFuturePayload : NSObject <FBResponsePayload>

- (void)fillRealResponsePayload:(id<FBResponsePayload>)responsePayload;

@end

NS_ASSUME_NONNULL_END
