#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import "RCTConvert.h"
#import "RCTLog.h"
@import Stripe;

#import "StripeAPIClient.h"

@interface RCTStripePayment : NSObject <RCTBridgeModule, STPPaymentContextDelegate>
@property STPPaymentContext * paymentContext;
@property StripeAPIClient * APIClient;
@end
