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

//This class encapsulates the functionality for the Transit Agency API
//This is where you can swap out different Transit Agencies to work with the Application
public with sharing class TransitServiceUtility 
{
    //MUNI Specific Values
    public static String BODY_TAG = 'body';
    public static  String PREDICTIONS_TAG = 'predictions';
    public static  String DIRECTION_TAG = 'direction';
    public static  String PREDICTION_TAG = 'prediction';
    public static  String EPOCH_TIME_ATTR = 'epochTime';
    public static  String STOP_TAG_ATTR = 'stopTag';
    public static  String STOP_TITLE_ATTR = 'stopTitle';
    public static  String MINUTES_ATTR = 'minutes';
    public static  String TITLE_ATTR = 'title';
    public static  String ROUTE_TITLE_ATTR = 'routeTitle';

 public static String getBusPredictions(String stopId)
 {
    // Instantiate a new http object  
    
    Http h = new Http();

    String params = '';
    params = params + '&stopId=' + stopId; 
    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint  
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni' + params);
    req.setMethod('GET');

    // Send the request, and return a response  
    
    HttpResponse res = h.send(req);
    system.debug(res.getBody());
    return res.getBody();
 }
    
 public static List<BusPrediction> foundBusPredictions(String xml, Map<String,String> busColorMap)
 {
    integer busLimit = 1;
    integer busCount = 0;
    system.debug(xml);
    List<BusPrediction> ctaBusPredictions = new List<BusPrediction>();
    Xmlstreamreader reader = new Xmlstreamreader(xml);
    reader.setCoalescing(true);
    while (reader.hasNext()) 
    {
        reader.next();
        system.debug('Local Name 1 == ' + reader.getLocalName());
        system.debug('Reader Event Type == ' + reader.getEventType());
        system.debug('XML Start TAg == ' + XmlTag.START_ELEMENT);
        if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == BODY_TAG)
        {
            system.debug('Local Name 2 == ' + reader.getLocalName());
            while(reader.hasNext())
            {
                reader.next();
                system.debug('Local Name 3 == ' + reader.getLocalName());
            
                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName()== PREDICTIONS_TAG)
                    {
                        String currentStopId = reader.getAttributeValue(null,STOP_TAG_ATTR );
                        String route = reader.getAttributeValue(null,ROUTE_TITLE_ATTR);
                        String stopTitle = reader.getAttributeValue(null,STOP_TITLE_ATTR);
                        system.debug('Current Stop Tag == ' + currentStopId);
                        while(reader.hasNext())
                        {
                            system.debug('Local Name 4 == ' + reader.getLocalName() );
                            reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName()== DIRECTION_TAG)
                            {
                                String currentDirection = reader.getAttributeValue(null,TITLE_ATTR );
                                system.debug('Local Name 5 == ' + reader.getLocalName());
                                reader.next();
                                while(reader.hasNext())
                                {
                                    BusPrediction tempBus = new BusPrediction();
                                    tempBus.rtDir = currentDirection;
                                    tempBus.stopName = stopTitle;
                                    system.debug('Local Name 6 == ' + reader.getLocalName());
                                    reader.next();
                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName()== PREDICTION_TAG)
                                    {
                                        String val = reader.getAttributeValue(null,MINUTES_ATTR);
                                        system.debug('StopId == ' + currentStopId + ', Minute == ' + val);
                                        tempBus.prdtm = val;
                                        tempBus.route = route;
                                        tempBus.stpid = currentStopId;
                                        busCount++;
                                        tempBus.color = busColorMap.get(tempBus.stpid);
                                        system.debug('Temp Bus Color == ' + tempBus.color);
                                        ctaBusPredictions.add(tempBus);
                                    }
                                    if(busCount > busLimit || (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == DIRECTION_TAG))
                                    {
                                        break;
                                    }                               
                                }
                            }
                        }   
                    }
                }
            }
        }
    
    return ctaBusPredictions;
 }
 
 static testMethod void testParser()
 {
 	String xml = '<body copyright="All data copyright San Francisco Muni 2011."><predictions agencyTitle="San Francisco Muni" routeTitle="M-Ocean View" routeTag="M" stopTitle="Civic Center Station Outbound" stopTag="6997"><direction title="Outbound to Balboa Park Station"><prediction epochTime="1314718876804" seconds="144" minutes="2" isDeparture="false" dirTag="M___OB1" vehicle="1446" block="9605" tripTag="4501745" /><prediction epochTime="1314719199913" seconds="468" minutes="7" isDeparture="false" dirTag="M___OB1" vehicle="1452" block="9612" tripTag="4501746" /><prediction epochTime="1314719552185" seconds="820" minutes="13" isDeparture="false" dirTag="M___OB1" vehicle="1535" block="9606" tripTag="4501747" /><prediction epochTime="1314720199261" seconds="1467" minutes="24" isDeparture="false" dirTag="M___OB1" vehicle="1464" block="9607" tripTag="4501748" /><prediction epochTime="1314720669210" seconds="1937" minutes="32" isDeparture="false" dirTag="M___OB1" vehicle="1406" block="9601" tripTag="4501749" /></direction></predictions></body>';
 	Map<String,String> testColors = new Map<String,String>();
 	List<BusPrediction> testPredictions = TransitServiceUtility.foundBusPredictions(xml, testColors);
 	system.assertEquals(2,testPredictions.size() );
 }

}