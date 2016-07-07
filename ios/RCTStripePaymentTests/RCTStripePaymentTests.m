//
//  RCTStripePaymentTests.m
//  RCTStripePaymentTests
//
//  Created by WeiGuangcheng on 7/7/16.
//  Copyright © 2016 Guangcheng Wei. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XCTest/XCTestAssertions.h>
#import "StripeAPIClient.h"

@interface RCTStripePaymentTests : XCTestCase

@property(retain) StripeAPIClient *subject;

@end

@implementation RCTStripePaymentTests

- (void)setUp {
    [super setUp];
    self.subject = [StripeAPIClient sharedInit:@"http://dev.liaoyuan.io/payment" withAuthHeader:@"FSign user=\"56e6d2cc25ac03ad06c7d7d3\",token=\"0d5daeb27a684e15e87de883975d1a32\""];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    [self.subject retrieveCustomer:^(STPCustomer * _Nullable customer, NSError * _Nullable error) {
        XCTAssertEqualObjects(customer.stripeID, @"5704ad02913d22ef78885bff");
    }];
}


@end
