//--------------------------------------------------------
// ORVXMModel
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

@class ORSerialPort;
@class ORVXMMotor;
@class ORVXMMotorCmd;

#define kNumVXMMotors  4

@interface ORVXMModel : OrcaObject
{
    @private
		NSMutableArray*	motors;
        NSString*       portName;
        BOOL            portWasOpen;
        ORSerialPort*   serialPort;
        unsigned long	dataId;
		BOOL			forceResetQueryMaskOnce;
		BOOL			repeatQuery;
        int             motorQueryMask;
		NSMutableArray* cmdQueue;
		BOOL			displayRaw;
		int				syncWithRun;
		BOOL			repeatCmds;
		int				repeatCount;
		BOOL			stopRunWhenDone;
		int				cmdIndex;
		int				numTimesToRepeat;
		BOOL			allGoingHome;
		BOOL			abortAllRepeats;
        BOOL            shipRecords;
        NSString*       cmdFile;

}

#pragma mark ***Initialization
- (id)   init;
- (void) dealloc;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) dataReceived:(NSNotification*)note;

#pragma mark ***Accessors
- (void) saveCmdList;
- (NSString*) cmdFile;
- (void) setCmdFile:(NSString*)aFileName;
- (BOOL) shipRecords;
- (void) setShipRecords:(BOOL)aShipRecords;
- (BOOL) allGoingHome;
- (void) setAllGoingHome:(BOOL)aState;
- (int) numTimesToRepeat;
- (void) setNumTimesToRepeat:(int)aNumTimesToRepeat;
- (int) cmdIndex;
- (void) setCmdIndex:(int)aCmdIndex;
- (BOOL) stopRunWhenDone;
- (void) setStopRunWhenDone:(BOOL)aStopRunWhenDone;
- (int) repeatCount;
- (void) setRepeatCount:(int)aRepeatCount;
- (BOOL) repeatCmds;
- (void) setRepeatCmds:(BOOL)aRepeatCmds;
- (int) syncWithRun;
- (void) setSyncWithRun:(int)aSyncWithRun;
- (BOOL) displayRaw;
- (void) setDisplayRaw:(BOOL)aDisplayRaw;
- (NSArray*) motors;
- (ORVXMMotor*) motor:(int)aMotor;
- (ORSerialPort*) serialPort;
- (void) setSerialPort:(ORSerialPort*)aSerialPort;
- (BOOL) portWasOpen;
- (void) setPortWasOpen:(BOOL)aPortWasOpen;
- (NSString*) portName;
- (void) setPortName:(NSString*)aPortName;
- (void) openPort:(BOOL)state;

#pragma mark ***Data Records
- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (NSDictionary*) dataRecordDescription;
- (unsigned long) dataId;
- (void) setDataId: (unsigned long) DataId;
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherVXM;
- (void) shipMotorState:(int)aMotorIndex;
- (unsigned)  cmdQueueCount;
- (NSString*) cmdQueueCommand:(int)index;
- (NSString*) cmdQueueDescription:(int)index;

#pragma mark ***Motor Commands
- (void) manualStart;
- (void) removeAllCmds;
- (void) startRepeatingPositionQueries;
- (void) stopPositionQueries;
- (void) queryPosition;
- (void) queryPositionOnce;
- (void) goHomeAll;
- (void) move:(int)motorIndex to:(float)aPosition speed:(int)aSpeed;
- (void) move:(int)motorIndex dx:(float)aPosition;
- (void) move:(int)motorIndex dx:(float)aPosition speed:(int)aSpeed;
- (void) goHome:(int)motorIndex speed:(int)aSpeed;
- (void) stopAllMotion;
- (void) goToNexCommand;
- (void) addCmdFromTableFor:(int)aMotorIndex;

#pragma mark ***Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end

extern NSString* ORVXMModelCmdFileChanged;
extern NSString* ORVXMModelShipRecordsChanged;
extern NSString* ORVXMModelAllGoingHomeChanged;
extern NSString* ORVXMModelNumTimesToRepeatChanged;
extern NSString* ORVXMModelCmdIndexChanged;
extern NSString* ORVXMModelStopRunWhenDoneChanged;
extern NSString* ORVXMModelRepeatCountChanged;
extern NSString* ORVXMModelRepeatCmdsChanged;
extern NSString* ORVXMModelSyncWithRunChanged;
extern NSString* ORVXMModelDisplayRawChanged;
extern NSString* ORVXMModelSerialPortChanged;
extern NSString* ORVXMLock;
extern NSString* ORVXMModelPortNameChanged;
extern NSString* ORVXMModelPortStateChanged;
extern NSString* ORVXMModelCmdQueueChanged;

@interface ORVXMMotorCmd : NSObject
{
	BOOL waitToSendNextCmd;
	NSString* cmd;
	NSString* description;
}

@property (nonatomic,assign) BOOL waitToSendNextCmd;
@property (nonatomic,retain) NSString* cmd;
@property (nonatomic,retain) NSString* description;
@end
