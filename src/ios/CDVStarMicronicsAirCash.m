#import "CDVStarMicronicsAirCash.h"
#import <StarIO/SMPort.h>
#import <sys/time.h>

@implementation CDVStarMicronicsAirCash

#pragma mark Public Methods

- (void)isOnline:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* portName = [command.arguments objectAtIndex:0];
    NSString* portSettings = [command.arguments objectAtIndex:1];

    NSDictionary* result = [self checkStatusWithPortname:portName
                                            portSettings:portSettings];

    if (result[@"error"]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:result[@"error"]];
    }
    else {
        BOOL isOnline = [result[@"isOnline"] boolValue];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                           messageAsBool:isOnline];
    }
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
}

- (void)isOpen:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* portName = [command.arguments objectAtIndex:0];
    NSString* portSettings = [command.arguments objectAtIndex:1];

    NSDictionary* result = [self checkStatusWithPortname:portName
                                            portSettings:portSettings];

    if (result[@"error"]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:result[@"error"]];
    }
    else {
        BOOL isOpen = [result[@"isOpen"] boolValue];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                           messageAsBool:isOpen];
    }
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
}

- (void)openCashDrawer:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* portName = [command.arguments objectAtIndex:0];
    NSString* portSettings = [command.arguments objectAtIndex:1];
    NSUInteger drawerNumber = [[command.arguments objectAtIndex:2] intValue];

    NSDictionary* result = [self openCashDrawerWithPortName:portName
                                            andPortSettings:portSettings
                                            andDrawerNumber:drawerNumber];

    if (result[@"success"]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:result[@"error"]];
    }
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
}

#pragma mark Private Methods

/**
 *  This function checks the status of the printer.
 *  The check status function can be used for both portable
 *  and non portable printers.
 *
 *  @param  portName        Port name to use for communication.
                            This should be (TCP:<IP Address>) or
 *                          (BT:<iOS Port Name>).
 *  @param  portSettings    Should be blank
 */
- (NSDictionary*)checkStatusWithPortname:(NSString*)portName
                            portSettings:(NSString*)portSettings
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc]
        initWithDictionary:@{ @"isOnline" : @NO,
            @"isOpen" : @NO }];
    SMPort* starPort = nil;
    @try {
        starPort = [SMPort getPort:portName:portSettings:10000];
        if (!starPort) {
            result[@"error"] = @"Unable to connect to drawer.";
            return result;
        }

        StarPrinterStatus_2 status;
        [starPort getParsedStatus:&status:2];

        if (status.offline == SM_FALSE) {
            result[@"isOnline"] = @YES;
        }
        if (status.compulsionSwitch == SM_TRUE) {
            result[@"isOpen"] = @YES;
        }

        return result;
    }
    @catch (PortException* exception) {
        result[@"error"] = exception.description;
        return result;
    }
    @finally {
        [SMPort releasePort:starPort];
    }
}

- (NSDictionary*)openCashDrawerWithPortName:(NSString*)portName
                            andPortSettings:(NSString*)portSettings
                            andDrawerNumber:(NSUInteger)drawerNumber
{
    unsigned char opencashdrawer_command = 0x00;
    if (!drawerNumber || drawerNumber == 1) {
        opencashdrawer_command = 0x07; // BEL
    }
    else if (drawerNumber == 2) {
        opencashdrawer_command = 0x1a; // SUB
    }

    NSData* commands = [NSData dataWithBytes:&opencashdrawer_command length:1];
    return [self sendCommand:commands
                    portName:portName
                portSettings:portSettings
               timeoutMillis:10000];
}

- (NSDictionary*)sendCommand:(NSData*)commandsToPrint
                    portName:(NSString*)portName
                portSettings:(NSString*)portSettings
               timeoutMillis:(u_int32_t)timeoutMillis
{
    int commandSize = (int)commandsToPrint.length;
    unsigned char* dataToSentToPrinter = (unsigned char*)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter length:commandSize];

    SMPort* starPort = nil;
    @try {
        starPort = [SMPort getPort:portName:portSettings:timeoutMillis];
        if (starPort == nil) {
            return @{
                @"success" : @NO,
                @"error" :
                    @"Fail to Open Port. Refer to 'getPort API' in the manual."
            };
        }

        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status:2];
        if (status.offline == SM_TRUE) {
            return @{ @"success" : @NO,
                @"error" : @"Printer is offline" };
        }

        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;

        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize) {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten =
                [starPort writePort:
                    dataToSentToPrinter:
                     totalAmountWritten:remaining];
            totalAmountWritten += amountWritten;

            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec) {
                break;
            }
        }

        if (totalAmountWritten < commandSize) {
            return @{ @"success" : @NO,
                @"error" : @"Write port timed out" };
        }

        [starPort endCheckedBlock:&status:2];
        if (status.offline == SM_TRUE) {
            return @{ @"success" : @NO,
                @"error" : @"Printer is offline" };
        }
    }
    @catch (PortException* exception) {
        return @{ @"success" : @NO,
            @"error" : @"Write port timed out" };
    }
    @finally {
        free(dataToSentToPrinter);
        [SMPort releasePort:starPort];
    }

    // Return success if no error has occured
    return @{ @"success" : @YES };
}

@end
