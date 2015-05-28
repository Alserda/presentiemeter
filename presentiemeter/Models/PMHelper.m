//
//  PMHelper.m
//  presentiemeter
//
//  Created by Peter Alserda on 23/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMHelper.h"

@implementation PMHelper


+ (NSMutableString *)formatMacAddress:(NSString *)oldMacAddress  {
    
    NSMutableString *macAddress = [NSMutableString stringWithString:[oldMacAddress uppercaseString]];
    [macAddress insertString: @":" atIndex: 2];
    [macAddress insertString: @":" atIndex: 5];
    [macAddress insertString: @":" atIndex: 8];
    [macAddress insertString: @":" atIndex: 11];
    [macAddress insertString: @":" atIndex: 14];
    
    return macAddress;
}

@end
