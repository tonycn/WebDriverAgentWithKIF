//
//  UIDevice+FBHelper.m
//  WebDriverAgent
//
//  Created by jianjun on 2019-02-21.
//

#import "UIDevice+FBHelper.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/utsname.h>
#import "UIApplication-KIFAdditions.h"

@implementation UIDevice (FBHelper)


- (NSString *)fb_getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (NSString *)fb_getLocalIPAddress
{
    return [self fb_getIPAddress];
}

- (NSData *)fb_screenshotWithError:(NSError **)error
{
    NSArray <UIWindow *> *allWindows = UIApplication.sharedApplication.windows;
    UIWindow *topWindow = allWindows.lastObject;
    UIGraphicsBeginImageContextWithOptions(topWindow.bounds.size, NO, [UIScreen mainScreen].scale);

    [topWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(image);
    return imageData;
}
@end
