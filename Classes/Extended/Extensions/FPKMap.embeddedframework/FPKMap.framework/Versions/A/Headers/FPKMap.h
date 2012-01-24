//
//  FPKMap.h
//  Overlay
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <MapKit/MapKit.h>

/**
This Extension is useful to place a Google Map over the page.

## Usage

* Prefix: **map://**
* Import: **#import <FPKMap/FPKMap.h>**
* String: **@"FPKMap"**

### Prefix

	map://

### Resources and Parameters

* **hybrid** or **satellite** or **standard**
	* *lat* = **DOUBLE** latitude
	* *lon* = **DOUBLE** longitude
	* *latd* = **FLOAT** latitude span
	* *lond* = **FLOAT** longitude span
	* *pinlat* = **DOUBLE** pin latitude *(optional)*
	* *pinlon* = **DOUBLE** pin longitude *(optional)*
	* *pintitle* = **STRING** pin title *(optional)*
	* *pinsub* = **STRING** pin subtitle *(optional)*
	* *pincolor* = **STRING** *red* or *purple* or *green* pin color *(optional)*
	* *user* = **BOOL** show the user position *(optional)*

### Sample url

	map://hybrid?lat=45.436587&lon=12.334042&latd=0.035594&lond=0.07493&pinlat=45.438113&pinlon=12.335908&pintitle=Rialto%20Bridge&pinsub=on%20the%20Grand%20Canal&pincolor=red&user=YES

*/

@interface FPKMap : UIView <FPKView, MKMapViewDelegate>{
    CGRect _rect;
}
@end
