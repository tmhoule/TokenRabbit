//
//  main.m
//  TokenRabbit
//
//  Created by Houle, Todd - 1130 - MITLL on 3/1/18.
//  Copyright © 2018 MIT Lincoln Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
