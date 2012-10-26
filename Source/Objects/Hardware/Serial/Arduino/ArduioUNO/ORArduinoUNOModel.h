//--------------------------------------------------------
// ORArduinoUNOModel
// Created by Mark  A. Howe on Wed 10/17/2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------
#pragma mark •••Imported Files
#import "ORSerialPortWithQueueModel.h"
#import "ORBitProcessing.h"
#import "ORAdcProcessing.h"

#define kNumArduinoUNOAdcChannels	6
#define kNumArduinoUNOPins			14 //first two are serial lines

#define kArduinoInput	0
#define kArduinoOutput  1
#define kArduinoPWM		2

@interface ORArduinoUNOModel : ORSerialPortWithQueueModel <ORBitProcessing,ORAdcProcessing>
{
    @private
		NSMutableData*	inComingData;
		int				pollTime;
		BOOL            delay;
		float			adc[kNumArduinoUNOAdcChannels];
		int				pinType[kNumArduinoUNOPins];
		NSString*       pinName[kNumArduinoUNOPins];
		unsigned char	pwm[kNumArduinoUNOPins];
		BOOL			pinStateOut[kNumArduinoUNOPins];
		BOOL			pinStateIn[kNumArduinoUNOPins];
	
		//process stuff
		unsigned int	oldProcessOutMask;
		unsigned int	processOutMask;
		float             lowLimit[kNumArduinoUNOAdcChannels];
		float             hiLimit[kNumArduinoUNOAdcChannels];
		float             minValue[kNumArduinoUNOAdcChannels];
		float             maxValue[kNumArduinoUNOAdcChannels];
		float             slope[kNumArduinoUNOAdcChannels];
		float             intercept[kNumArduinoUNOAdcChannels];
}

#pragma mark •••Initialization
- (void) dealloc;

#pragma mark •••Accessors
- (int)  pollTime;
- (void) setPollTime:(int)aPollTime;
- (float)  adc:(unsigned short)aChan;
- (void) setAdc:(unsigned short)aChan withValue:(float)aValue;

- (NSString*) pinName:(int)i;
- (void) setPin:(int)i name:(NSString*)aName;

- (unsigned char) pwm:(unsigned short)aPin;
- (void) setPin:(unsigned short)aPin pwm:(unsigned char)aValue;

- (BOOL) pinStateOut:(unsigned short)aPin;
- (void) setPin:(unsigned short)aPin stateOut:(BOOL)aValue;

- (BOOL) pinStateIn:(unsigned short)aPin;
- (void) setPin:(unsigned short)aPin stateIn:(BOOL)aValue;

- (unsigned char) pinType:(unsigned short)aPin;
- (void) setPin:(unsigned short)aPin type:(unsigned char)aType;

- (unsigned char) pwm:(unsigned short)aPin;
- (void) setPin:(unsigned short)aPin pwm:(unsigned char)aValue;
- (BOOL) validForPwm:(unsigned short)aPin;

- (unsigned int) inputMask;

- (float) lowLimit:(int)i;
- (void)  setLowLimit:(int)i value:(float)aValue;
- (float) hiLimit:(int)i;
- (void)  setHiLimit:(int)i value:(float)aValue;
- (float) slope:(int)i;
- (void)  setSlope:(int)i value:(float)aValue;
- (float) intercept:(int)i;
- (void)  setIntercept:(int)i value:(float)aValue;
- (float) minValue:(int)i;
- (void)  setMinValue:(int)i value:(float)aValue;
- (float) maxValue:(int)i;
- (void)  setMaxValue:(int)i value:(float)aValue;
- (int) numberCommandsInQueue;

#pragma mark •••Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

#pragma mark •••Mark the Common Script Methods
- (void) commonScriptMethodSectionBegin;
- (void) commonScriptMethodSectionEnd;

#pragma mark •••Port Methods
- (void) dataReceived:(NSNotification*)note;

#pragma mark •••HW Methods
- (void) updateAll;
- (void) initHardware;
- (void) writeOutput:(unsigned short) aPin state:(BOOL)aState;
- (void) writeAllOutputs:(unsigned short)aMask;
- (void) readAdcValues;
- (void) readInputPins;

#pragma mark •••Adc Processing Protocol
- (void) processIsStarting;
- (void) processIsStopping; 
- (void) startProcessCycle;
- (void) endProcessCycle;
- (BOOL) processValue:(int)channel;
- (void) setProcessOutput:(int)channel value:(int)value;
- (NSString*) processingTitle;
@end

extern NSString* ORArduinoUNOLock;
extern NSString* ORArduinoUNOModelPollTimeChanged;
extern NSString* ORArduinoUNOModelAdcChanged;
extern NSString* ORArduinoUNOPinTypeChanged;
extern NSString* ORArduinoUNOPinStateInChanged;
extern NSString* ORArduinoUNOPinStateOutChanged;
extern NSString* ORArduinoUNOPwmChanged;
extern NSString* ORArduinoUNOPinNameChanged;
extern NSString* ORArduinoUNOHiLimitChanged;
extern NSString* ORArduinoUNOLowLimitChanged;
extern NSString* ORArduinoUNOSlopeChanged;
extern NSString* ORArduinoUNOInterceptChanged;
extern NSString* ORArduinoUNOMinValueChanged;
extern NSString* ORArduinoUNOMaxValueChanged;