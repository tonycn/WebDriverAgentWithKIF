//
//  FBResponseFuturePayload.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-19.
//

#import "FBResponseFuturePayload.h"

@interface FBResponseFuturePayload ()
@property (nonatomic, strong) RouteResponse *responseToFill;

@property (nonatomic, strong) id<FBResponsePayload> payload;
@end

@implementation FBResponseFuturePayload {
    dispatch_semaphore_t _waitResponseSemaphore;
}

- (void)dispatchWithResponse:(RouteResponse *)response
{
    if (self.payload) {
        [self.payload dispatchWithResponse:response];
    } else {
        _waitResponseSemaphore = dispatch_semaphore_create(0);
        self.responseToFill = response;
        dispatch_time_t maxTimeOut = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
        dispatch_semaphore_wait(_waitResponseSemaphore, maxTimeOut);
    }
}

- (void)fillRealResponsePayload:(id<FBResponsePayload>)responsePayload
{
    if (_waitResponseSemaphore == NULL) {
        self.payload = responsePayload;
    } else {
        [responsePayload dispatchWithResponse:self.responseToFill];
        dispatch_semaphore_signal(_waitResponseSemaphore);
    }
}

@end
