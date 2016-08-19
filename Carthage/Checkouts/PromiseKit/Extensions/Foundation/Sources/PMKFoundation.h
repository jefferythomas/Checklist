#import <Foundation/Foundation.h>
#import <PromiseKit/PromiseKit.h>

FOUNDATION_EXPORT double PMK_UIKitVersionNumber;
FOUNDATION_EXPORT const unsigned char PMK_UIKitVersionString[];

#define PMKTaskErrorLaunchPathKey @"PMKTaskErrorLaunchPathKey"
#define PMKTaskErrorArgumentsKey @"PMKTaskErrorArgumentsKey"
#define PMKTaskErrorStandardOutputKey @"PMKTaskErrorStandardOutputKey"
#define PMKTaskErrorStandardErrorKey @"PMKTaskErrorStandardErrorKey"
#define PMKTaskErrorExitStatusKey @"PMKTaskErrorExitStatusKey"



/**
 To import the `NSNotificationCenter` category:

 use_frameworks!
 pod "PromiseKit/Foundation"

 Or `NSNotificationCenter` is one of the categories imported by the umbrella pod:

 use_frameworks!
 pod "PromiseKit"

 And then in your sources:

 @import PromiseKit;
 */
@interface NSNotificationCenter (PromiseKit)
/**
 Observe the named notification once.

 [NSNotificationCenter once:UIKeyboardWillShowNotification].then(^(id note, id userInfo){
 UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
 CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

 return [UIView promiseWithDuration:duration delay:0.0 options:(curve << 16) animations:^{

 }];
 });

 @warning *Important* Promises only resolve once. If you need your block to execute more than once then use `-addObserverForName:object:queue:usingBlock:`.

 @param notificationName The name of the notification for which to register the observer.

 @return A promise that fulfills with two parameters:

 1. The NSNotification object.
 2. The NSNotification’s userInfo property.
 */
+ (AnyPromise *)once:(NSString *)notificationName NS_REFINED_FOR_SWIFT;

@end



/**
 To import the `NSURLSession` category:

 use_frameworks!
 pod "PromiseKit/Foundation"

 Or `NSURLSession` is one of the categories imported by the umbrella pod:

 use_frameworks!
 pod "PromiseKit"

 And then in your sources:

 #import <PromiseKit/PromiseKit.h>

 PromiseKit automatically deserializes the raw HTTP data response into the
 appropriate rich data type based on the mime type the server provides.
 Thus if the response is JSON you will get the deserialized JSON response.
 PromiseKit supports decoding into strings, JSON and UIImages.

 However if your server does not provide a rich content-type, you will
 just get `NSData`. This is rare, but a good example we came across was
 downloading files from Dropbox.

 PromiseKit goes to quite some lengths to provide good `NSError` objects
 for error conditions at all stages of the HTTP to rich-data type
 pipeline. We provide the following additional `userInfo` keys as
 appropriate:

 - `PMKURLErrorFailingDataKey`
 - `PMKURLErrorFailingStringKey`
 - `PMKURLErrorFailingURLResponseKey`

 PromiseKit uses [OMGHTTPURLRQ](https://github.com/mxcl/OMGHTTPURLRQ) to
 make its HTTP requests. PromiseKit only provides a convenience layer
 above OMGHTTPURLRQ, thus if you need more power (eg. a multipartFormData
 POST), use OMGHTTPURLRQ to generate the `NSURLRequest` and then pass
 that request to `+promise:`.

 @see https://github.com/mxcl/OMGHTTPURLRQ
 */
@interface NSURLSession (PromiseKit)

/**
 Makes a GET request to the provided URL.

 [NSURLSession GET:@"http://placekitten.com/320/320"].then(^(UIImage *img){
 // PromiseKit decodes the image (if it’s an image)
 });

 @param urlStringFormatOrURL The `NSURL` or string format to request.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)GET:(id)urlStringFormatOrURL, ... NS_REFINED_FOR_SWIFT;

/**
 Makes a GET request with the provided query parameters.

 id url = @"http://jsonplaceholder.typicode.com/comments";
 id params = @{@"postId": @1};
 [NSURLSession GET:url query:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The `NSURL` or URL string format to request.

 @param parameters The parameters to be encoded as the query string for the GET request.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)GET:(NSString *)urlString query:(NSDictionary *)parameters NS_REFINED_FOR_SWIFT;

/**
 Makes a POST request to the provided URL passing form URL encoded
 parameters.

 Form URL-encoding is the standard way to POST on the Internet, so
 probably this is what you want. If it doesn’t work, try the `+POST:JSON`
 variant.

 id url = @"http://jsonplaceholder.typicode.com/posts";
 id params = @{@"title": @"foo", @"body": @"bar", @"userId": @1};
 [NSURLSession POST:url formURLEncodedParameters:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param parameters The parameters to be form URL-encoded and passed as the POST body.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)POST:(NSString *)urlString formURLEncodedParameters:(NSDictionary *)parameters NS_REFINED_FOR_SWIFT;

/**
 Makes a POST request to the provided URL passing JSON encoded parameters.

 Most web servers nowadays support POST with either JSON or form
 URL-encoding. If in doubt try form URL-encoded parameters first.

 id url = @"http://jsonplaceholder.typicode.com/posts";
 id params = @{@"title": @"foo", @"body": @"bar", @"userId": @1};
 [NSURLSession POST:url JSON:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param JSONParameters The parameters to be JSON encoded and passed as the POST body.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)POST:(NSString *)urlString JSON:(NSDictionary *)JSONParameters NS_REFINED_FOR_SWIFT;

/**
 Makes a PUT request to the provided URL passing form URL-encoded
 parameters.

 id url = @"http://jsonplaceholder.typicode.com/posts/1";
 id params = @{@"id": @1, @"title": @"foo", @"body": @"bar", @"userId": @1};
 [NSURLSession PUT:url formURLEncodedParameters:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param parameters The parameters to be form URL-encoded and passed as the HTTP body.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)PUT:(NSString *)urlString formURLEncodedParameters:(NSDictionary *)parameters NS_REFINED_FOR_SWIFT;

/**
 Makes a DELETE request to the provided URL passing form URL-encoded
 parameters.

 id url = @"http://jsonplaceholder.typicode.com/posts/1";
 id params = nil;
 [NSURLSession DELETE:url formURLEncodedParameters:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param parameters The parameters to be form URL-encoded and passed as the HTTP body.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)DELETE:(NSString *)urlString formURLEncodedParameters:(NSDictionary *)parameters NS_REFINED_FOR_SWIFT;

/**
 Makes a PATCH request to the provided URL passing the provided JSON parameters.

 id url = @"http://jsonplaceholder.typicode.com/posts/1";
 id params = nil;
 [NSURLSession PATCH:url JSON:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param JSONParameters The JSON parameters.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)PATCH:(NSString *)urlString JSON:(NSDictionary *)JSONParameters NS_REFINED_FOR_SWIFT;

/**
 Makes an HTTP request using the parameters specified by the provided URL
 request.

 This variant is less convenient, but provides you complete control over
 your `NSURLRequest`. Often this is necessary if your API requires
 authentication in the HTTP headers.

 Also, for example, if you need to send a multipart form request then
 PromiseKit provides no convenience method for this, however using
 OMGHTTPURLRQ (a dependency of this category), we can accomplish our
 requirements:

 OMGMultipartFormData *multipartFormData = [OMGMultipartFormData new];

 NSData *data1 = [NSData dataWithContentsOfFile:@"myimage1.png"];
 [multipartFormData addFile:data1 parameterName:@"file1" filename:@"myimage1.png" contentType:@"image/png"];

 NSMutableURLRequest *rq = [OMGHTTPURLRQ POST:url:multipartFormData];

 [NSURLSession promise:rq].then(^(id response){
 //…
 });

 @param request The URL request.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)promise:(NSURLRequest *)request NS_REFINED_FOR_SWIFT;

@end



#if TARGET_OS_MAC && !TARGET_OS_EMBEDDED && !TARGET_OS_SIMULATOR
/**
 To import the `NSTask` category:

 use_frameworks!
 pod "PromiseKit/Foundation"

 Or `NSTask` is one of the categories imported by the umbrella pod:

 use_frameworks!
 pod "PromiseKit"

 And then in your sources:

 @import PromiseKit;
 */
@interface NSTask (PromiseKit)

/**
 Launches the receiver and resolves when it exits.

 If the task fails the promise is rejected with code `PMKTaskError`, and
 `userInfo` keys: `PMKTaskErrorStandardOutputKey`,
 `PMKTaskErrorStandardErrorKey` and `PMKTaskErrorExitStatusKey`.

 NSTask *task = [NSTask new];
 task.launchPath = @"/usr/bin/basename";
 task.arguments = @[@"/usr/bin/sleep"];
 [task promise].then(^(NSString *stdout){
 //…
 });

 @return A promise that fulfills with three parameters:

 1) The stdout interpreted as a UTF8 string.
 2) The stderr interpreted as a UTF8 string.
 3) The stdout as `NSData`.
 */
- (AnyPromise *)promise NS_REFINED_FOR_SWIFT;

@end

#endif



#if TARGET_OS_OSX || TARGET_OS_IOS || TARGET_OS_TV

/**
 To import the `NSURLConnection` category:

 use_frameworks!
 pod "PromiseKit/Foundation"

 Or `NSURLConnection` is one of the categories imported by the umbrella pod:

 use_frameworks!
 pod "PromiseKit"

 And then in your sources:

 @import PromiseKit;

 PromiseKit automatically deserializes the raw HTTP data response into the
 appropriate rich data type based on the mime type the server provides.
 Thus if the response is JSON you will get the deserialized JSON response.
 PromiseKit supports decoding into strings, JSON and UIImages.

 However if your server does not provide a rich content-type, you will
 just get `NSData`. This is rare, but a good example we came across was
 downloading files from Dropbox.

 PromiseKit goes to quite some lengths to provide good `NSError` objects
 for error conditions at all stages of the HTTP to rich-data type
 pipeline. We provide the following additional `userInfo` keys as
 appropriate:

 - `PMKURLErrorFailingDataKey`
 - `PMKURLErrorFailingStringKey`
 - `PMKURLErrorFailingURLResponseKey`

 PromiseKit uses [OMGHTTPURLRQ](https://github.com/mxcl/OMGHTTPURLRQ) to
 make its HTTP requests. PromiseKit only provides a convenience layer
 above OMGHTTPURLRQ, thus if you need more power (eg. a multipartFormData
 POST), use OMGHTTPURLRQ to generate the `NSURLRequest` and then pass
 that request to `+promise:`.

 @see https://github.com/mxcl/OMGHTTPURLRQ
 */
@interface NSURLConnection (PromiseKit)

/**
 Makes a GET request to the provided URL.

 [NSURLConnection GET:@"http://placekitten.com/320/320"].then(^(UIImage *img){
 // PromiseKit decodes the image (if it’s an image)
 });

 @param urlStringFormatOrURL The `NSURL` or string format to request.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)GET:(id)urlStringFormatOrURL, ... NS_REFINED_FOR_SWIFT;

/**
 Makes a GET request with the provided query parameters.

 id url = @"http://jsonplaceholder.typicode.com/comments";
 id params = @{@"postId": @1};
 [NSURLConnection GET:url query:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The `NSURL` or URL string format to request.

 @param parameters The parameters to be encoded as the query string for the GET request.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)GET:(NSString *)urlString query:(NSDictionary *)parameters NS_REFINED_FOR_SWIFT;

/**
 Makes a POST request to the provided URL passing form URL encoded
 parameters.

 Form URL-encoding is the standard way to POST on the Internet, so
 probably this is what you want. If it doesn’t work, try the `+POST:JSON`
 variant.

 id url = @"http://jsonplaceholder.typicode.com/posts";
 id params = @{@"title": @"foo", @"body": @"bar", @"userId": @1};
 [NSURLConnection POST:url formURLEncodedParameters:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param parameters The parameters to be form URL-encoded and passed as the POST body.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)POST:(NSString *)urlString formURLEncodedParameters:(NSDictionary *)parameters NS_REFINED_FOR_SWIFT;

/**
 Makes a POST request to the provided URL passing JSON encoded parameters.

 Most web servers nowadays support POST with either JSON or form
 URL-encoding. If in doubt try form URL-encoded parameters first.

 id url = @"http://jsonplaceholder.typicode.com/posts";
 id params = @{@"title": @"foo", @"body": @"bar", @"userId": @1};
 [NSURLConnection POST:url JSON:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param JSONParameters The parameters to be JSON encoded and passed as the POST body.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)POST:(NSString *)urlString JSON:(NSDictionary *)JSONParameters NS_REFINED_FOR_SWIFT;

/**
 Makes a PUT request to the provided URL passing form URL-encoded
 parameters.

 id url = @"http://jsonplaceholder.typicode.com/posts/1";
 id params = @{@"id": @1, @"title": @"foo", @"body": @"bar", @"userId": @1};
 [NSURLConnection PUT:url formURLEncodedParameters:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param parameters The parameters to be form URL-encoded and passed as the HTTP body.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)PUT:(NSString *)urlString formURLEncodedParameters:(NSDictionary *)parameters NS_REFINED_FOR_SWIFT;

/**
 Makes a DELETE request to the provided URL passing form URL-encoded
 parameters.

 id url = @"http://jsonplaceholder.typicode.com/posts/1";
 id params = nil;
 [NSURLConnection DELETE:url formURLEncodedParameters:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param parameters The parameters to be form URL-encoded and passed as the HTTP body.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)DELETE:(NSString *)urlString formURLEncodedParameters:(NSDictionary *)parameters NS_REFINED_FOR_SWIFT;

/**
 Makes a PATCH request to the provided URL passing the provided JSON parameters.

 id url = @"http://jsonplaceholder.typicode.com/posts/1";
 id params = nil;
 [NSURLConnection PATCH:url JSON:params].then(^(NSDictionary *jsonResponse){
 // PromiseKit decodes the JSON dictionary (if it’s JSON)
 });

 @param urlString The URL to request.

 @param JSONParameters The JSON parameters.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)PATCH:(NSString *)urlString JSON:(NSDictionary *)JSONParameters;

/**
 Makes an HTTP request using the parameters specified by the provided URL
 request.

 This variant is less convenient, but provides you complete control over
 your `NSURLRequest`. Often this is necessary if your API requires
 authentication in the HTTP headers.

 Also, for example, if you need to send a multipart form request then
 PromiseKit provides no convenience method for this, however using
 OMGHTTPURLRQ (a dependency of this category), we can accomplish our
 requirements:

 OMGMultipartFormData *multipartFormData = [OMGMultipartFormData new];

 NSData *data1 = [NSData dataWithContentsOfFile:@"myimage1.png"];
 [multipartFormData addFile:data1 parameterName:@"file1" filename:@"myimage1.png" contentType:@"image/png"];

 NSMutableURLRequest *rq = [OMGHTTPURLRQ POST:url:multipartFormData];

 [NSURLConnection promise:rq].then(^(id response){
 //…
 });

 @param request The URL request.

 @return A promise that fulfills with three parameters:

 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */
+ (AnyPromise *)promise:(NSURLRequest *)request NS_REFINED_FOR_SWIFT;

@end

#endif
