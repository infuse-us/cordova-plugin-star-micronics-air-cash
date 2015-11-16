#import <Cordova/CDV.h>

@interface CDVStarMicronicsAirCash : CDVPlugin {
}

- (void)isOnline:(CDVInvokedUrlCommand*)command;
- (void)isOpen:(CDVInvokedUrlCommand*)command;
- (void)openCashDrawer:(CDVInvokedUrlCommand*)command;

@end
