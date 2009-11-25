//--------------------------------------------------------
// ORIpeSlowControlModel
// Created by Mark  A. Howe on Mon Apr 11 2005
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
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

#pragma mark ***Imported Files

#import "ORIpeSlowControlModel.h"
#import "ORDataTaker.h"
#import "ORDataTypeAssigner.h"
#import "ORAdeiLoader.h"

#pragma mark •••Notification Strings
NSString* ORIpeSlowControlModelShipRecordsChanged	= @"ORIpeSlowControlModelShipRecordsChanged";
NSString* ORIpeSlowControlModelTotalRequestCountChanged = @"ORIpeSlowControlModelTotalRequestCountChanged";
NSString* ORIpeSlowControlModelTimeOutCountChanged	= @"ORIpeSlowControlModelTimeOutCountChanged";
NSString* ORIpeSlowControlModelFastGenSetupChanged	= @"ORIpeSlowControlModelFastGenSetupChanged";
NSString* ORIpeSlowControlModelSetPointChanged		= @"ORIpeSlowControlModelSetPointChanged";
NSString* ORIpeSlowControlModelItemTypeChanged		= @"ORIpeSlowControlModelItemTypeChanged";
NSString* ORIpeSlowControlModelViewItemNameChanged	= @"ORIpeSlowControlModelViewItemNameChanged";
NSString* ORIpeSlowControlLock                      = @"ORIpeSlowControlLock";
NSString* ORIpeSlowControlSelectedSensorNumChanged  = @"ORIpeSlowControlSelectedSensorNumChanged";
NSString* ORIpeSlowControlItemListChanged			= @"ORIpeSlowControlItemListChanged";
NSString* ORIpeSlowControlAdeiBaseUrlForSensorChanged = @"ORIpeSlowControlAdeiBaseUrlForSensorChanged";
NSString* ORIpeSlowControlPollTimeChanged			= @"ORIpeSlowControlPollTimeChanged";
NSString* ORIpeSlowControlLastRequestChanged		= @"ORIpeSlowControlLastRequestChanged";
NSString* ORIpeSlowControlIPNumberChanged			= @"ORIpeSlowControlIPNumberChanged";
NSString* ORIpeSlowItemTreeChanged					= @"ORIpeSlowItemTreeChanged";
NSString* ORIpeSlowControlModelHistogramChanged		= @"ORIpeSlowControlModelHistogramChanged";
NSString* ORIpeSlowControlPendingRequestsChanged	= @"ORIpeSlowControlPendingRequestsChanged";

NSString* ORADEIInConnection						= @"ORADEIInConnection";

#define IPE_SLOW_CONTROL_SHORT_NAME @"IPE-ADEI"

@interface ORIpeSlowControlModel (private)
- (NSMutableArray*) insertNode:(id)aNode intoArray:(NSMutableArray*)anArray path:(NSString*)aPath nodeName:(NSString*)nodeName isLeaf:(BOOL)isLeaf;
- (void) itemTreeResults:(id)result path:(NSString*)aPath;
- (void) polledItemResult:(id)result path:(NSString*)aPath;
- (void) clearPendingRequest:(NSString*)anItemKey;
- (void) setPendingRequest:(NSString*)anIemKey;
- (void) checkForTimeOuts;
- (void) shipTheRecords;
- (NSTimeInterval) timeFromADEIDate:(NSString*)aDate;
- (void) addItemKeyToPollingLookup:(NSString*) anItemKey;
- (void) removeItemKeyFromPollingLookup:(NSString*) anItemKey;
@end

@implementation ORIpeSlowControlModel
- (id) init
{
	self = [super init];
	[self initBasics];
	return self;
}

- (id) initBasics
{
    //FZK-internal: [self setAdeiServiceUrl: @"http://ipepdvadei.ka.fzk.de/adei/services/"];//TODO: make attribute -tb-
    [self setIPNumber: @"fuzzy.fzk.de/adei"];
	return self;
}

- (void) dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[connectionHistory release];
	[itemTreeRoot release];
	[requestCache release];
	[super dealloc];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"IpeSlowControl"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORIpeSlowControlController"];
}

- (BOOL) solitaryObject
{
    return YES;
}

-(void) makeConnectors
{
	//we  have three permanent connectors. The rest we manage for the pci objects.
    ORConnector* aConnector = [[ORConnector alloc] initAt:NSMakePoint(0, 0) withGuardian:self withObjectLink:self];
    [[self connectors] setObject:aConnector forKey:ORADEIInConnection];
    [aConnector setOffColor:[NSColor magentaColor]];
    [aConnector setOffColor:[NSColor brownColor]];
	[aConnector setConnectorType: 'ADEI'];
	[aConnector addRestrictedConnectionType: 'ADEO']; //can only connect to DB Inputs
    [aConnector release];
}

- (void) initConnectionHistory
{
	ipNumberIndex = [[NSUserDefaults standardUserDefaults] integerForKey: [NSString stringWithFormat:@"orca.%@.IPNumberIndex",[self className]]];
	if(!connectionHistory){
		NSArray* his = [[NSUserDefaults standardUserDefaults] objectForKey: [NSString stringWithFormat:@"orca.%@.ConnectionHistory",[self className]]];
		connectionHistory = [his mutableCopy];
	}
	if(!connectionHistory)connectionHistory = [[NSMutableArray alloc] init];
}

- (void) clearHistory
{
	[connectionHistory release];
	connectionHistory = nil;
	
	[self setIPNumber:IPNumber];
}


#pragma mark ***Accessors

- (BOOL) shipRecords
{
    return shipRecords;
}

- (void) setShipRecords:(BOOL)aShipRecords
{
    [[[self undoManager] prepareWithInvocationTarget:self] setShipRecords:shipRecords];
    shipRecords = aShipRecords;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlModelShipRecordsChanged object:self];
}

- (int) totalRequestCount
{
    return totalRequestCount;
}

- (void) setTotalRequestCount:(int)aTotalRequestCount
{
    totalRequestCount = aTotalRequestCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlModelTotalRequestCountChanged object:self];
}

- (int) timeOutCount
{
    return timeOutCount;
}

- (void) setTimeOutCount:(int)aTimeOutCount
{
    timeOutCount = aTimeOutCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlModelTimeOutCountChanged object:self];
}

- (BOOL) fastGenSetup
{
    return fastGenSetup;
}

- (void) setFastGenSetup:(BOOL)aFastGenSetup
{
    [[[self undoManager] prepareWithInvocationTarget:self] setFastGenSetup:fastGenSetup];
    fastGenSetup = aFastGenSetup;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlModelFastGenSetupChanged object:self];
}

- (double) setPoint
{
    return setPoint;
}

- (void) setSetPoint:(double)aSetPoint
{
    [[[self undoManager] prepareWithInvocationTarget:self] setSetPoint:setPoint];
    setPoint = aSetPoint;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlModelSetPointChanged object:self];
}

- (int) itemType
{
    return itemType;
}

- (void) setItemType:(int)aItemType
{
    [[[self undoManager] prepareWithInvocationTarget:self] setItemType:itemType];
    itemType = aItemType;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlModelItemTypeChanged object:self];
}

- (BOOL) viewItemName
{
    return viewItemName;
}

- (void) setViewItemName:(BOOL)aViewItemName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setViewItemName:viewItemName];
    viewItemName = aViewItemName;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlModelViewItemNameChanged object:self];
}

- (unsigned) connectionHistoryCount
{
	return [connectionHistory count];
}

- (id) connectionHistoryItem:(unsigned)index
{
	if(connectionHistory && index>=0 && index<[connectionHistory count])return [connectionHistory objectAtIndex:index];
	else return nil;
}

- (unsigned) ipNumberIndex
{
	return ipNumberIndex;
}

- (NSString*) IPNumber
{
	if(!IPNumber)return @"";
    return IPNumber;
}

- (void) setIPNumber:(NSString*)aIPNumber
{
	if(!aIPNumber) aIPNumber = @"http://ipepdvadei.ka.fzk.de/adei";
	[[[self undoManager] prepareWithInvocationTarget:self] setIPNumber:IPNumber];
	
	[IPNumber autorelease];
	IPNumber = [aIPNumber copy];    
	
	//load into the connection history for the comboxbox popup
	if(!connectionHistory)connectionHistory = [[NSMutableArray alloc] init];
	if(![connectionHistory containsObject:IPNumber]){
		[connectionHistory addObject:IPNumber];
	}
	ipNumberIndex = [connectionHistory indexOfObject:aIPNumber];
	
	[[NSUserDefaults standardUserDefaults] setObject:connectionHistory forKey:[NSString stringWithFormat:@"orca.%@.ConnectionHistory",[self className]]];
	[[NSUserDefaults standardUserDefaults] setInteger:ipNumberIndex forKey:[NSString stringWithFormat:@"orca.%@.IPNumberIndex",[self className]]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlIPNumberChanged object:self];
}

- (NSString*) ipNumberToURL
{
	//convert a host name xxx.xxx.xxx to a url of form http://xxxx.xxx.xxx
	NSMutableString* goodUrl = [NSMutableString stringWithString: [self IPNumber]];
	if([goodUrl length]){
		if(![goodUrl hasPrefix:   @"http://"]) [goodUrl insertString: @"http://"  atIndex: 0];
		if(![goodUrl hasSuffix:   @"/"]) [goodUrl appendString: @"/"];
	}
	return goodUrl;
}

- (NSString*) lastRequest
{
	if(!lastRequest)return @"";
	return lastRequest;
}

- (void) setLastRequest:(NSString*)aString
{
	if([aString length]==0)aString = @"";
	[aString autorelease];
	lastRequest = [aString copy];
	[[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlLastRequestChanged object:self];
}

- (int) pollTime
{
    return pollTime;
}

- (void) setPollTime:(int)aPollTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollTime:pollTime];
    pollTime = aPollTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlPollTimeChanged object:self];
	
	if(pollTime)[self performSelector:@selector(pollSlowControls) withObject:nil afterDelay:2];
	else		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollSlowControls) object:nil];
}

- (void) setDataIds:(id)assigner
{
    channelDataId = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherObject
{
    [self setChannelDataId:     [anotherObject channelDataId]];
}

- (int) channelDataId
{
    return channelDataId;
}

- (void) setChannelDataId:(int) aValue
{
    channelDataId = aValue;
}

- (void) dumpSensorlist
{
	NSLog(@"%@\n",requestCache);
}

#pragma mark ***Polled Item via LookupTable index
- (BOOL) itemExists:(int)anIndex
{
	return anIndex<[pollingLookUp count];
}

- (BOOL) isControlItem:(int)anIndex
{
	//anIndex is NOT the channel Number
	if(anIndex<[pollingLookUp count]){
		NSString* itemKey = [pollingLookUp objectAtIndex:anIndex];
		NSDictionary* topLevelDictionary = [requestCache objectForKey:itemKey];
		NSDictionary* itemDictionary = [topLevelDictionary objectForKey:itemKey];
		return [itemDictionary objectForKey:@"Control"]!=nil;
	}
	else return NO;
}

- (NSString*) requestCacheItemKey:(int)anIndex
{
	//Note: index is NOT channel, it is the index of the item in the details panel
	//use the lookup table to return the polingCache's topLevelDictionary
	//to have fast access by index to the requestCache, there is a lookupTable Array of the 
	//form: itemKey0,itemKey1,itemKey2....
	if(anIndex<[pollingLookUp count]){
		return [pollingLookUp objectAtIndex:anIndex];
	}
	else return nil;
}

- (NSDictionary*) requestCacheItem:(int)anIndex
{
	//Note: index is NOT channel, it is the index of the item in the details panel
	//use the lookup table to return the polingCache's topLevelDictionary
	//to have fast access by index to the requestCache, there is a lookupTable Array of the 
	//form: itemKey0,itemKey1,itemKey2....
	if(anIndex<[pollingLookUp count]){
		NSString* itemKey = [pollingLookUp objectAtIndex:anIndex];
		NSDictionary* topLevelDictionary = [requestCache objectForKey:itemKey];
		return [topLevelDictionary objectForKey:itemKey];
	}
	else return nil;
}

- (unsigned) pollingLookUpCount
{
	return [pollingLookUp count];
}

- (NSString*) createWebRequestForItem:(int)anIndex
{
	//anIndex is NOT the channel number
	//examples for a single sensor request:
	//fuzzy.fzk.de/adei/#db_server=katrin&db_name=hauptspektrometer&db_group=0&db_mask=1&experiment=0-0&window=0&history_id=1232130010554
	//fuzzy.fzk.de/adei/#db_server=katrin&db_name=hauptspektrometer&db_group=0&db_mask=1&experiment=0-0&window=0
	//fuzzy.fzk.de/adei/#minimal=graph&db_server=katrin&db_name=hauptspektrometer&db_group=0&db_mask=1&window=0
	NSString* requestString = nil;
	if(anIndex<[pollingLookUp count]){
		NSString* itemKey	= [pollingLookUp objectAtIndex:anIndex];
		NSDictionary* topLevelDictionary = [requestCache objectForKey:itemKey];
		NSDictionary* itemDictionary	 = [topLevelDictionary objectForKey:itemKey];
		NSString* url		= [itemDictionary objectForKey:@"URL"];
		NSString* path		= [itemDictionary objectForKey:@"Path"];
		requestString = [ORAdeiLoader webRequestStringUrl:url itemPath:path];
		[self setTotalRequestCount:totalRequestCount+1];
	}
	return requestString;
}


#pragma mark •••Polled item access via itemKey
- (NSMutableDictionary*) topLevelPollingDictionary:(id)anItemKey
{
	return [requestCache objectForKey:anItemKey];
}

#pragma mark •••Channel Loop Up Methods
- (void) makeChannelLookup
{
	[channelLookup release];
	channelLookup = [[NSMutableDictionary dictionary] retain];
	for(id itemKey in pollingLookUp){
		NSDictionary* topLevelDictionary = [requestCache objectForKey:itemKey];
		id channelNumber = [topLevelDictionary objectForKey:@"ChannelNumber"];
		if(channelNumber){
			[channelLookup setObject:itemKey forKey:channelNumber];
		}
	}
}

- (int) nextUnusedChannelNumber
{
	int proposedIndex = 0;
	do {
		BOOL alreadyUsed = NO;
		for(id itemKey in pollingLookUp){
			NSDictionary* topLevelDictionary = [requestCache objectForKey:itemKey];
			int aChannelNumber = [[topLevelDictionary objectForKey:@"ChannelNumber"] intValue];
			if(aChannelNumber == proposedIndex){
				alreadyUsed = YES;
				proposedIndex++;
				break; //no need to continue this loop
			}
		}
		if(!alreadyUsed)break;
	} while(1);
	return proposedIndex;
}

#pragma mark •••Polling Cache Management
//addItems to the polling loop
- (void) addItems:(NSArray*)anItemArray
{
	if(!requestCache)   requestCache = [[NSMutableDictionary dictionary] retain];
	if(!pollingLookUp)  pollingLookUp = [[NSMutableArray array] retain];
	for(id anItem in anItemArray){
		NSString* itemKey = [self itemKey:[anItem objectForKey:@"URL"]:[anItem objectForKey:@"Path"]];
		
		if(![pollingLookUp containsObject:itemKey]){
			//we have never seen this item before, so add it alone with some extra info for the processing system
			//item not in the list yet... add it
			int aChannelNumber = [self nextUnusedChannelNumber]; //find an unused channel number in the polling List
			NSMutableDictionary* topLevelDictionary = [self makeTopLevelDictionary];
			[topLevelDictionary setObject:anItem forKey:itemKey];			
			[topLevelDictionary setObject:[NSNumber numberWithInt:aChannelNumber]	forKey:@"ChannelNumber"]; //channel number for access by the processing system
			
			[requestCache setObject:topLevelDictionary forKey:itemKey];
			[self addItemKeyToPollingLookup:itemKey];
		}
	}
}

- (void) removeSet:(NSIndexSet*)aSetToRemove
{
	NSMutableArray* itemsToRemove = [NSMutableArray array];
	unsigned current_index = [aSetToRemove firstIndex];
    while (current_index != NSNotFound) {
		if(current_index<[pollingLookUp count]){
			NSString* itemKey = [self requestCacheItemKey:current_index];
			[itemsToRemove addObject:itemKey];
		}
		current_index = [aSetToRemove indexGreaterThanIndex: current_index];
    }
	for(id aKey in itemsToRemove){
		[self removeItemKeyFromPollingLookup:aKey];
	}
}


- (NSMutableDictionary*) makeTopLevelDictionary
{
	NSMutableDictionary* topLevelDictionary = [NSMutableDictionary dictionary];
	[topLevelDictionary setObject:[NSNumber numberWithInt:0]		forKey:@"LoAlarm"]; //used by processing
	[topLevelDictionary setObject:[NSNumber numberWithInt:100]		forKey:@"HiAlarm"]; //used by processing
	[topLevelDictionary setObject:[NSNumber numberWithInt:0]		forKey:@"LoLimit"]; //used by processing
	[topLevelDictionary setObject:[NSNumber numberWithInt:100]		forKey:@"HiLimit"]; //used by processing
	return topLevelDictionary;
}


#pragma mark •••Item Tree Management
- (void) setItemTreeRoot:(NSMutableArray*)anArray
{
	[anArray retain];
	[itemTreeRoot release];
	itemTreeRoot = anArray;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowItemTreeChanged object:self];
}

- (NSArray*) itemTreeRoot
{
	return itemTreeRoot;
}

- (void) loadItemTree
{
	[itemTreeRoot release];
	itemTreeRoot = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowItemTreeChanged object:self];
	ORAdeiLoader* aLoader = [ORAdeiLoader loaderWithAdeiHost:[self ipNumberToURL] adeiType:itemType delegate:self didFinishSelector:@selector(itemTreeResults:path:)];
	[aLoader loadPath:@"/" recursive:YES];
}

- (NSString*) itemDetails:(int)anIndex
{
	//anIndex in NOT channel number
	if(anIndex<[pollingLookUp count]){
		NSString* itemKey = [pollingLookUp objectAtIndex:anIndex];
		id topLevelDictionary = [requestCache objectForKey:itemKey];
		NSString* s = [topLevelDictionary description];
		s = [s stringByReplacingOccurrencesOfString:@"{" withString:@""];
		s = [s stringByReplacingOccurrencesOfString:@"}" withString:@""];
		s = [s stringByReplacingOccurrencesOfString:@"\t" withString:@""];
		s = [s stringByReplacingOccurrencesOfString:@";" withString:@""];
		return s;
	}
	else return @"<Error: index out of bounds>";
}

- (NSString*) itemKey:aUrl:aPath
{
	if([aPath hasPrefix:@"/"])return [NSString stringWithFormat:@"%@%@",aUrl,aPath];
	else return [NSString stringWithFormat:@"%@/%@",aUrl,aPath];
}

#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];

	[[self undoManager] disableUndoRegistration];
	
 	[self initConnectionHistory];
   
    [self initBasics];
	[self setShipRecords:		[decoder decodeBoolForKey:	  @"shipRecords"]];
	[self setFastGenSetup:		[decoder decodeBoolForKey:	  @"fastGen"]];
	[self setSetPoint:			[decoder decodeDoubleForKey:  @"setPoint"]];
	[self setItemType:			[decoder decodeIntForKey:	  @"itemType"]];
	[self setViewItemName:		[decoder decodeBoolForKey:	  @"viewItemName"]];
	[self setPollTime:			[decoder decodeIntForKey:	  @"pollTime"]];
	[self setIPNumber:			[decoder decodeObjectForKey:  @"IPNumber"]];
	[self setItemTreeRoot:		[decoder decodeObjectForKey:  @"itemTreeRoot"]];
	
	requestCache =				[[decoder decodeObjectForKey: @"requestCache"]retain];
	pollingLookUp =				[[decoder decodeObjectForKey: @"pollingLookUp"]retain];
	[self makeChannelLookup];

	[[self undoManager] enableUndoRegistration];
        
	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];    
	[encoder encodeBool:shipRecords			forKey:@"shipRecords"];
	[encoder encodeBool:fastGenSetup		forKey:@"fastGen"];
	[encoder encodeDouble:setPoint			forKey:@"setPoint"];
	[encoder encodeInt:itemType				forKey:@"itemType"];
	[encoder encodeBool:viewItemName		forKey:@"viewItemName"];
	[encoder encodeInt:pollTime				forKey:@"pollTime"];
 	[encoder encodeObject:IPNumber			forKey:@"IPNumber"];
 	[encoder encodeObject:itemTreeRoot		forKey:@"itemTreeRoot"];
 	[encoder encodeObject:pollingLookUp		forKey:@"pollingLookUp"];
	//only store the part of the requestCache that is polled
	NSMutableDictionary* itemsToStore = [NSMutableDictionary dictionary];
	for(id itemKey in pollingLookUp){
		NSDictionary* topLevelDictionary = [requestCache objectForKey:itemKey];
		[itemsToStore setObject:topLevelDictionary forKey:itemKey];
	}
 	[encoder encodeObject:itemsToStore		forKey:@"requestCache"];
	
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"ORIpeSlowControlDecoderForChannelData",  @"decoder",
								 [NSNumber numberWithLong:channelDataId],   @"dataId",
								 [NSNumber numberWithBool:YES],       @"variable",
								 [NSNumber numberWithLong:-1],        @"length",
								 nil];
    [dataDictionary setObject:aDictionary forKey:@"ChannelData"];
    return dataDictionary;
}

//put out parameters into the header. Called automagically.
- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{    
    NSMutableDictionary* objDictionary = [super addParametersToDictionary:dictionary];
	NSMutableDictionary* itemsToPutInHeader = [NSMutableDictionary dictionary];
	for(id itemKey in pollingLookUp){
		NSDictionary* topLevelDictionary = [requestCache objectForKey:itemKey];
		[itemsToPutInHeader setObject:topLevelDictionary forKey:itemKey];
	}
    [objDictionary setObject:itemsToPutInHeader forKey:@"WatchedItems"];    	
    return objDictionary;
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"IP320"];
}

#pragma mark •••Adc or Bit Processing Protocol
/** This is called once per "processing" cycle and is called at the begin of the process cycle.
  * The process control calls (also in test mode): processIsStarting, multiple times (startProcessCycle, endProcessCycle) , processIsStopping
  * The ORAdcModel calls (not in test mode!):  
  @verbatim
  normal cycle is:
    maxValueForChan:
    minValueForChan:
    getAlarmRangeLow:high:channel:
    convertedValue:    
  @endverbatim
  
  * <br>
  * The protocol ORAdcProcessing is in: ORAdcProcessing.h
  * The protocol ORBitProcessing is in: ORBitProcessing.h
  */
//note that everything called by these routines MUST be threadsafe
- (void) processIsStarting
{
	//called when processing is started. nothing to do for now. 
	//called at the HW polling rate in the process dialog. 
	//For now we just use the local polling
}

- (void)processIsStopping
{
	//called when processing is stopping. nothing to do for now.
}

- (void) startProcessCycle
{
	//called at the HW polling rate in the process dialog. 
	//ignore for now.
}

- (void) endProcessCycle
{
}

- (NSString*) processingTitle
{
    return [NSString stringWithFormat: @"%@-%i",IPE_SLOW_CONTROL_SHORT_NAME,[self uniqueIdNumber]];
}


- (void) setProcessOutput:(int)channel value:(int)value
{
    //nothing to do
}

- (BOOL) processValue:(int)channel
{
	return [self convertedValue:channel]!=0;
}

- (double) convertedValue:(int)channel
{    
	NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
	if(itemKey){
		NSDictionary* topLevelDictionary = [requestCache objectForKey: itemKey];
		NSDictionary* itemDictionary = [topLevelDictionary objectForKey:itemKey];
		if([itemDictionary objectForKey:@"Control"]) return [[itemDictionary objectForKey:@"value"] doubleValue];
		else										 return [[itemDictionary objectForKey:@"Value"] doubleValue];
	}
	return 0; // return something if channel number out of range
}

- (double) maxValueForChan:(int)channel
{
	NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
	if(itemKey){
		NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
		NSDictionary* topLevelDictionary = [requestCache objectForKey: itemKey];
		return [[topLevelDictionary objectForKey:@"HiLimit"] doubleValue];
	}
	return 0; // return something if channel number out of range
}

- (double) lowAlarm:(int)channel
{    
	NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
	if(itemKey){
		NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
		NSDictionary* topLevelDictionary = [requestCache objectForKey: itemKey];
		return [[topLevelDictionary objectForKey:@"LoAlarm"] doubleValue];
	}
	return 0; // return something if channel number out of range
}

- (double) highAlarm:(int)channel
{
	NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
	if(itemKey){
		NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
		NSDictionary* topLevelDictionary = [requestCache objectForKey: itemKey];
		return [[topLevelDictionary objectForKey:@"HiAlarm"] doubleValue];
	}
	return 0; // return something if channel number out of range
}

- (double) minValueForChan:(int)channel
{
	NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
	if(itemKey){
		NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
		NSDictionary* topLevelDictionary = [requestCache objectForKey: itemKey];
		return [[topLevelDictionary objectForKey:@"LoLimit"] doubleValue];
	}
	return 0; // return something if channel number out of range
}

//alarm limits for the processing framework.
- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit  channel:(int)channel
{	
	NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
	if(itemKey){
		NSString* itemKey = [channelLookup objectForKey:[NSNumber numberWithInt:channel]];
		NSDictionary* topLevelDictionary = [requestCache objectForKey: itemKey];
		*theLowLimit  =  [[topLevelDictionary objectForKey:@"LoAlarm"]doubleValue] ;
		*theHighLimit  =  [[topLevelDictionary objectForKey:@"HiAlarm"]doubleValue] ;
	}
}

#pragma mark •••polling
- (void) pollSlowControls
{
	///
	//TODO
	//-----collect requests for groups into one request. The response code should handle the result...
	//TODO
	//
	NSArray* setupOptions = nil;
	if(fastGenSetup){
		setupOptions = [NSArray arrayWithObjects:@"fastgen",nil];
	}
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollSlowControls) object:nil];
	for(id anItemKey in pollingLookUp){
		id topLevelDictionary = [requestCache objectForKey:anItemKey];
		id anItem = [topLevelDictionary objectForKey:anItemKey];
		int aType = [[anItem objectForKey:@"Control"] intValue];
		ORAdeiLoader* aLoader = [ORAdeiLoader loaderWithAdeiHost:[anItem objectForKey:@"URL"] adeiType:aType delegate:self didFinishSelector:@selector(polledItemResult:path:) setupOptions:setupOptions];
		[aLoader requestItem:[anItem objectForKey:@"Path"]];
		[self setPendingRequest:anItemKey];
		[self setTotalRequestCount:totalRequestCount+1];

	}		
	
	if(pollTime)[self performSelector:@selector(pollSlowControls) withObject:nil afterDelay:pollTime];
	
	if(shipRecords) [self shipTheRecords];
}

#pragma mark •••ID Helpers (see OrcaObject)
- (NSString*) identifier
{
    return [NSString stringWithFormat: @"%@-%i",IPE_SLOW_CONTROL_SHORT_NAME,[self uniqueIdNumber]];
}

#pragma mark •••Methods Useful For Scripting
//-------------should use only these methods in scripts---------------------------------
- (void) setUrl:(NSString*)aUrl path:(NSString*)aPath value:(double)aValue
{
	ORAdeiLoader* aLoader = [ORAdeiLoader loaderWithAdeiHost:aUrl adeiType:kControlType delegate:self didFinishSelector:@selector(polledItemResult:path:)];
	[aLoader writeControl:aPath value:aValue];
	[self setPendingRequest:[self itemKey:aUrl :aPath]];
	[self setTotalRequestCount:totalRequestCount+1];
}

- (void) postSensorRequest:(NSString*)aUrl path:(NSString*)aPath
{
	ORAdeiLoader* aLoader;
	aLoader = [ORAdeiLoader loaderWithAdeiHost:aUrl adeiType:kSensorType delegate:self didFinishSelector:@selector(polledItemResult:path:)];
	[aLoader requestItem:aPath];
	[self setPendingRequest:[self itemKey:aUrl :aPath]];
	[self setTotalRequestCount:totalRequestCount+1];
}

- (void) postControlRequest:(NSString*)aUrl path:(NSString*)aPath
{
	ORAdeiLoader* aLoader;
	aLoader = [ORAdeiLoader loaderWithAdeiHost:aUrl adeiType:kControlType delegate:self didFinishSelector:@selector(polledItemResult:path:)];
	[aLoader requestItem:aPath];
	[self setPendingRequest:[self itemKey:aUrl :aPath]];
	[self setTotalRequestCount:totalRequestCount+1];
}

- (void) postControlSetpoint:(NSString*)aUrl path:(NSString*)aPath value:(double)aValue
{
    ORAdeiLoader* aLoader = [ORAdeiLoader loaderWithAdeiHost:aUrl adeiType:kControlType delegate:self didFinishSelector:nil];
    [aLoader writeControl:aPath value:aValue];
    [self setTotalRequestCount:totalRequestCount+1];
}


- (BOOL) requestIsPending:(NSString*)aUrl path:(NSString*)aPath
{
	return [pendingRequests objectForKey:[self itemKey:aUrl:aPath]] != nil;
}

//if the item is part of the itemArray
- (void) writeSetPoint:(int)anIndex value:(double)aValue
{
	//index is NOT channel
	if(anIndex<[pollingLookUp count]){
    NSLog(@"pollingLookUp:\n %@\n",pollingLookUp);
		NSString* itemKey = [pollingLookUp objectAtIndex:anIndex];
		id topLevelDictionary = [requestCache objectForKey:itemKey];
		id anItem = [topLevelDictionary objectForKey:itemKey];
		if([anItem objectForKey:@"Control"]){
			NSString* aUrl  = [anItem objectForKey:@"URL"];
			NSString* aPath = [anItem objectForKey:@"Path"];
			ORAdeiLoader* aLoader = [ORAdeiLoader loaderWithAdeiHost:aUrl adeiType:kControlType delegate:self didFinishSelector:nil];
			[aLoader writeControl:aPath value:aValue];
			[self setTotalRequestCount:totalRequestCount+1];
		}
	}
}

- (double) valueForUrl:(NSString*)aUrl path:(NSString*)aPath
{
	NSString* itemKey = [self itemKey:aUrl:aPath];
	if(itemKey){
		NSDictionary* topLevelDictionary = [requestCache objectForKey: itemKey];
		NSDictionary* itemDictionary = [topLevelDictionary objectForKey:itemKey];
		if([itemDictionary objectForKey:@"Control"]) return [[itemDictionary objectForKey:@"value"] doubleValue];
		else										 return [[itemDictionary objectForKey:@"Value"] doubleValue];
	}
	return 0; // return something if channel number out of range
}
//-------------end of script methods---------------------------------

- (void) histogram:(int)milliSecs
{
	int i = milliSecs;
	if(i>=kResponseTimeHistogramSize)i=kResponseTimeHistogramSize-1;
	histogram[i]++;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlModelHistogramChanged object:self];
}

- (long) dataTimeHist:(int)index
{
	if(index<kResponseTimeHistogramSize)return histogram[index];
	else return 0;
}

- (unsigned) pendingRequestsCount
{
	return [[pendingRequests allKeys] count];
}

- (id) pendingRequest:(id)aKey forIndex:(int)anIndex
{
	if(anIndex < [[pendingRequests allKeys] count]){
		id aKey =  [[pendingRequests allKeys] objectAtIndex:anIndex];
		return aKey;
	}
	else return nil;
}

@end

@implementation ORIpeSlowControlModel (private)

- (NSMutableArray*) insertNode:(id)aNode intoArray:(NSMutableArray*)anArray path:(NSString*)aPath nodeName:(NSString*)nodeName isLeaf:(BOOL)isLeaf
{
	for(id aDictionary in anArray){
		NSString* thisNodesName = [aDictionary objectForKey:@"Name"];
		if(!thisNodesName)thisNodesName = [aDictionary objectForKey:@"name"];
		if([thisNodesName isEqualToString:nodeName]){
			//OK the node is already there.
			if(isLeaf){
				//It's a leaf. Replace the existing entry with the new info
				[aDictionary setObject:aNode forKey:@"Children"];
				return nil;
			}
			else return [aDictionary objectForKey:@"Children"];
		}
	}
	
	if(isLeaf){
		for(id item in aNode){
			[item setObject:[self ipNumberToURL] forKey:@"URL"];
			NSString* leafNodePath = [aPath stringByAppendingPathComponent:[item objectForKey:@"value"]];
			[item setObject:leafNodePath forKey:@"Path"];
		}
		NSMutableDictionary* aDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											nodeName,@"Name",
											[self ipNumberToURL],@"URL",
											aPath,@"Path",
											aNode,@"Children",
											nil];
		[anArray addObject:aDictionary];
		return anArray;
	}
	else {
		//if we get here, there was no entry yet. make one.
		NSMutableArray* newArray = [NSMutableArray array];
		NSMutableDictionary* aDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											nodeName,@"Name",
											aPath,@"Path",
											[self ipNumberToURL],@"URL",
											newArray,@"Children",
											nil];
		[anArray addObject:aDictionary];
		return newArray;
	}
}

- (void) itemTreeResults:(id)result path:(NSString*)aPath
{	
	[self setLastRequest:aPath];
	NSMutableArray* pathComponents;
	if([aPath isEqual:@"/"] || ([aPath length]==0)){
		//this was the root -- we ignore this and start with the servers
		return;
	}
	else pathComponents = [[aPath componentsSeparatedByString:@"/"] mutableCopy];
	
	if(!itemTreeRoot)itemTreeRoot = [[NSMutableArray array] retain];
	
	// paths are of the form "/server/database/group/item". Always the fourth level is the leaf node
	int level = 0;
	NSMutableArray* aNodeArray = itemTreeRoot;
	for(id nodeName in pathComponents){
		aNodeArray = [self insertNode:result 
							intoArray:aNodeArray 
								 path: aPath
							 nodeName:[pathComponents objectAtIndex:level] 
							   isLeaf:level==2];
		if(!aNodeArray)break;
		level++;
	}
	[pathComponents release];
	[[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowItemTreeChanged object:self];
}

- (void) polledItemResult:(id)result path:(NSString*)aPath
{
	//got back some results from pollSlowControls. Store it in the requestCache.
	//requestCache form:
	// Array of Dictionaries of the form:
	// itemKey -> topLevelDictionary whose form is:
	//		itemKey -> thePolledItem from database (another Dictionary) 
	//		"LoAlarm" -> loAlarm Value
	//		"HiAlarm" -> hiAlarm Value
	// ...
	// ...
	//
	for(id resultItem in result){
		NSString* itemKey = [self itemKey:[resultItem objectForKey:@"URL"]:[resultItem objectForKey:@"Path"]];
		id topLevelDictionary = [requestCache objectForKey:itemKey];
		if(!topLevelDictionary){
			//wasn't in the topLevel so we haven't seen this item before. Add it to the cache.
			topLevelDictionary = [self makeTopLevelDictionary];
			[requestCache setObject:topLevelDictionary forKey:itemKey];
		}
		//we only replace the resultItem. leaving the other things in the dictionary (i.e. loAlarm, etc...) alone.
		[topLevelDictionary setObject:resultItem forKey:itemKey];
		[self clearPendingRequest:itemKey];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlItemListChanged object:self];
}

- (void) clearPendingRequest:(NSString*) anItemKey
{
	NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
	int deltaTime = (t - [[pendingRequests objectForKey:anItemKey] doubleValue])*1000;
	[self histogram:deltaTime];
	[pendingRequests removeObjectForKey:anItemKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlPendingRequestsChanged object:self];
	if([pendingRequests count]==0){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkForTimeOuts) object:nil];
		checkingForTimeouts = NO;
	}
}

- (void) setPendingRequest:(NSString*)anItemKey
{
	if(!pendingRequests)pendingRequests = [[NSMutableDictionary dictionary] retain];
	[pendingRequests setObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:anItemKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlPendingRequestsChanged object:self];
	if(!checkingForTimeouts){
		[self performSelector:@selector(checkForTimeOuts) withObject:nil afterDelay:10]; //delay should be parameter
		checkingForTimeouts = YES;
	}
}

- (void) checkForTimeOuts
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkForTimeOuts) object:nil];
	NSTimeInterval theCurrentTime = [NSDate timeIntervalSinceReferenceDate];
	if([pendingRequests count] == 0) return; 
	NSArray* theKeys = [pendingRequests allKeys];
	for(id anItemKey in theKeys){
		//it's a dictionary with one key -- the itemKey that holds the time the request was posted
		NSTimeInterval timePosted = [[pendingRequests objectForKey:anItemKey] doubleValue];
		if(theCurrentTime - timePosted > 10){
			NSLog(@"timeout on %@\n",anItemKey);
			[self setTimeOutCount:[self timeOutCount]+1];
			[self clearPendingRequest:anItemKey];
		}
	}
	[self performSelector:@selector(checkForTimeOuts) withObject:nil afterDelay:10]; //delay should be parameter

}

- (void) shipTheRecords
{
	union {
		float asFloat;
		unsigned long asLong;
	}dataUnion;
	
	if([pollingLookUp count]){
		if([[ORGlobal sharedGlobal] runInProgress]){
			NSMutableData* theData = [NSMutableData dataWithCapacity:256]; //not a hard limit, just a hint to the data obj
			for(id anItemKey in pollingLookUp){
				NSDictionary* topLevelDictionary	= [requestCache objectForKey:anItemKey];
				NSDictionary* itemDictionary		= [topLevelDictionary objectForKey:anItemKey];
				float theValue;
				if([itemDictionary objectForKey:@"Control"]) theValue =  [[itemDictionary objectForKey:@"value"] floatValue];
				else										 theValue =  [[itemDictionary objectForKey:@"Value"] floatValue];
				int channelNumber = [[topLevelDictionary objectForKey:@"ChannelNumber"] intValue];

				NSTimeInterval theTimeStamp =  [self timeFromADEIDate:[itemDictionary objectForKey:@"Date"]];
				unsigned long seconds	 = (unsigned long)theTimeStamp;	  //seconds since 1970
				unsigned long subseconds = (theTimeStamp - seconds)*1000; //milliseconds
				
				unsigned long data[7];
				data[0] = channelDataId | 7;
				data[1] = (([self uniqueIdNumber]&0xf) << 21) | (channelNumber&0xff);
							
				dataUnion.asFloat = theValue;
				data[2] = dataUnion.asLong;
				data[3] = seconds; 
				data[4] = subseconds;
				data[5] = 0; //spare
				data[6] = 0; //spare
				
				[theData appendBytes:data length:7*sizeof(unsigned long)];
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:ORQueueRecordForShippingNotification object:theData];
		}
	}
}

- (NSTimeInterval) timeFromADEIDate:(NSString*)aDate
{
	NSCalendarDate *theDate = [NSCalendarDate dateWithString:aDate calendarFormat:@"%d-%b-%y %H:%M:%S.%F"];
	return [theDate timeIntervalSince1970];
}
- (void) addItemKeyToPollingLookup:(NSString *)anItemKey
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeItemKeyFromPollingLookup:anItemKey];
	[pollingLookUp addObject:anItemKey];
	[self makeChannelLookup];
	[[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlItemListChanged object:self];
}

- (void) removeItemKeyFromPollingLookup:(NSString *)anItemKey
{
    [[[self undoManager] prepareWithInvocationTarget:self] addItemKeyToPollingLookup:anItemKey];
	[pollingLookUp removeObject:anItemKey];
	[self makeChannelLookup];
	[[NSNotificationCenter defaultCenter] postNotificationName:ORIpeSlowControlItemListChanged object:self];
}

@end
