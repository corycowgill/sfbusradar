/*Copyright (C) 2011 by Cory Cowgill

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.*/
public with sharing class MUNIGeoLocation
{
	public String radiusValue {get;set;}
	public List<SelectOption> radiusOptions {get;set;}
	public List<MUNI_Stop_Location__c> insertLocs {get;set;}
	public List<String> colors = new List<String>{'red-dot.png','green-dot.png','blue-dot.png','yellow-dot.png','pink-dot.png','purple-dot.png','orange-dot.png'};
	public Map<String,String> busColorMap {get;set;}
	public boolean testMode = false;
	
	//Bounding Box Coordinates
	public decimal bottomLat {get;set;}
	public decimal topLat {get;set;}
	public decimal topLong {get;set;}
	public decimal bottomLong {get;set;}
	
	//Zoom Size for Map
	public integer zoomSize {get;set;}    	
	public List<MUNI_Stop_Location__c> nearbyStops {get;set;}
	public String valueLong { get; set; }
	public String valueLat { get; set; }
	public List<BusPrediction> busPredictions {get; set;}

	 public MUNIGeoLocation()
	 {
	    zoomSize = 17;
	    busColorMap = new Map<String,String>();
	    radiusOptions = new List<SelectOption>();
	    radiusOptions.add(new SelectOption('0.0015','1 Block'));
	    radiusOptions.add(new SelectOption('0.0030','2 Blocks'));
	    radiusOptions.add(new SelectOption('0.0045','3 Blocks'));
	    nearbyStops = new List<MUNI_Stop_Location__c>();
	    busPredictions = new List<BusPrediction>();
	 }
 
	 public PageReference iFoundYou() 
	 {
	
	    busPredictions = new List<BusPrediction>();
	    System.debug('IFoundYou called....');
	    System.debug('User Lat: ' + valueLat);
	    System.debug('User Long: ' + valueLong);
	    if(radiusValue == null)
	    {
	        radiusValue = '0.0015';
	    }
	    setZoomLevel();
	    bottomLat = -1 * Decimal.ValueOf(radiusValue) + Decimal.valueOf(valueLat);
	    topLat = Decimal.ValueOf(radiusValue) + Decimal.valueOf(valueLat);
	    bottomLong = -1 * Decimal.ValueOf(radiusValue) + Decimal.valueOf(valueLong);
	    topLong = Decimal.ValueOf(radiusValue) + Decimal.valueOf(valueLong);
	    
	    system.debug('bottomLat == ' + bottomLat  );
	    system.debug('topLat == ' + topLat);
	    system.debug('topLong == ' + topLong);
	    system.debug('bottomLong == ' + bottomLong); 
	    nearbyStops = [Select Latitude__c, Longitude__c, StopId__c, MUNI_Stop_Id__c from MUNI_Stop_Location__c where (Latitude__c > :bottomLat and Latitude__c < :topLat) and (Longitude__c > :bottomLong and Longitude__c < :topLong) limit 100];
	    set<String> ids = new set<String>();
	    integer colorCount = 0;
	    for(MUNI_Stop_Location__c stopLoc : nearbyStops)
	    {
	        ids.add(stopLoc.MUNI_Stop_Id__c);
	        busColorMap.put(stopLoc.StopId__c,colors[colorCount]);
	        colorCount++;
	        if(colorCount > 6)
	        {
	            colorCount = 0;
	        }
	    }
	    
	    integer limitStops = 10;
	    integer limitCount = 0;
	    if(ids.size() >= 10)
	    {
	        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Warning: More than 10 stops found in your radius. Some buses may not show on your search results. Please reduce your search radius.');
	        ApexPages.addMessage(myMsg);
	    }   
	    String xmlPredictionsResponse = '';
	    for(String id : ids)
	    {
	        limitCount++;
	        if(!testMode && limitCount < limitStops)
	        {
	            xmlPredictionsResponse = TransitServiceUtility.getBusPredictions(id);
	            system.debug(xmlPredictionsResponse);
	            List<BusPrediction> tempPredicts = TransitServiceUtility.foundBusPredictions(xmlPredictionsResponse,busColorMap);
	            busPredictions.addAll(tempPredicts);
	        }
	    }
	    return null;
	 }
	
	 private void setZoomLevel()
	 {
	    if(radiusValue != null)
	    {
	        if(radiusValue == '0.0015')
	        {
	            zoomSize = 17;
	        }else if(radiusValue == '0.0030')
	        {
	            zoomSize = 16;
	        }else if(radiusVAlue == '0.0045')
	        {
	            zoomSize = 15;
	        }
	    }
	    
	 }
	 
	 String getDecodedString(Xmlstreamreader reader) 
	 {
	     return EncodingUtil.urlDecode(reader.getText(), 'UTF-8').trim();
	 } 
	 
	 private static testMethod void testController()
	 {
	    MUNIGeoLocation testController = new MUNIGeoLocation();
	    testController.testMode = true;
	    testController.valueLat = '41.9220744';
	    testController.valueLong = '-87.6368514';
	    testController.iFoundYou();    
	    system.assert(true);
	 } 

}