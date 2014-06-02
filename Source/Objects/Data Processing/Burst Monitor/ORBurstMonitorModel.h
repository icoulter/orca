//
//  ORBurstMonitorModel.h
//  Orca
//
//  Created by Mark Howe on Mon Nov 18 2002.
//  Copyright (c) 2002 CENPA, University of Washington. All rights reserved.
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


#pragma mark •••Imported Files
#import "ORDataChainObject.h"
#import "ORBaseDecoder.h"
#import "ORDataProcessing.h"

#pragma mark •••Forward Declarations
@class ORDecoder;

@interface ORBurstMonitorModel :  ORDataChainObject <ORDataProcessing>
{

@private

    id					 thePassThruObject;         //cache the object on the other side of the pass thru connection
	id					 theBurstMonitoredObject;	//cache the object on the other side of the BurstMonitor connection
    unsigned short       timeWindow;
    unsigned short       nHit;
    unsigned short       minimumEnergyAllowed;
    unsigned long        shaperID;
    
    NSMutableArray*      queueArray;
    NSMutableDictionary* queueMap;
    NSRecursiveLock*     queueLock;
    NSMutableArray*      emailList;
    unsigned short       numBurstsNeeded;
    NSData*              header;
    ORDecoder*           theDecoder;
    NSMutableDictionary* runUserInfo;
    unsigned short       burstCount;
}

- (id)   init;
- (void) dealloc;

#pragma mark •••Accessors
- (unsigned short) numBurstsNeeded;
- (void) setNumBurstsNeeded:(unsigned short)aNumBurstsNeeded;

- (unsigned short) timeWindow;
- (void) setTimeWindow:(unsigned short)value;

- (void) setNHit:(unsigned short)value;
- (unsigned short) nHit;

- (unsigned short) minimumEnergyAllowed;
- (void) setMinimumEnergyAllowed:(unsigned short)value;

- (NSMutableArray*)      queueArray;
- (NSMutableDictionary*) queueMap;
- (NSMutableArray*)      emailList;
- (void) setEmailList:(NSMutableArray*)aEmailList;
- (void) addAddress:(id)anAddress atIndex:(int)anIndex;
- (void) removeAddressAtIndex:(int) anIndex;
- (void) lockArray;
- (void) unlockArray;
#pragma mark •••Run Methods
- (void) runTaskStarted:(id)userInfo;
- (void) runTaskStopped:(id)userInfo;
- (void) closeOutRun:(id)userInfo;
- (void) processData:(NSArray*)dataArray decoder:(ORDecoder*)aDecoder;
- (void) setRunMode:(int)aMode;

#pragma mark •••EMail
- (void) mailSent:(NSString*)address;
- (void) sendMail:(id)userInfo;
- (NSString*) cleanupAddresses:(NSArray*)aListOfAddresses;

#pragma mark •••Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end

#pragma mark •••External String Definitions
extern NSString* ORBurstMonitorModelNumBurstsNeededChanged;
extern NSString* ORBurstMonitorNameChanged;
extern NSString* ORBurstMonitorTimeWindowChanged;
extern NSString* ORBurstMonitorNHitChanged;
extern NSString* ORBurstMonitorMinimumEnergyAllowedChanged;
extern NSString* ORBurstMonitorQueueChanged;
extern NSString* ORBurstMonitorEmailListChanged;
extern NSString* ORBurstMonitorLock;


@interface ORBurstData : NSObject
{
    NSDate* datePosted;
    NSData* dataRecord;
}
@property (retain) NSDate* datePosted;
@property (retain) NSData* dataRecord;

@end