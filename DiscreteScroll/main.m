#import <ApplicationServices/ApplicationServices.h>

#define SIGN(x) (((x) > 0) - ((x) < 0))
#define LINES 6

CGEventRef cgEventCallback(CGEventTapProxy proxy, CGEventType type,
                           CGEventRef event, void *refcon)
{
    if (type != kCGEventScrollWheel) {
        return event;
    }

    if (!CGEventGetIntegerValueField(event, kCGScrollWheelEventIsContinuous)) {
        int64_t delta = CGEventGetIntegerValueField(event, kCGScrollWheelEventPointDeltaAxis1);

        if (delta) {
            CGEventSetIntegerValueField(event, kCGScrollWheelEventDeltaAxis1, SIGN(delta) * LINES);
            return event;
        }

        delta = CGEventGetIntegerValueField(event, kCGScrollWheelEventDeltaAxis2);
        if (delta < 0) {
            CGEventSourceRef source = NULL;//CGEventCreateSourceFromEvent(event);
            CGPoint loc = CGEventGetLocation(event);

            event = CGEventCreateMouseEvent(source,
                                            kCGEventLeftMouseDown,
                                            loc,
                                            kCGMouseButtonLeft);
            CGEventTapPostEvent(proxy, event);
            CFRelease(event);
            event = CGEventCreateMouseEvent(source,
                                            kCGEventLeftMouseUp,
                                            loc,
                                            kCGMouseButtonLeft);
            CGEventTapPostEvent(proxy, event);
            CFRelease(event);
            event = CGEventCreateMouseEvent(source,
                                            kCGEventLeftMouseDown,
                                            loc,
                                            kCGMouseButtonLeft);
            CGEventSetIntegerValueField(event, kCGMouseEventClickState, 2);
            CGEventTapPostEvent(proxy, event);
            CFRelease(event);
            event = CGEventCreateMouseEvent(source,
                                            kCGEventLeftMouseUp,
                                            loc,
                                            kCGMouseButtonLeft);
            CGEventSetIntegerValueField(event, kCGMouseEventClickState, 2);
            CGEventTapPostEvent(proxy, event);
            CFRelease(event);
//             CFRelease(source);
            return NULL;
        }
    }
    
    return event;
}

int main(void)
{
    CFMachPortRef eventTap;
    CFRunLoopSourceRef runLoopSource;
    
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0,
                                CGEventMaskBit(kCGEventScrollWheel), cgEventCallback, NULL);
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    CFRunLoopRun();
    
    CFRelease(eventTap);
    CFRelease(runLoopSource);
    
    return 0;
}
