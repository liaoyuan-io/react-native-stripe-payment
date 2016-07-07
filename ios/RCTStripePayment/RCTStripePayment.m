#import "RCTStripePayment.h"

@implementation RCTStripePayment

RCT_EXPORT_MODULE();

- (id)init {
  self = [super init];
  return self;
}


RCT_EXPORT_METHOD(selectPayment:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  /*  TODO:
   *  pass contextDidChangeHandler
   *       didCreatePaymentResultHandler, put STPPaymentResult.source to server
   *       prefilledInformation
   *  in options
   */
}

- (void)paymentContextDidChange:(STPPaymentContext *)paymentContext {
  //TODO: call contextDidChangeHandler
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didCreatePaymentResult:(STPPaymentResult *)paymentResult completion:(STPErrorBlock)completion {
  //TODO: call didCreatePaymentResultHandler
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFinishWithStatus:(STPPaymentStatus)status error:(NSError *)error {
  //TODO: resolve or reject
  //      resolve with packaged paymentContext
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFailToLoadWithError:(NSError *)error {
  //TODO: reject
}

@end
