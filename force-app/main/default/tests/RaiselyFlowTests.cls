@isTest
public class RaiselyFlowTests {

    @isTest
    public static void NewOneOffWithOnlineDonation() {

        // TODO!!!: Figure out a way to generally reference the Donation Opportunity Record Type
        // Right now, we have to go manually edit the flow for each org to get the org generated ID
        //Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        String donationOppRecordTypeId = '012Dn000000N15oIAC';

        // Crate a Campaign Record for our donation
        Campaign campaign = new Campaign();
        campaign.Name = 'Test Campaign';
        insert campaign;

        // Create the Get_Raisely_Data__c record
        Get_Raisely_Data__c raisleyData = new Get_Raisely_Data__c();

        raisleyData.Event_Type__c = 'donation.succeeded';
        raisleyData.Email__c = 'somebody@mitchroutt.com';
        raisleyData.First_Name__c = 'Joe';
        raisleyData.Last_Name__c = 'Schmoe';
        raisleyData.Donation_Item_Type__c = 'DONATION';
        raisleyData.Data_Source__c = 'Raisely';
        raisleyData.Mobile__c = '+1(555)999-0948';
        raisleyData.Newsletter_Opt_In__c = 'No';
        raisleyData.Processing__c = 'ONCE';
        raisleyData.Type__c = 'ONLINE';
        raisleyData.Amount__c = 100;
        raisleyData.Donation_UUID_c__c = '555DDASDFFG';
        raisleyData.Profile_Name__c = 'SomeProfile';
        raisleyData.Profile_Type__c = 'SomeProfileType';
        raisleyData.Receipt_ID__c = '9938DFFDS';
        raisleyData.Payment_Method__c = 'Credit Card';
        raisleyData.Team_Name__c = 'Dream Team';
        raisleyData.Business_Name_for_Receipt__c = 'Dreams Inc.';
        raisleyData.CampaignID__c = campaign.Id;
        raisleyData.Transaction_Date__c = Date.Today();
        raisleyData.BYT_Your_Message__c = 'Keep Pounding!';
           
        // The flow trigger happens after insert of the record, so we put the start/stop test methods here to make sure 
        // that the flow is done before we validate the data that was created. I am not 100% sure those calls are necessary.
        Test.startTest();
        insert raisleyData;
        Test.stopTest();

        // Verify the Contact was created correctly
        List<Contact> contacts = [SELECT Id, Email, FirstName, LastName, LeadSource, 
                                MobilePhone, Newsletter_Opt_In__c, Type_of_Contact__c 
                                FROM Contact];
                                
        system.assertEquals(1, contacts.size());
        Contact contact = contacts.get(0);                                

        system.assertEquals(raisleyData.Email__c, contact.Email);
        system.assertEquals(raisleyData.First_Name__c, contact.FirstName);
        system.assertEquals(raisleyData.Last_Name__c, contact.LastName);
        system.assertEquals(raisleyData.Data_Source__c, contact.LeadSource);
        system.assertEquals(raisleyData.Mobile__c, contact.MobilePhone);
        system.assertEquals(raisleyData.Newsletter_Opt_In__c, contact.Newsletter_Opt_In__c);
        system.assertEquals('Donor', contact.Type_of_Contact__c);
    
        // Verify the Donation Opportunity was created correctly
        List<Opportunity> opportunities = [SELECT Id, Amount, BYT_Channel__c, 
                                            BYT_Donation_UUID__c, BYT_Profile_Name__c,
                                            BYT_Profile_Type__c, BYT_Receipt_Id__c,
                                            BYT_Team_Name__c, Business_Name_for_Receipt__c,
                                            CampaignId, CloseDate, Donor_Message__c,
                                            Keep_Donation_Anonymous__c, LeadSource,
                                            Name, RecordTypeId, StageName,
                                            npsp__Acknowledgment_Date__c,
                                            npsp__Acknowledgment_Status__c,
                                            npsp__Primary_Contact__c,
                                            RecordType.DeveloperName
                                            FROM Opportunity];
        system.assertEquals(1, opportunities.size());
        Opportunity opp = opportunities.get(0);
        system.assertEquals(raisleyData.Amount__c, opp.Amount);
        system.assertEquals(raisleyData.Data_Source__c, opp.BYT_Channel__c);
        system.assertEquals(raisleyData.Donation_UUID_c__c, opp.BYT_Donation_UUID__c);
        system.assertEquals(raisleyData.Profile_Name__c, opp.BYT_Profile_Name__c);
        system.assertEquals(raisleyData.Profile_Type__c, opp.BYT_Profile_Type__c);
        system.assertEquals(raisleyData.Receipt_ID__c, opp.BYT_Receipt_Id__c);
        system.assertEquals(raisleyData.Team_Name__c, opp.BYT_Team_Name__c);
        system.assertEquals(raisleyData.Business_Name_for_Receipt__c, opp.Business_Name_for_Receipt__c);
        system.assertEquals(raisleyData.CampaignID__c, opp.CampaignId);
        system.assertEquals(raisleyData.Transaction_Date__c, opp.CloseDate);
        system.assertEquals(raisleyData.BYT_Your_Message__c, opp.Donor_Message__c);
        system.assertEquals(raisleyData.Keep_Donation_Anonymous__c, opp.Keep_Donation_Anonymous__c);
        system.assertEquals(raisleyData.Data_Source__c, opp.LeadSource);
        system.assertEquals(raisleyData.First_Name__c + ' ' + raisleyData.Last_Name__c, opp.Name);
        system.assertEquals(donationOppRecordTypeId, opp.RecordTypeId);        
        system.assertEquals('Closed Won', opp.StageName);
        system.assertEquals(raisleyData.Transaction_Date__c, opp.npsp__Acknowledgment_Date__c);
        system.assertEquals(contact.Id, opp.npsp__Primary_Contact__c);            
        
        // Verify the Payment record was created and then updated properly
        List<Payment> payments = [SELECT Id FROM Payment];                                  
        system.assertEquals(1, payments.size(), 'The Flow did not create a Payment record');
        Payment payment = payments.get(0);
    }

}