public with sharing class AccountGeolocationChatterController 
{
	public String valueLong { get; set; }
	public String valueLat { get; set; }
	public integer zoomSize {get;set;}
	public String radiusValue {get;set;}
	//Bounding Box Coordinates
	public decimal bottomLat {get;set;}
	public decimal topLat {get;set;}
	public decimal topLong {get;set;}
	public decimal bottomLong {get;set;}
	public List<SelectOption> radiusOptions {get;set;}
	public List<Account> accounts {get;set;}
	public List<AccountFeed> accountFeeds {get;set;}
	public Map<String,List<AccountFeed>> accountFeedsMap {get;set;}
	
	public AccountGeolocationChatterController()
	{
		zoomSize = 17;
		radiusOptions = new List<SelectOption>();
	    radiusOptions.add(new SelectOption('0.0015','1 Block'));
	    radiusOptions.add(new SelectOption('0.0030','2 Blocks'));
	    radiusOptions.add(new SelectOption('0.0045','3 Blocks'));
	}
	
	public void findAccounts()
	{
	    if(radiusValue == null)
	    {
	        radiusValue = '0.0015';
	    }
	    setZoomLevel(); 
	    accounts = [Select Id, Latitude__c, Longitude__c, Name from Account where (Latitude__c > :bottomLat and Latitude__c < :topLat) and (Longitude__c > :bottomLong and Longitude__c < :topLong) limit 100];		
		List<String> accountIds = new List<String>();
		for(Account acct : accounts)
		{
			accountIds.add(acct.Id);
		}
		accountFeeds = [SELECT Body, Type, Title, CreatedBy.Name FROM AccountFeed where id in:accountIds ORDER BY CreatedDate DESC, Id DESC LIMIT 5  ];
		
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
}