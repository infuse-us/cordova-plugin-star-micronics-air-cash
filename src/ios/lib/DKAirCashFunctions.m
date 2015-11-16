//
//  DKAirCashFunctions.m
//  IOS_SDK
//
//  Created by u3237 on 13/06/25.
//
//

#import "DKAirCashFunctions.h"
#import <sys/time.h>
#import <StarIO/SMPort.h>

@implementation DKAirCashFunctions

/*!
 *  This function shows the DK-AirCash firmware information
 *
 *  @param  portName        Port name to use for communication
 *  @param  portSettings    The port settings to use
 */
+ (void)showFirmwareInformation:(NSString *)portName portSettings:(NSString *)portSettings {
    SMPort *starPort = nil;
    NSDictionary *dict = nil;
    
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port.\nRefer to \"getPort API\" in the manual."
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSMutableString *message = [NSMutableString string];
        dict = [starPort getFirmwareInformation];
        for (id key in dict.keyEnumerator) {
            [message appendFormat:@"%@: %@\n", key, dict[key]];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firmware"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    @catch (PortException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Get firmware information failed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        [SMPort releasePort:starPort];
    }
}

/*!
 *  This function shows the DK-AirCash Dip Switch information
 *
 *  @param  portName        Port name to use for communication
 *  @param  portSettings    The port settings to use
 */
+ (void)showDipSwitchInformation:(NSString *)portName portSettings:(NSString *)portSettings {
    SMPort *starPort = nil;
    NSDictionary *dict = nil;
    
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port.\nRefer to \"getPort API\" in the manual."
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSMutableString *message = [NSMutableString string];
        dict = [starPort getDipSwitchInformation];

        // DipSW 1 Label
        [message appendFormat:@"--DipSwitch1--\n"];
        // DipSW 1-1
        if ([[dict objectForKey:@"DIPSW11"] isEqualToString:@"YES"])
        {
            [message appendFormat:@"[1-1] LAN\n"];
        }
        else
        {
            [message appendFormat:@"[1-1] Bluetooth / WiFi\n"];
        }
        // DipSW 1-2
        [message appendFormat:@"[1-2] Reserved\n"];
        // DipSW 1-3
        if ([[dict objectForKey:@"DIPSW13"] isEqualToString:@"YES"])
        {
            [message appendFormat:@"[1-3] Disabled\n"];
        }
        else
        {
            [message appendFormat:@"[1-3] Enabled\n"];
        }
        // DipSW 1-4
        if ([[dict objectForKey:@"DIPSW14"] isEqualToString:@"YES"])
        {
            [message appendFormat:@"[1-4] Disabled\n"];
        }
        else
        {
            [message appendFormat:@"[1-4] Enabled\n"];
        }
        // DipSW 1-5
        if ([[dict objectForKey:@"DIPSW15"] isEqualToString:@"YES"])
        {
            [message appendFormat:@"[1-5] 20 seconds\n"];
        }
        else
        {
            [message appendFormat:@"[1-5] No timeout\n"];
        }
        // DipSW 1-6
        [message appendFormat:@"[1-6] Reserved\n"];
        // DipSW 1-7
        [message appendFormat:@"[1-7] Reserved\n"];
        // DipSW 1-8
        [message appendFormat:@"[1-8] Reserved\n"];

        // DipSW 2 Label
        [message appendFormat:@"\n--DipSwitch2--\n"];
        // DipSW 2-1
        [message appendFormat:@"[2-1] Reserved\n"];
        // DipSW 2-2
        [message appendFormat:@"[2-2] Reserved\n"];
        // DipSW 2-3
        if ([[dict objectForKey:@"DIPSW23"] isEqualToString:@"YES"])
        {
            [message appendFormat:@"[2-3] H: Open\n"];
        }
        else
        {
            [message appendFormat:@"[2-3] L: Open\n"];
        }
        // DipSW 2-4
        [message appendFormat:@"[2-4] Reserved\n"];
        // DipSW 2-5
        [message appendFormat:@"[2-5] Reserved\n"];
        // DipSW 2-6
        [message appendFormat:@"[2-6] Reserved\n"];
        // DipSW 2-7
        [message appendFormat:@"[2-7] Reserved\n"];
        // DipSW 2-8
        if ([[dict objectForKey:@"DIPSW28"] isEqualToString:@"YES"])
        {
            [message appendFormat:@"[2-8] Disabled\n"];
        }
        else
        {
            [message appendFormat:@"[2-8] Enabled\n"];
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dip Switch"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    @catch (PortException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Get dip switch information failed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        [SMPort releasePort:starPort];
    }
}

/**
 *  This function opens the DK-AirCash.
 *  This function just send the byte 0x07 to the DK-AirCash which is the open Cash Drawer command.
 *
 *  @param  portName        Port name to use for communication. This should be (TCP:<IP Address>), (BT:<iOS Port Name>),
 *                          or (BLE:<Device Name>).
 *  @param  portSettings    Should be blank
 */
+ (void)OpenCashDrawerWithPortname:(NSString *)portName portSettings:(NSString *)portSettings drawerNumber:(NSUInteger)drawerNumber
{
    unsigned char opencashdrawer_command = 0x00;
    
    if (drawerNumber == 1) {
        opencashdrawer_command = 0x07; // BEL
    }
    else if (drawerNumber == 2) {
        opencashdrawer_command = 0x1a; // SUB
    }
    
    NSData *commands = [NSData dataWithBytes:&opencashdrawer_command length:1];
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
}

/**
 *  This function checks the status of the printer.
 *  The check status function can be used for both portable and non portable printers.
 *
 *  @param  portName        Port name to use for communication. This should be (TCP:<IP Address>) or
 *                          (BT:<iOS Port Name>).
 *  @param  portSettings    Should be blank
 */
+ (void)CheckStatusWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port.\nRefer to \"getPort API\" in the manual."
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        StarPrinterStatus_2 status;
        [starPort getParsedStatus:&status :2];
        
        NSString *onlineStatus;
        if (status.offline == SM_TRUE) {
            onlineStatus = @"The drawer is offline";
        } else {
            onlineStatus = @"The drawer is online";
        }
        
        NSString *compulsionSwStatus;
        if (status.compulsionSwitch == SM_FALSE) {
            compulsionSwStatus = @"Cash Drawer: Close";
        } else {
            compulsionSwStatus = @"Cash Drawer: Open";
        }
        
        NSString *message = [NSString stringWithFormat:@"%@\n%@", onlineStatus, compulsionSwStatus];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Drawer Status"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Get status failed."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
}

#pragma mark Common

+ (void)sendCommand:(NSData *)commandsToPrint portName:(NSString *)portName portSettings:(NSString *)portSettings timeoutMillis:(u_int32_t)timeoutMillis
{
    int commandSize = (int)commandsToPrint.length;
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter length:commandSize];
    
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :timeoutMillis];
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port.\nRefer to \"getPort API\" in the manual."
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Printer is offline"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                            message:@"Write port timed out"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        [starPort endCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Printer is offline"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Write port timed out"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        free(dataToSentToPrinter);
        [SMPort releasePort:starPort];
    }
}

/*!
 *  Open drawer / wait drawer open / wait drawer close
 */
+ (BOOL)waitDrawerOpenAndCloseWithPortName:(NSString *)portName portSettings:(NSString *)portSettings drawerNumber:(NSUInteger)drawerNumber
{
    //
    // Create Drawer Open Command
    //
    unsigned char opencashdrawer_command = 0x00;
    switch (drawerNumber) {
        case 1:
            opencashdrawer_command = 0x07; // BEL
            break;
        case 2:
            opencashdrawer_command = 0x1a; // SUB
            break;
        default:
            return NO;
    }
    

    SMPort *starPort = nil;

    @try {
        //
        // Send Drawer Open Command
        //
        
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil) {
            [self showCommonErrorDialogWithTitle:@"Error" message:@"DK-AirCash is turned off or other host is using the DK-AirCash"];
            return NO;
        }
        
        // Check current status
        StarPrinterStatus_2 status;
        [starPort getParsedStatus:&status :2];
        if (status.compulsionSwitch == SM_TRUE) {
            [self showCommonErrorDialogWithTitle:@"" message:@"Drawer was already opened."];
            return NO;
        }
        
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            [self showCommonErrorDialogWithTitle:@"Error" message:@"Printer is offline"];
            return NO;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        NSData *commands = [NSData dataWithBytes:&opencashdrawer_command length:1];
        unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commands.length);
        [commands getBytes:dataToSentToPrinter length:commands.length];
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commands.length)
        {
            int remaining = (int)(commands.length - totalAmountWritten);
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec) {
                break;
            }
        }
        free(dataToSentToPrinter);
        
        if (totalAmountWritten < commands.length)
        {
            [self showCommonErrorDialogWithTitle:@"Error" message:@"Printer is offline"];
            return NO;
        }
        
        [self showCommonProgressDialogWithTitle:@"" message:@"Waiting for drawer to open."];
        
        [starPort endCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            [self showCommonErrorDialogWithTitle:@"Error" message:@"Printer is offline"];
            return NO;
        }
        
        // Interval
        usleep(150 * 1000);
        
        [self dismissCommonProgressDialog];
        
        // Check drawer open
        [starPort getParsedStatus:&status :2];
        if (status.compulsionSwitch == SM_FALSE) {
            [self showCommonErrorDialogWithTitle:@"Error" message:@"Drawer didn\'t open."];
            return NO;
        }
        
        //
        // Wait Drawer Close
        //
        [self showCommonProgressDialogWithTitle:@"" message:@"Waiting for drawer to close."];
        
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        while (YES) {
            [starPort getParsedStatus:&status :2];
            if (status.compulsionSwitch == SM_FALSE) {
                break;
            }
            
            // Check timeout
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec) {
                [self showCommonErrorDialogWithTitle:@"Error" message:@"Drawer didn\'t close within 30 seconds."];
                return NO;
            }
            
            // Interval
            usleep(500 * 1000);
        }

        [self dismissCommonProgressDialog];
        
        [self showCommonProgressDialogWithTitle:@"" message:@"Completed successfully."];
        
        usleep(3000 * 1000);
        
        [self dismissCommonProgressDialog];
    }
    @catch (PortException *ex) {
        [self showCommonErrorDialogWithTitle:@"Printer Error" message:@"Write port timed out"];
    }
    @finally {
        [SMPort releasePort:starPort];
        [self dismissCommonProgressDialog];
    }
    
    return YES;
}


static UIAlertView* alert = nil;

+ (void)showCommonProgressDialogWithTitle:(NSString *)title message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (alert != nil) {
            [self dismissCommonProgressDialog];
        }
        
        alert = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
        [alert show];
    });
}

+ (void)dismissCommonProgressDialog
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        alert = nil;
    });
}

+ (void)showCommonErrorDialogWithTitle:(NSString *)title message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    });
}

@end
