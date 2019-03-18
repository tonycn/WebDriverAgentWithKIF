//
//  FBUITapCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUITapElementCommand.h"

#import "FBSession.h"
#import "FBApplication.h"
#import "FBResponsePayload.h"
#import "FBElementCache.h"
#import "UIView-KIFAdditions.h"
#import "UIView+FBHelper.h"

@implementation FBUITapElementCommand

- (BOOL)execute
{
    FBElementCache *elementCache = [FBSession activeSession].elementCache;
    UIView *element = [elementCache elementForUUID:self.uuid];
    if (nil == element) {
        
    } else {
        [element tap];
    }
    return YES;
}

@end
