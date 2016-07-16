#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import "RCTConvert.h"
#import "RCTLog.h"
@import Stripe;


@interface RCTStripePayment : NSObject <RCTBridgeModule, STPPaymentContextDelegate, STPBackendAPIAdapter>

@property STPPaymentContext * paymentContext;
@property RCTPromiseResolveBlock resolve;
@property RCTPromiseRejectBlock reject;

@property(retain) NSString *baseURL;
@property(retain) NSString *authHeader;
@property(retain) NSString *customerID;
@property BOOL *changeDefault;
@property(retain) NSURLSession *session;

@end
