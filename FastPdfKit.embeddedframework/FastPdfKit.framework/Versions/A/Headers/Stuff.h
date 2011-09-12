/*
 *  Stuff.h
 *  OffscreenRendererTest
 *
 *  Created by Nicolò Tosi on 4/21/10.
 *  Copyright 2010 MobFarm S.r.l. All rights reserved.
 *
 */

#define ORIENTATION_PORTRAIT 0
#define ORIENTATION_LANDSCAPE 1

#define DETAIL_POPIN_DELAY 0.15

#define MF_COCOA_RELEASE(x) [(x)release],(x)=nil
#define MF_C_FREE(x)\
if((x)!=NULL) {		\
free((x)),(x)=NULL; \
}					\

#define MF_BUNDLED_BUNDLE(x) [NSBundle bundleWithPath:[[NSBundle mainBundle]pathForResource:(x) ofType:@"bundle"]]
#define MF_BUNDLED_RESOURCE(x,k,z) [(MF_BUNDLED_BUNDLE(x))pathForResource:(k) ofType:(z)]

#define PRINT_TRANSFORM(c,t) NSLog(@"%@ - [%.3f %.3f %.3f %.3f %.3f %.3f]",(c),(t).a,(t).b,(t).c,(t).d,(t).tx,(t).ty)
#define PRINT_RECT(c,r) NSLog(@"%@ - (%.3f, %.3f)[%.3f x %.3f]",(c),(r).origin.x,(r).origin.y,(r).size.width,(r).size.height)
#define PRINT_SIZE(c,s) NSLog(@"%@ - (%.3f, %.3f)",(c),(s).width,(s).height)

/**
 When the lead property of the MFDocumentViewController is set to MFDocumentLeadLeft, the odd numbered page is shown
 on the left side of the view. MFDocumentLeadRight move the odd page on the right, and this should be the default behaviour
 when dealing with books or magazines.
 */
enum MFDocumentLead {
	MFDocumentLeadLeft = 0,
	MFDocumentLeadRight = 1
};
typedef NSUInteger MFDocumentLead;

/**
 Pretty much self explanatory: when the mode property of the MFDocumentViewController is set to MFDocumentModeSingle, a single
 page is drawn on the view. MFDocumentModeDouble display two pages side-by-side.
 */
enum MFDocumentMode {
	MFDocumentModeSingle = 1,
	MFDocumentModeDouble = 2,
    MFDocumentModeOverflow = 3
};
typedef NSUInteger MFDocumentMode;

/**
 Set the default mode to automatically adopt upon rotation.
 */
enum MFDocumentAutoMode {
    MFDocumentAutoModeNone = 0,
    MFDocumentAutoModeSingle = 1,
    MFDocumentAutoModeDouble = 2,
    MFDocumentAutoModeOverflow = 3
};
typedef NSUInteger MFDocumentAutoMode;

/**
 MFDocumentDirectionL2R is the standard for western magazine and books. Set the direction property of MFDocumentViewController
 to MFDocumentDirectionR2L if you want to display document likes manga.
 */
enum MFDocumentDirection {
	MFDocumentDirectionL2R = 0,
	MFDocumentDirectionR2L = 1
};
typedef NSUInteger MFDocumentDirection;

#define IS_DEVICE_PAD ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


static inline int normalize_angle(int degs) {
	while( degs < 0) {
		degs+=360;
	}
	while(degs >= 360) {
		degs-=360;
	}
	return degs;
}

static inline float f_normalize_angle(float degs) {
	while (degs < 0) {
		degs+=360.0;
	} 
	while(degs >= 360) {
		degs-=360.0;
	}
	return degs;
}


static inline NSUInteger pageForDirection(NSUInteger pageNumber, NSUInteger numberOfPages, MFDocumentDirection direction) {
	
	if(direction == MFDocumentDirectionL2R) {
		return pageNumber;
	} else if (direction == MFDocumentDirectionR2L) {
		return numberOfPages-pageNumber+1;
	} else {
		return 0;
	}
	
}

static inline float radiansToDegrees(float rads) {
    return rads * 180.0f / M_PI;
}

static inline float degreesToRadians(float degs) {
	//return ((fmod(degs, 360.0)) / 180.0) * M_PI;
    return degs * M_PI / 180.0f;
}

static inline NSInteger pageNumberForPosition(NSInteger position) {
	return position+1;
}

static inline CGSize sizeForContent(NSInteger numberOfPages, CGSize pageSize) {
	CGFloat contentHeight = pageSize.height;
	CGFloat contentWidth = numberOfPages * pageSize.width;
	return CGSizeMake(contentWidth, contentHeight);
}

static inline NSUInteger numberOfPositions(NSUInteger numberOfPages, MFDocumentMode pagesForPositions, MFDocumentLead lead) {
	
	int nrOfPos = 0;
	if(pagesForPositions == MFDocumentModeSingle || pagesForPositions == MFDocumentModeOverflow){
		
		nrOfPos = numberOfPages;
		
	} else if (pagesForPositions == MFDocumentModeDouble) {
		
		if(lead == MFDocumentLeadLeft) {
			
			nrOfPos = ceil((double)numberOfPages*0.5);
			
		} else if (lead == MFDocumentLeadRight) {
			nrOfPos = ceil(((double)numberOfPages+1.0)*0.5); 
		}
	}
	return nrOfPos;
}

static inline NSInteger positionForPage(NSUInteger page, MFDocumentMode mode, MFDocumentLead lead, MFDocumentDirection direction, NSUInteger maxPages) {
	int pos = 0;
	
	if(direction == MFDocumentDirectionL2R) {
		// Page will remain the same
	} else if (direction == MFDocumentDirectionR2L) {
		page = maxPages-page+1;
	}
	
	if(mode == MFDocumentModeSingle || mode == MFDocumentModeOverflow) {
		pos = page-1;
	} else if (mode == MFDocumentModeDouble) {
		if(lead == MFDocumentLeadLeft) {
			pos = (ceil((double)page * 0.5))-1;
		} else if (lead == MFDocumentLeadRight) {
			pos = (floor((double)page * 0.5));
		}
	}
	return pos;
}


static inline NSUInteger leftPageForPosition(NSInteger position, MFDocumentMode mode, MFDocumentLead lead, MFDocumentDirection direction, NSUInteger maxPages) {
	
	int page = 0;
	
	if(mode == MFDocumentModeSingle || mode == MFDocumentModeOverflow) {
		page = position+1;
	} else if (mode == MFDocumentModeDouble) {
		
		if(lead == MFDocumentLeadLeft) {
			page = position * 2 + 1;
		} else if (lead == MFDocumentLeadRight) {
			page = position * 2 + 0;
		}
	}
	
	if(page < 0 || page > maxPages) {
		page = 0;
	}
	
	if(direction == MFDocumentDirectionR2L) {
		page = maxPages-page+1;
	}
	
	return page;
}

static inline NSUInteger rightPageForPosition(NSInteger position, MFDocumentMode mode, MFDocumentLead lead, MFDocumentDirection direction, NSUInteger maxPages) {
	
	int page = 0;
	
	if(mode == MFDocumentModeSingle || mode == MFDocumentModeOverflow) {
		page = 0;
	} else if (mode == MFDocumentModeDouble) {
		
	if(lead == MFDocumentLeadLeft) {
		page = position * 2 + 2;
	} else if (lead == MFDocumentLeadRight) {
		page = position * 2 + 1;
	}
	}
	
	if(page < 0 || page > maxPages) {
		page = 0;
	}
	
	if(direction == MFDocumentDirectionR2L) {
		page = maxPages-page+1;
	}
	
	return page;
}

// Return the smallest pages displayed, ranging between 1 and maxPages
static inline NSUInteger pageForPosition(NSInteger position, MFDocumentMode mode, MFDocumentLead lead, MFDocumentDirection direction, NSUInteger maxPages) {
	
	int page = 0;
	
	if(mode == MFDocumentModeSingle || mode == MFDocumentModeOverflow) {
		page = position+1;
	} else if (mode == MFDocumentModeDouble) {
		if(lead == MFDocumentLeadLeft) {
			page = position * 2 + 1;
		} else if (lead == MFDocumentLeadRight) {
			page = position * 2;
		}
	}
 	
	if(page <= 0)
		page = 1;
	if(page > maxPages)
		page = maxPages;
	
	if(direction == MFDocumentDirectionR2L) {
		page = maxPages-page+1;
	}
	
	return page;
	
}

static inline CGRect rectForPosition(NSInteger position, CGSize pageSize) {
	
	return CGRectMake(position * pageSize.width, 0, pageSize.width, pageSize.height);
	
}

