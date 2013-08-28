/*
 *  MJD.h
 *  Orca
 *
 *  Created by Mark Howe on 08/27/13.
 *  Copyright 2013 ENAP, University of North Carolina. All rights reserved.
 *
 */
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina at the Experimental Nuclear and Astroparticle Physics
//(ENAP) group sponsored in part by the United States
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------
#ifndef __MJD_H__
#define __MJD_H__

#include "MJDCmds.h"
void processMJDCommand(SBC_Packet* aPacket);
void readPreAmpAdcs(SBC_Packet* inputPacket);
void singleAuxIO(SBC_Packet* aPacket);
uint32_t writeAuxIOSPI(uint32_t baseAddress,uint32_t spiData);

#endif // __SNO_H__