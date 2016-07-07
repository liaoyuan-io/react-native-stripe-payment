#import <Foundation/Foundation.h>
@import Stripe;

@interface StripeAPIClient : NSObject <STPBackendAPIAdapter>
@property(retain) NSString *baseURL;
@property(retain) NSString *customerID;
@property(retain) NSURLSession *session;

+ (StripeAPIClient*) sharedInit:(NSString*)baseURL customerID:(NSString*)customerID;
- (void)retrieveCustomer:(STPCustomerCompletionBlock)completion;
- (void)selectDefaultCustomerSource:(id<STPSource>)source completion:(STPErrorBlock)completion;
- (void)attachSourceToCustomer:(id<STPSource>)source completion:(STPErrorBlock)completion;
@end