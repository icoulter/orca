//--------------------------------------------------------
// ORRandomPulserController
// Created by Mark  A. Howe on Tue Oct 12 2004
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2004 CENPA, University of Washington. All rights reserved.
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

@interface ORRandomPulserController : OrcaObjectController
{
	IBOutlet NSTextField* rateField;
	IBOutlet NSButton* loadHWButton;
	IBOutlet NSButton* readHWButton;
	IBOutlet NSStepper* rateStepper;
	IBOutlet NSTextField* ampField;
	IBOutlet NSStepper* ampStepper;
    IBOutlet NSButton*	settingLockButton;
	IBOutlet NSMatrix* ttlPulseStateMatrix;
	IBOutlet NSMatrix* negPulseStateMatrix;
}

#pragma mark ***Initialization
-(id) init;
-(void) dealloc;
-(void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;
- (void) pulserRateChanged:(NSNotification*)note;
- (void) pulserAmpChanged:(NSNotification*)note;
- (void) settingsLockChanged:(NSNotification*)aNotification;
- (void) settingsLockChanged:(NSNotification*)aNotification;
- (void) ttlPulseStateChanged:(NSNotification*)note;
- (void) negPulseStateChanged:(NSNotification*)note;

#pragma mark ***Accessors

#pragma mark ***Actions
- (IBAction) ampFieldAction:(id)sender;
- (IBAction) rateAction:(id)sender;
- (IBAction) loadHWAction:(id)sender;
- (IBAction) readHWAction:(id)sender;
- (IBAction) settingLockAction:(id) sender;
- (IBAction) ttlPulseStateMatrixAction:(id)sender;
- (IBAction) negPulseStateMatrixAction:(id)sender;

@end

