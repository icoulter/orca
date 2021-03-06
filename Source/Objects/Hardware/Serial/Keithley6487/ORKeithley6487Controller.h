//--------------------------------------------------------
// ORKeithley6487Controller
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

@class ORCompositeTimeLineView;

@interface ORKeithley6487Controller : OrcaObjectController
{
    IBOutlet NSTextField*   lockDocField;
	IBOutlet NSButton*		shipCurrentButton;
    IBOutlet NSButton*      lockButton;
    IBOutlet NSTextField*   portStateField;
    IBOutlet NSPopUpButton* portListPopup;
    IBOutlet NSPopUpButton* pollTimePopup;
    IBOutlet NSButton*      openPortButton;
    IBOutlet NSButton*      readCurrentButton;
    IBOutlet NSTextField*   currentField;
    IBOutlet NSTextField*   timeField;
	IBOutlet ORCompositeTimeLineView*    plotter0;
}

#pragma mark ***Initialization
- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ***Interface Management
- (void) updateTimePlot:(NSNotification*)aNotification;
- (void) scaleAction:(NSNotification*)aNotification;
- (void) shipCurrentChanged:(NSNotification*)aNotification;
- (void) lockChanged:(NSNotification*)aNotification;
- (void) portNameChanged:(NSNotification*)aNotification;
- (void) portStateChanged:(NSNotification*)aNotification;
- (void) currentChanged:(NSNotification*)aNotification;
- (void) pollTimeChanged:(NSNotification*)aNotification;
- (void) miscAttributesChanged:(NSNotification*)aNotification;
- (void) scaleAction:(NSNotification*)aNotification;

#pragma mark ***Actions
- (IBAction) shipCurrentAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) portListAction:(id) sender;
- (IBAction) openPortAction:(id)sender;
- (IBAction) readCurrentAction:(id)sender;
- (IBAction) pollTimeAction:(id)sender;

@end


