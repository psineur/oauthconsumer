//
//  OADataFetcher.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OADataFetcher.h"

@implementation OADataFetcher

@synthesize disableRedirects = _disableRedirects;
@synthesize delegate = delegate;

- (id)init {
	if ((self = [super init])) {
		responseData = [[NSMutableData alloc] init];
	}
	return self;
}

- (void)dealloc {
    delegate = nil;
	[connection release];
	[response release];
	[responseData release];
	[request release];
	[super dealloc];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)aRequest redirectResponse:(NSURLResponse *)aResponse
{    
    // Disable redirects if needed.
    if (_disableRedirects && aResponse)
        return nil;
    
    return aRequest;
}

/* Protocol for async URL loading */
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse {
	[response release];
	response = [aResponse retain];
	[responseData setLength:0];
}
	
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
															  response:response
																  data:responseData
															didSucceed:NO];

	[delegate ticket:ticket didFailWithError:error];
	[ticket release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest: (OAMutableURLRequest *)request
															  response:response
																  data:responseData
															didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];

	[delegate ticket:ticket didFinishWithData:responseData];
	[ticket release];
}

- (void)fetchDataWithRequest:(NSURLRequest *)aRequest delegate:(id)aDelegate {
	[request release];
	request = [aRequest retain];
    delegate = aDelegate;
    
    if ([aRequest isKindOfClass: [OAMutableURLRequest class]])
    {
        [(OAMutableURLRequest *)request prepare];
    }

	connection = [[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
}

@end
