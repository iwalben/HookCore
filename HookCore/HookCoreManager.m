//
//  HookCoreManager.m
//  HookCore
//
//  Created by iwalben on 2020/4/24.
//  Copyright © 2020 WM. All rights reserved.
//

#import "HookCoreManager.h"
#import <objc/runtime.h>
#import <objc/message.h>


@implementation HookCoreManager

+(void)hookAllMethodForClass:(id)hc_class{
    //hook实例方法（在类对象的method_list中）
    hc_logMethod(hc_class,nil);
    //hook类方法在（元类对象的method_list中）
    Class metaClass = object_getClass(hc_class);
    hc_logMethod(metaClass, nil);
}


void hc_logMethod(Class aClass, BOOL(^condition)(SEL sel)) {
    unsigned int outCount;
    Method *methods = class_copyMethodList(aClass,&outCount);
    
    for (int i = 0; i < outCount; i ++) {
        Method tempMethod = *(methods + i);
        SEL selector = method_getName(tempMethod);
        char *returnType = method_copyReturnType(tempMethod);
        if (hc_replaceMethod(aClass, selector, returnType)) {
            NSLog(@"success hook method:%@ types:%s", NSStringFromSelector(selector), method_getDescription(tempMethod)->types);
        } else {
            NSLog(@"fail method:%@ types:%s", NSStringFromSelector(selector), method_getDescription(tempMethod)->types);
        }
        free(returnType);
    }
    free(methods);
}

BOOL hc_replaceMethod(Class cls, SEL originSelector, char *returnType) {
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    const char *originTypes = method_getTypeEncoding(originMethod);
    IMP msgForwardIMP = _objc_msgForward;
    
    IMP originIMP = method_getImplementation(originMethod);
    if (originIMP == nil || originIMP == msgForwardIMP) {
        return NO;
    }
    //把原方法的IMP换成_objc_msgForward，使之触发forwardInvocation方法
    class_replaceMethod(cls, originSelector, msgForwardIMP, originTypes);
    
    //把方法forwardInvocation的IMP换成hc_forwardInvocation
    class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)hc_forwardInvocation, "v@:@");
    
    //创建一个新方法，IMP就是原方法的原来的IMP，那么只要在hc_forwardInvocation调用新方法即可
    SEL newSelecotr = hc_createNewSelector(originSelector);
    BOOL isAdd = class_addMethod(cls, newSelecotr, originIMP, originTypes);
    if (!isAdd) {
        NSLog(@"class_addMethod fail");
    }
    
    return YES;
}

//forwardInvocation:方法的新IMP
void hc_forwardInvocation(id target, SEL selector, NSInvocation *invocation) {

    SEL originSelector = invocation.selector;
    
    NSString *originSelectorString = NSStringFromSelector(originSelector);

    
    [invocation setSelector:hc_createNewSelector(originSelector)];
    [invocation setTarget:target];

    NSDate *start = [NSDate date];
    
    [invocation invoke];
    
    NSDate *end = [NSDate date];
    NSTimeInterval interval = [end timeIntervalSinceDate:start];
    NSLog(@"target:%@  sel:%@  spend time:%f",target,originSelectorString,interval);
}

//创建一个新的selector
SEL hc_createNewSelector(SEL originalSelector) {
    NSString *oldSelectorName = NSStringFromSelector(originalSelector);
    NSString *newSelectorName = [NSString stringWithFormat:@"hc_%@", oldSelectorName];
    SEL newSelector = NSSelectorFromString(newSelectorName);
    return newSelector;
}



@end
