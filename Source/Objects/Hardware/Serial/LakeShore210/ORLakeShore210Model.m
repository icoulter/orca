//--------------------------------------------------------
// ORLakeShore210Model
// Created by Mark  A. Howe on Fri Jul 22 2005
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

#import "ORLakeShore210Model.h"
#import "ORSerialPort.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORTimeRate.h"

#pragma mark ***External Strings
NSString* ORLakeShore210ModelShipTemperaturesChanged = @"ORLakeShore210ModelShipTemperaturesChanged";
NSString* ORLakeShore210ModelDegreesInKelvinChanged = @"ORLakeShore210ModelDegreesInKelvinChanged";
NSString* ORLakeShore210ModelPollTimeChanged	= @"ORLakeShore210ModelPollTimeChanged";
NSString* ORLakeShore210ModelSerialPortChanged = @"ORLakeShore210ModelSerialPortChanged";
NSString* ORLakeShore210ModelPortNameChanged   = @"ORLakeShore210ModelPortNameChanged";
NSString* ORLakeShore210ModelPortStateChanged  = @"ORLakeShore210ModelPortStateChanged";
NSString* ORLakeShore210TempArrayChanged	   = @"ORLakeShore210TempArrayChanged";
NSString* ORLakeShore210TempChanged			   = @"ORLakeShore210TempChanged";

NSString* ORLakeShore210Lock = @"ORLakeShore210Lock";

@interface ORLakeShore210Model (private)
- (void) runStarted:(NSNotification*)aNote;
- (void) runStopped:(NSNotification*)aNote;
- (void) timeout;
- (void) processOneCommandFromQueue;
- (void) process_xrdg_response:(NSString*)theResponse args:(NSArray*)cmdArgs;
@end

@implementation ORLakeShore210Model
- (id) init
{
	self = [super init];
    [self registerNotificationObservers];
	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [buffer release];
	[cmdQueue release];
	[lastRequest release];
    [portName release];
    if([serialPort isOpen]){
        [serialPort close];
    }
    [serialPort release];
	int i;
	for(i=0;i<8;i++){
		[timeRates[i] release];
	}

	[super dealloc];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"LakeShore210.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORLakeShore210Controller"];
}

- (NSString*) helpURL
{
	return @"RS232/LakeShore_210.html";
}

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];

    [notifyCenter addObserver : self
                     selector : @selector(dataReceived:)
                         name : ORSerialPortDataReceived
                       object : nil];

    [notifyCenter addObserver: self
                     selector: @selector(runStarted:)
                         name: ORRunStartedNotification
                       object: nil];
    
    [notifyCenter addObserver: self
                     selector: @selector(runStopped:)
                         name: ORRunStoppedNotification
                       object: nil];

}

- (void) dataReceived:(NSNotification*)note
{
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
        NSString* theString = [[[[NSString alloc] initWithData:[[note userInfo] objectForKey:@"data"] 
												      encoding:NSASCIIStringEncoding] autorelease] uppercaseString];

		//the serial port may break the data up into small chunks, so we have to accumulate the chunks until
		//we get a full piece.
        theString = [[theString componentsSeparatedByString:@"\n"] componentsJoinedByString:@""];
        if(!buffer)buffer = [[NSMutableString string] retain];
        [buffer appendString:theString];					
		
        do {
            NSRange lineRange = [buffer rangeOfString:@"\r"];
            if(lineRange.location!= NSNotFound){
                NSMutableString* theResponse = [[[buffer substringToIndex:lineRange.location+1] mutableCopy] autorelease];
                [buffer deleteCharactersInRange:NSMakeRange(0,lineRange.location+1)];      //take the cmd out of the buffer
				NSArray* lastCmdParts = [lastRequest componentsSeparatedByString:@" "];
				NSString* lastCmd = [lastCmdParts objectAtIndex:0];

				if([lastCmd isEqualToString: @"KRDG?"])      [self process_xrdg_response:theResponse args:lastCmdParts];
				else if([lastCmd isEqualToString: @"CRDG?"]) [self process_xrdg_response:theResponse args:lastCmdParts];
		
				[self setLastRequest:nil];			 //clear the last request
				[self processOneCommandFromQueue];	 //do the next command in the queue
            }
        } while([buffer rangeOfString:@"\r"].location!= NSNotFound);
	}
}


- (void) shipTemps
{
    if([[ORGlobal sharedGlobal] runInProgress]){
		
		unsigned long data[18];
		data[0] = dataId | 18;
		data[1] = ((degreesInKelvin&0x1)<<16) | ([self uniqueIdNumber]&0x0000fffff);
		
		union {
			float asFloat;
			unsigned long asLong;
		}theData;
		int index = 2;
		int i;
		for(i=0;i<8;i++){
			theData.asFloat = temp[i];
			data[index] = theData.asLong;
			index++;
			
			data[index] = timeMeasured[i];
			index++;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:ORQueueRecordForShippingNotification 
															object:[NSData dataWithBytes:data length:sizeof(long)*18]];
	}
}


#pragma mark ***Accessors
- (ORTimeRate*)timeRate:(int)index
{
	return timeRates[index];
}

- (BOOL) shipTemperatures
{
    return shipTemperatures;
}

- (void) setShipTemperatures:(BOOL)aShipTemperatures
{
    [[[self undoManager] prepareWithInvocationTarget:self] setShipTemperatures:shipTemperatures];
    
    shipTemperatures = aShipTemperatures;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORLakeShore210ModelShipTemperaturesChanged object:self];
}

- (BOOL) degreesInKelvin
{
    return degreesInKelvin;
}

- (void) setDegreesInKelvin:(BOOL)aDegreesInKelvin
{
    [[[self undoManager] prepareWithInvocationTarget:self] setDegreesInKelvin:degreesInKelvin];
    
    degreesInKelvin = aDegreesInKelvin;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORLakeShore210ModelDegreesInKelvinChanged object:self];
}

- (int) pollTime
{
    return pollTime;
}

- (void) setPollTime:(int)aPollTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollTime:pollTime];
    pollTime = aPollTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORLakeShore210ModelPollTimeChanged object:self];

	if(pollTime){
		[self performSelector:@selector(pollTemps) withObject:nil afterDelay:2];
	}
	else {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollTemps) object:nil];
	}
}

- (void) pollTemps
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollTemps) object:nil];
	[self readTemps];

	[self performSelector:@selector(pollTemps) withObject:nil afterDelay:pollTime];
}

- (float) temp:(int)index
{
	if(index>=0 && index<8)return temp[index];
	else return 0.0;
}

- (unsigned long) timeMeasured:(int)index
{
	if(index>=0 && index<8)return timeMeasured[index];
	else return 0;
}

- (void) setTemp:(int)index value:(float)aValue;
{
	if(index>=0 && index<8){
		temp[index] = aValue;
		//get the time(UT!)
		time_t	ut_Time;
		time(&ut_Time);
		//struct tm* theTimeGMTAsStruct = gmtime(&theTime);
		timeMeasured[index] = ut_Time;

		[[NSNotificationCenter defaultCenter] postNotificationName:ORLakeShore210TempChanged 
															object:self 
														userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"Index"]];

		if(timeRates[index] == nil) timeRates[index] = [[ORTimeRate alloc] init];
		[timeRates[index] addDataToTimeAverage:aValue];

	}
}

- (NSString*) lastRequest
{
	return lastRequest;
}

- (void) setLastRequest:(NSString*)aRequest
{
	[lastRequest autorelease];
	lastRequest = [aRequest copy];    
}

- (BOOL) portWasOpen
{
    return portWasOpen;
}

- (void) setPortWasOpen:(BOOL)aPortWasOpen
{
    portWasOpen = aPortWasOpen;
}

- (NSString*) portName
{
    return portName;
}

- (void) setPortName:(NSString*)aPortName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPortName:portName];
    
    if(![aPortName isEqualToString:portName]){
        [portName autorelease];
        portName = [aPortName copy];    

        BOOL valid = NO;
        NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
        ORSerialPort *aPort;
        while (aPort = [enumerator nextObject]) {
            if([portName isEqualToString:[aPort name]]){
                [self setSerialPort:aPort];
                if(portWasOpen){
                    [self openPort:YES];
                 }
                valid = YES;
                break;
            }
        } 
        if(!valid){
            [self setSerialPort:nil];
        }       
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ORLakeShore210ModelPortNameChanged object:self];
}

- (ORSerialPort*) serialPort
{
    return serialPort;
}

- (void) setSerialPort:(ORSerialPort*)aSerialPort
{
    [aSerialPort retain];
    [serialPort release];
    serialPort = aSerialPort;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORLakeShore210ModelSerialPortChanged object:self];
}

- (void) openPort:(BOOL)state
{
    if(state) {
		[serialPort setSpeed:9600];
		[serialPort setParityOdd];
		[serialPort setStopBits2:1];
		[serialPort setDataBits:7];
        [serialPort open];
    }
    else      [serialPort close];
    portWasOpen = [serialPort isOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORLakeShore210ModelPortStateChanged object:self];
    
}


#pragma mark ***Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setShipTemperatures:[decoder decodeBoolForKey:@"ORLakeShore210ModelShipTemperatures"]];
	[self setDegreesInKelvin:[decoder decodeBoolForKey:@"ORLakeShore210ModelDegreesInKelvin"]];
	[self setPollTime:[decoder decodeIntForKey:@"ORLakeShore210ModelPollTime"]];
	[self setPortWasOpen:[decoder decodeBoolForKey:@"ORLakeShore210ModelPortWasOpen"]];
    [self setPortName:[decoder decodeObjectForKey: @"portName"]];
	[[self undoManager] enableUndoRegistration];
	int i;
	for(i=0;i<8;i++)timeRates[i] = [[ORTimeRate alloc] init];

    [self registerNotificationObservers];

	return self;
}
- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeBool:shipTemperatures forKey:@"ORLakeShore210ModelShipTemperatures"];
    [encoder encodeBool:degreesInKelvin forKey:@"ORLakeShore210ModelDegreesInKelvin"];
    [encoder encodeInt:pollTime forKey:@"ORLakeShore210ModelPollTime"];
    [encoder encodeBool:portWasOpen forKey:@"ORLakeShore210ModelPortWasOpen"];
    [encoder encodeObject:portName forKey: @"portName"];
}

#pragma mark *** Commands
- (void) addCmdToQueue:(NSString*)aCmd
{
    if([serialPort isOpen]){ 
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:aCmd];
		if(!lastRequest){
			[self processOneCommandFromQueue];
		}
	}
}

- (void) readTemps
{
	if(degreesInKelvin) [self addCmdToQueue:@"KRDG? 0"];
	else				[self addCmdToQueue:@"CRDG? 0"];
}

#pragma mark ***Data Records
- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherLakeShore210
{
    [self setDataId:[anotherLakeShore210 dataId]];
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"LakeShore210Model"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"ORLakeShore210DecoderForTemperature",@"decoder",
        [NSNumber numberWithLong:dataId],   @"dataId",
        [NSNumber numberWithBool:NO],       @"variable",
        [NSNumber numberWithLong:18],       @"length",
        nil];
    [dataDictionary setObject:aDictionary forKey:@"Temperatures"];
    
    return dataDictionary;
}

@end

@implementation ORLakeShore210Model (private)
- (void) runStarted:(NSNotification*)aNote
{
}

- (void) runStopped:(NSNotification*)aNote
{
}

- (void) timeout
{
	NSLogError(@"Lake Shore 210",@"command timeout",nil);
	[self setLastRequest:nil];
	[self processOneCommandFromQueue];	 //do the next command in the queue
}

- (void) processOneCommandFromQueue
{
	if([cmdQueue count] == 0) return;
	NSString* aCmd = [[[cmdQueue objectAtIndex:0] retain] autorelease];
	[cmdQueue removeObjectAtIndex:0];
	
	if([aCmd rangeOfString:@"?"].location != NSNotFound){
		[self setLastRequest:aCmd];
		[self performSelector:@selector(timeout) withObject:nil afterDelay:3];
	}
	if(![aCmd hasSuffix:@"\r\n"]) aCmd = [aCmd stringByAppendingString:@"\r\n"];
	[serialPort writeString:aCmd];
	if(!lastRequest){
		[self performSelector:@selector(processOneCommandFromQueue) withObject:nil afterDelay:.01];
	}
}

- (void) process_xrdg_response:(NSString*)theResponse args:(NSArray*)cmdArgs
{
	NSArray* t = [theResponse componentsSeparatedByString:@","];
	int i;
	for(i=0;i<[t count];i++){
		[self setTemp:i value:[[t objectAtIndex:i] floatValue]];
	}	
	if(shipTemperatures) [self shipTemps];
}

@end