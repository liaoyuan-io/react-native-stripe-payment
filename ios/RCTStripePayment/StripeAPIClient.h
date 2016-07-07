#import <Foundation/Foundation.h>
@import Stripe;

@interface StripeAPIClient : NSObject <STPBackendAPIAdapter>
@property(retain) NSString *baseURL;
@property(retain) NSString *authHeader;
@property(retain) NSString *customerID;
@property(retain) NSURLSession *session;

+ (StripeAPIClient*)sharedInit:(NSString*)baseURL  withAuthHeader:(NSString*) authHeader;
- (void)retrieveCustomer:(STPCustomerCompletionBlock)completion;
- (void)selectDefaultCustomerSource:(id<STPSource>)source completion:(STPErrorBlock)completion;
- (void)attachSourceToCustomer:(id<STPSource>)source completion:(STPErrorBlock)completion;
@end