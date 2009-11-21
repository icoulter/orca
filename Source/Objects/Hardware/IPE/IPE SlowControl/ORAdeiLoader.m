//--------------------------------------------------------
// ORAdeiLoader
// Created by Mark  A. Howe on Sun Oct 11 2009
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2009 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#import "ORAdeiLoader.h"

@implementation ORAdeiLoader
+ (id) loaderWithAdeiHost:(NSString*)aHost adeiType:(int)aType delegate:(id)aDelegate didFinishSelector:(SEL)aSelector
{
	return [[[ORAdeiLoader alloc] initWithAdeiHost:aHost adeiType:aType delegate:aDelegate didFinishSelector:aSelector] autorelease];
}

+ (id) loaderWithAdeiHost:(NSString*)aHost adeiType:(int)aType delegate:(id)aDelegate didFinishSelector:(SEL)aSelector setupOptions:(NSArray*)setupOptions
{
	return [[[ORAdeiLoader alloc] initWithAdeiHost:aHost adeiType:aType delegate:aDelegate didFinishSelector:aSelector  setupOptions:setupOptions] autorelease];
}

- (id) initWithAdeiHost:(NSString*)aHost adeiType:(int)aType  delegate:(id)aDelegate didFinishSelector:(SEL)aSelector
{
	return [self initWithAdeiHost:aHost adeiType:aType delegate:aDelegate didFinishSelector:aSelector setupOptions:nil];
}

- (id) initWithAdeiHost:(NSString*)aHost adeiType:(int)aType  delegate:(id)aDelegate didFinishSelector:(SEL)aSelector setupOptions:(NSArray*)someArray
{
	self = [super init];
	host = [aHost retain];
	delegate			= aDelegate;
	didFinishSelector	= aSelector;
	adeiType			= aType;
	setupOptions		= [someArray retain];
	[self retain];
	return self;
}

- (void) dealloc
{
	[host release];
	[path release];
	[setupOptions release];
	[theAdeiConnection release];
	[receivedData release];
	[resultArray release];
	[super dealloc];
}

- (void) writeControl:(NSString*)aPath value:(double)aValue
{
	//example: @"http://ipepdvadei.ka.fzk.de/test/services/control.php?db_server=test_zeus&db_name=cfp_test&control_group=3&control_mask=2&target=set&control_values=%f",aValue];

	if([aPath hasPrefix:@"/"])aPath = [aPath substringFromIndex:1];
	NSArray* components = [aPath componentsSeparatedByString:@"/"];
	if([components count] == 4){
		NSString* requestString = [NSMutableString stringWithFormat:
								   @"%@/services/control.php?db_server=%@&db_name=%@&control_group=%@&control_mask=%@&target=set&control_values=%f",
								   host,
								   [components objectAtIndex:0],
								   [components objectAtIndex:1],
								   [components objectAtIndex:2],
								   [components objectAtIndex:3],
								   aValue];
		if(requestString){
			dataFormat = kxmlFormat;
			path = [aPath copy];
			recursive  = NO;
			NSURL* furl = [NSURL URLWithString: requestString];
			NSURLRequest* theRequest=[NSURLRequest requestWithURL:furl  cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10.0];// make it configurable
			theAdeiConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		}
	}
}

- (void) requestItem:(NSString*)aPath
{
	if(adeiType == kControlType) [self requestControlItem:aPath];
	else						 [self requestSensorItem:aPath];
}

- (void) requestSensorItem:(NSString*)aPath
{
	NSString* requestString = [ORAdeiLoader sensorItemRequestStringUrl:host itemPath:aPath];
	if(requestString){
		if([setupOptions count]){
			//for now we only support one option
			requestString = [requestString stringByAppendingFormat:@"&setup=%@",[setupOptions objectAtIndex:0]];
		}
		dataFormat = kcsvFormat;
		path = [aPath copy];
		recursive  = NO;
		NSURL* furl = [NSURL URLWithString: requestString];
		NSURLRequest* theRequest=[NSURLRequest requestWithURL:furl  cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10.0];// make it configurable
		theAdeiConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
}

- (void) requestControlItem:(NSString*)aPath
{
	NSString* requestString = [ORAdeiLoader controlItemRequestStringUrl:host itemPath:aPath];
	if(requestString){
		dataFormat = kxmlFormat;
		path = [aPath copy];
		recursive  = NO;
		NSURL* furl = [NSURL URLWithString: requestString];
		NSURLRequest* theRequest=[NSURLRequest requestWithURL:furl  cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10.0];// make it configurable
		theAdeiConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
}

- (void) loadPath:(NSString*)aPath recursive:(BOOL)aFlag
{
	NSArray* components;
	int count = 0;
	recursive = aFlag;
	//db paths are of the form '/server/database/group/item'
	//nil and empty strings are considered a 'root' path
	if([aPath isEqual:@"/"] || ([aPath length]==0)) count = 0;
	else {
		if([aPath hasPrefix:@"/"])aPath = [aPath substringFromIndex:1];
		components = [aPath componentsSeparatedByString:@"/"];
		count = [components count];
	}
	
	//@"http://ipepdvadei.ka.fzk.de/test/services/control.php?db_server=test_zeus&db_name=cfp_test&control_group=3&control_mask=3

	NSMutableString* requestString = nil;
	switch (count) {
		case 0:	//path was nil. get all servers
			requestString = [NSMutableString stringWithFormat:@"%@/services/list.php?target=servers",host];
		break;
			
		case 1:	//data bases
			requestString = [NSMutableString stringWithFormat:@"%@/services/list.php?db_server=%@&target=databases",host,[components objectAtIndex:0]];
		break;
			
		case 2:	//groups
			if(adeiType == kSensorType){
				requestString = [NSMutableString stringWithFormat:@"%@/services/list.php?db_server=%@&db_name=%@&target=groups",host,[components objectAtIndex:0],[components objectAtIndex:1]];
			}
			else {
				requestString = [NSMutableString stringWithFormat:@"%@/services/list.php?db_server=%@&db_name=%@&target=cgroups",host,[components objectAtIndex:0],[components objectAtIndex:1]];
			}
		break;
			
		case 3: //items
			if(adeiType == kSensorType){
				requestString = [NSMutableString stringWithFormat:@"%@/services/list.php?db_server=%@&db_name=%@&db_group=%@&target=items",host,[components objectAtIndex:0],[components objectAtIndex:1],[components objectAtIndex:2]];
			}
			else {
				requestString = [NSMutableString stringWithFormat:@"%@/services/list.php?db_server=%@&db_name=%@&control_group=%@&target=controls",host,[components objectAtIndex:0],[components objectAtIndex:1],[components objectAtIndex:2]];
			}
		break;
			
		default:
		break;
	}
	
	if(requestString){
		dataFormat = kxmlFormat;
		path = [aPath copy];
		NSURL* furl = [NSURL URLWithString: requestString];
		NSURLRequest* theRequest=[NSURLRequest requestWithURL:furl  cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10.0];// make it configurable
		theAdeiConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
}

#pragma mark ***Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(!receivedData)receivedData = [[NSMutableData data] retain];
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection  didFailWithError:(NSError *)error
{	
    if(connection==theAdeiConnection){
        // release the connection, and the data object
        [theAdeiConnection release];
		theAdeiConnection = nil;
        [receivedData release];
		receivedData = nil;
		NSLogError(@"ADEI Loader",@"Connection Failed",[error localizedDescription], nil);
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(dataFormat == kxmlFormat){
		[self parseXMLData:receivedData];
		if(adeiType==kControlType){
			NSMutableDictionary* dictionary = [resultArray objectAtIndex:0];
			[dictionary setObject:host	forKey:@"URL"];
			[dictionary setObject:path	forKey:@"Path"];
		}
	}
	else {
		[self parseCSVData:receivedData];
	}
	[receivedData release];
	receivedData = nil;
	if(didFinishSelector){
	    NSInvocation* anInvocation = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:didFinishSelector]];
	    int numGetArgs = [[delegate methodSignatureForSelector:didFinishSelector] numberOfArguments]-2;
	    [anInvocation setSelector:didFinishSelector];
	    [anInvocation setTarget:delegate];
        
	    if(numGetArgs){
			[anInvocation setArgument:0 to:resultArray];
			[anInvocation setArgument:1 to:path];
			[anInvocation invoke];
		}
	}

	if(recursive){
		//paths are of the form '/server/database/group/item'
		//nil and empty strings are considered a 'root' path
		int count;
		NSArray* components;
		if([path isEqual:@"/"] || ([path length]==0)) count = 0;
		else {
			components = [path componentsSeparatedByString:@"/"];
			count = [components count];
		}
		
		switch (count) {
			case 0: //result should be list of servers
				for(id server in resultArray){
					NSString* serverName = [server objectForKey:@"db_server"];
					ORAdeiLoader* aLoader = [ORAdeiLoader loaderWithAdeiHost:host adeiType:adeiType delegate:delegate didFinishSelector:didFinishSelector];
					NSString* aPath = [NSString stringWithFormat:@"%@%@",path,serverName];
					[aLoader loadPath:aPath	recursive:YES];
				}
			break;
				
			case 1: //result should be list of databases
				for(id aDataBase in resultArray){
					NSString* dataBaseName = [aDataBase objectForKey:@"db_name"];
					ORAdeiLoader* aLoader = [ORAdeiLoader loaderWithAdeiHost:host  adeiType:adeiType  delegate:delegate didFinishSelector:didFinishSelector];
					NSString* aPath = [NSString stringWithFormat:@"%@/%@",path,dataBaseName];
					[aLoader loadPath:aPath	recursive:YES];
				}
			break;
				
			case 2: //result should be list of groups
				for(id aGroup in resultArray){
					NSString* groupName;
					groupName= [aGroup objectForKey:@"db_group"];
					ORAdeiLoader* aLoader = [ORAdeiLoader loaderWithAdeiHost:host  adeiType:adeiType delegate:delegate didFinishSelector:didFinishSelector];
					NSString* aPath = [NSString stringWithFormat:@"%@/%@",path,groupName];
					[aLoader loadPath:aPath	recursive:YES];
				}
			break;
								
			default:
			break;
		}
	}
	[self autorelease];
}

- (void) parseXMLData:(NSData *)xmlData
{
 	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
	[parser parse];
    [parser release];
}

- (void) parseCSVData:(NSData*)someData
{
	//format is Date,N1,N2,N3.....\nDateValue,V1,V2,V3...
	//we put it into a some dictionaries where the Nx values have key= @"NAME" 
	//and the Vx values have the key = @"Value"
	NSString* s		= [[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding] autorelease];
	if([s rangeOfString:@"ERROR"].location == NSNotFound){
		s				= [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
		NSArray* lines	= [s componentsSeparatedByString:@"\n"];
		NSArray* keys	= [[lines objectAtIndex:0] componentsSeparatedByString:@","];
		NSArray* values = [[lines objectAtIndex:1] componentsSeparatedByString:@","];
		NSArray* itemNumbers = [[path lastPathComponent] componentsSeparatedByString:@","];
		NSString* pathRoot = [[[path stringByDeletingLastPathComponent] mutableCopy] autorelease];
		if(([keys count] == [values count]) && ([itemNumbers count] == ([values count]-1))) {
			if(!resultArray)resultArray = [[NSMutableArray array] retain];
			int i;
			NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
			[dictionary setObject:host	forKey:@"URL"];
			[dictionary setObject:[values objectAtIndex:0]	forKey:@"Date"];
			for(i=1;i<[keys count];i++){
				[dictionary setObject:[pathRoot stringByAppendingPathComponent:[itemNumbers objectAtIndex:i-1]]	forKey:@"Path"];
				[dictionary setObject:[keys objectAtIndex:i]	forKey:@"Name"];
				[dictionary setObject:[values objectAtIndex:i]	forKey:@"Value"];
			}
			[resultArray addObject:dictionary];
		}
	}
}

#pragma mark Delegate calls
- (void) parser:(NSXMLParser*) parser
didStartElement:(NSString*) elementName
   namespaceURI:(NSString*) namespaceURI
  qualifiedName:(NSString*) qName
	 attributes:(NSDictionary*) attributeDict
{
	if([elementName isEqual:@"Value"]){
		if(!resultArray)resultArray = [[NSMutableArray array] retain];
		NSMutableDictionary* dictWithAdditions = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
		if(adeiType)[dictWithAdditions setObject:[NSNumber numberWithInt:adeiType]	forKey:@"Control"];
		[resultArray addObject:dictWithAdditions];
	}
}

+ (NSString*) controlItemRequestStringUrl:(NSString*)aUrl itemPath:(NSString*)aPath;
{
	NSString* requestString = nil;
	if([aPath hasPrefix:@"/"])aPath = [aPath substringFromIndex:1];
	NSArray* components = [aPath componentsSeparatedByString:@"/"];
	if([components count] == 4) {
		requestString = [NSMutableString stringWithFormat:
						 @"%@/services/control.php?db_server=%@&db_name=%@&control_group=%@&control_mask=%@&target=get",
						 aUrl,
						 [components objectAtIndex:0],
						 [components objectAtIndex:1],
						 [components objectAtIndex:2],
						 [components objectAtIndex:3]
						 ];
		
	}
	return requestString;
}

+ (NSString*) sensorItemRequestStringUrl:(NSString*)aUrl itemPath:(NSString*)aPath;
{
	NSString* requestString = nil;
	if([aPath hasPrefix:@"/"])aPath = [aPath substringFromIndex:1];
	NSArray* components = [aPath componentsSeparatedByString:@"/"];
	if([components count] == 4) {
		requestString = [NSMutableString stringWithFormat:
						 @"%@/services/getdata.php?format=csv&db_server=%@&db_name=%@&db_group=%@&window=-1&db_mask=%@",
						 aUrl,
						 [components objectAtIndex:0],
						 [components objectAtIndex:1],
						 [components objectAtIndex:2],
						 [components objectAtIndex:3]
						 ];
	}
	return requestString;
}

+ (NSString*) webRequestStringUrl:(NSString*)url itemPath:(NSString*)path
{
	NSString* requestString = nil;
	NSArray* components = [path componentsSeparatedByString:@"/"];
	if([components count] == 4) {
		requestString = [NSMutableString stringWithFormat:
				 @"%@/?minimal=graph#&module=graph&db_server=%@&db_name=%@&db_group=%@&db_mask=%@&window=0",
				 url,
				 [components objectAtIndex:0],
				 [components objectAtIndex:1],
				 [components objectAtIndex:2],
				 [components objectAtIndex:3]
				 ];
	}
	return requestString;
}
@end
