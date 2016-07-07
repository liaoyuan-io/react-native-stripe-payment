//
//  RCTStripePaymentTests.m
//  RCTStripePaymentTests
//
//  Created by WeiGuangcheng on 7/7/16.
//  Copyright © 2016 Guangcheng Wei. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StripeAPIClient.h"

@interface RCTStripePaymentTests : XCTestCase

@property(retain) StripeAPIClient *subject;

@end

@implementation RCTStripePaymentTests

- (void)setUp {
    [super setUp];
    self.subject = [StripeAPIClient sharedInit:@"base_url" customerID:@"1"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    [self.subject retrieveCustomer:^(STPCustomer * _Nullable customer, NSError * _Nullable error) {
        
    }];
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
