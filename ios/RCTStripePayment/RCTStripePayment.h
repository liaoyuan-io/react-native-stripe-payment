#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import "RCTConvert.h"
#import "RCTLog.h"
@import Stripe;

@interface RCTStripePayment : NSObject <RCTBridgeModule, STPPaymentContextDelegate>

@end
