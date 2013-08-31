/*
 *  mfprofile.h
 *  FastPDFKitTest
 *
 *  Created by Nicolò Tosi on 2/3/11.
 *  Copyright 2011 com.mobfarm. All rights reserved.
 *
 */

#ifndef _MFPROFILE_H_
#define _MFPROFILE_H_

#define OP_Td 0
#define OP_TD 1
#define OP_Tm 2
#define OP_Tstar 3
#define OP_TJ 4

/*
 This is an experimental feature.
 Setting different values in the profile array will allow the extraction and search procedures to behave differently when
 specific pdf operator are found when parsing the document.
 */
 
typedef struct MFProfile {
	
	/// Td, TD, Tm, Tstar
	// 0 - do nothing (strings will be appended).
	// 1 - add space with trimm
	// 2 - add new line
	// Example:
	// The array {1,2,1,0} will cause the Td operator to add a space with trim, TD to add a new line, Tm to act like Td, and Tstar to do nothing.
	
	unsigned int fpdfk_xtr_policy[5];
	
	// Td, TD, Tm, Tstar
	// 0 - do nothing
	// 1 - reset check
	// 2 - reset check and add space
	// 3 - add space
	// Example:
	// The array {0,1,3,2} will cause the search to just use the string passed after Td operator as a continuation of the string already checked, then to reset the check before continue on TD, to reset the check and add a space before taking in consideration the text passed after Tm, and just add a space when T* is encountered.
	
	unsigned int fpdfk_src_policy[5];
	
} MFProfile;

void initProfile(MFProfile * profile);
void initProfileWithSettings(MFProfile * profile, int xtr0, int xtr1, int xtr2, int xtr3, int xtr4, int src0, int src1, int src2, int src3, int src4);


#endif