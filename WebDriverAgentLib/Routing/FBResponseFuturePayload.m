//
//  FBResponseFuturePayload.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-19.
//

#import "FBResponseFuturePayload.h"

@interface FBResponseFuturePayload ()
@property (nonatomic, strong) RouteResponse *response;
@end

@implementation FBResponseFuturePayload

- (void)dispatchWithResponse:(RouteResponse *)response
{
    self.response = response;
}

- (void)fillRealResponsePayload:(id<FBResponsePayload>)responsePayload
{
    [responsePayload dispatchWithResponse:self.response];
}

@end
