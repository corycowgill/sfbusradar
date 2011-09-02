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

public with sharing class GeoCoderController 
{
	public String accountId {get;set;}
	public String lat {get;set;}
	public String lon {get;set;}
	public Account geoAccount {get;set;}
	public String gmapKey {get;set;}
	
	//Controller Constructer
	public GeoCoderController(ApexPages.standardcontroller std)
	{
		gmapKey = 'XXXXXXXREPLACEWITH A Google Maps Key';
		geoAccount = [Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, Latitude__c, Longitude__c from Account where id =: std.getId()];
	}
	
	//Store the Coordinates on the Account
	public void geoCodeResult()
	{
		system.debug('LAT == ' + lat);
		system.debug('LON == ' + lon);
		geoAccount.Latitude__c = Decimal.valueOf(lat);
		geoAccount.Longitude__c = Decimal.valueOf(lon);
		update geoAccount;
	}
	
	static testMethod void testController()
	{
		Account testAccount = new Account();
		testAccount.name = 'Unit Test';
		insert testAccount;
		
		ApexPages.standardController controller = new ApexPages.standardController(testAccount);
		GeoCoderController gcc = new GeoCoderController(controller);
		gcc.lat = '-100.00000';
		gcc.lon = '-100.00000';
		gcc.geoCodeResult();
		
		Account result = [Select Id, Latitude__c, Longitude__c from Account where id =:testAccount.Id];
		system.assertNotEquals(null,result.Latitude__c);
		system.assertNotEquals(null,result.Longitude__c);
	}
	
}