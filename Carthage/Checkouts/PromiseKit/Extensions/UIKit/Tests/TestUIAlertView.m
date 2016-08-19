@import PromiseKit;
@import PMKUIKit;
@import XCTest;
@import UIKit;

#if !TARGET_OS_TV

@implementation UIAlertViewTests: XCTestCase

// fulfills with buttonIndex
- (void)test1 {
    XCTestExpectation *ex = [self expectationWithDescription:@""];

    UIAlertView *alert = [UIAlertView new];
    [alert addButtonWithTitle:@"0"];
    [alert addButtonWithTitle:@"1"];
    alert.cancelButtonIndex = [alert addButtonWithTitle:@"2"];
    [alert promise].then(^(id obj){
        XCTAssertEqual([obj integerValue], 1);
        [ex fulfill];
    });
    PMKAfter(0.1).then(^{
        [alert dismissWithClickedButtonIndex:1 animated: NO];
    });
    [self waitForExpectationsWithTimeout:3 handler: nil];
}

// cancel button presses are cancelled errors
- (void)test2 {
    XCTestExpectation *ex = [self expectationWithDescription:@""];

    UIAlertView *alert = [UIAlertView new];
    [alert addButtonWithTitle:@"0"];
    [alert addButtonWithTitle:@"1"];
    alert.cancelButtonIndex = [alert addButtonWithTitle:@"2"];
    [alert promise].catchWithPolicy(PMKCatchPolicyAllErrors, ^(NSError *err){
        XCTAssertTrue(err.isCancelled);
        [ex fulfill];
    });
    PMKAfter(0.1).then(^{
        [alert dismissWithClickedButtonIndex:2 animated: NO];
    });
    [self waitForExpectationsWithTimeout:3 handler: nil];
}

// single button UIAlertViews don't get considered cancelled
- (void)test3 {
    XCTestExpectation *ex = [self expectationWithDescription:@""];

    UIAlertView *alert = [UIAlertView new];
    [alert addButtonWithTitle:@"0"];
    [alert promise].then(^{
        [ex fulfill];
    });
    PMKAfter(0.1).then(^{
        [alert dismissWithClickedButtonIndex:0 animated: NO];
    });
    [self waitForExpectationsWithTimeout:3 handler: nil];
}

// single button UIAlertViews don't get considered cancelled unless the cancelIndex is set
- (void)test4 {
    XCTestExpectation *ex = [self expectationWithDescription:@""];

    UIAlertView *alert = [UIAlertView new];
    alert.cancelButtonIndex = [alert addButtonWithTitle:@"0"];
    [alert promise].catchWithPolicy(PMKCatchPolicyAllErrors, ^(NSError *err){
        [ex fulfill];
    });
    PMKAfter(0.1).then(^{
        [alert dismissWithClickedButtonIndex:0 animated: NO];
    });
    [self waitForExpectationsWithTimeout:3 handler: nil];
}

@end

#endif
