@isTest
public class RaiselyFlowTests {

    // TODO!!!: Figure out a way to generally reference the Donation Opportunity Record Type
    // Right now, we have to go manually edit the flow for each org to get the org generated ID
    private static Id donationOppRecordTypeId = '012Dn000000N15oIAC'; 
    
    @isTest
    public static void NewOneOffWithOnlineDonation() {

        Get_Raisely_Data__c raiselyData = GenerateRaiselyRecord();
        
        raiselyData.Processing__c = 'ONCE';

        // The flow trigger happens after insert of the record, so we put the start/stop test methods here to make sure 
        // that the flow is done before we validate the data that was created. I am not 100% sure those calls are necessary.
        Test.startTest();
        insert raiselyData;
        Test.stopTest();

        Contact contact = VerifyNewContact(raiselyData);
    
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
                                            RecordType.DeveloperName,
                                            npe01__Do_Not_Automatically_Create_Payment__c
                                            FROM Opportunity];
        system.assertEquals(1, opportunities.size());
        Opportunity opp = opportunities.get(0);
        system.assertEquals(raiselyData.Amount__c, opp.Amount);
        system.assertEquals(raiselyData.Data_Source__c, opp.BYT_Channel__c);
        system.assertEquals(raiselyData.Donation_UUID_c__c, opp.BYT_Donation_UUID__c);
        system.assertEquals(raiselyData.Profile_Name__c, opp.BYT_Profile_Name__c);
        system.assertEquals(raiselyData.Profile_Type__c, opp.BYT_Profile_Type__c);
        system.assertEquals(raiselyData.Receipt_ID__c, opp.BYT_Receipt_Id__c);
        system.assertEquals(raiselyData.Team_Name__c, opp.BYT_Team_Name__c);
        system.assertEquals(raiselyData.Business_Name_for_Receipt__c, opp.Business_Name_for_Receipt__c);
        system.assertEquals(raiselyData.CampaignID__c, opp.CampaignId);
        system.assertEquals(raiselyData.Transaction_Date__c, opp.CloseDate);
        system.assertEquals(raiselyData.BYT_Your_Message__c, opp.Donor_Message__c);
        system.assertEquals(raiselyData.Keep_Donation_Anonymous__c, opp.Keep_Donation_Anonymous__c);
        system.assertEquals(raiselyData.Data_Source__c, opp.LeadSource);
        system.assertEquals(raiselyData.First_Name__c + ' ' + raiselyData.Last_Name__c, opp.Name);
        system.assertEquals(donationOppRecordTypeId, opp.RecordTypeId);        
        system.assertEquals('Closed Won', opp.StageName);
        system.assertEquals(raiselyData.Transaction_Date__c, opp.npsp__Acknowledgment_Date__c);
        system.assertEquals(contact.Id, opp.npsp__Primary_Contact__c);     
        system.assertEquals('Acknowledged', opp.npsp__Acknowledgment_Status__c);       
        
        if(!opp.npe01__Do_Not_Automatically_Create_Payment__c) {
            // Verify the Payment record was created and then updated properly
            List<npe01__OppPayment__c> payments = [SELECT Id, npe01__Check_Reference_Number__c,  
                                                    npe01__Payment_Method__c 
                                                    FROM npe01__OppPayment__c];                                  
            system.assertEquals(1, payments.size(), 'The Flow did not create a Payment record');
            npe01__OppPayment__c payment = payments.get(0);  
            system.assertEquals(raiselyData.Receipt_ID__c, payment.npe01__Check_Reference_Number__c);
            system.assertEquals(raiselyData.Payment_Method__c, payment.npe01__Payment_Method__c);          
        }
    }

    @isTest
    public static void NewRecurringDonation() {

        Get_Raisely_Data__c raiselyData = GenerateRaiselyRecord();
        
        raiselyData.Processing__c = 'RECURRING';

        // The flow trigger happens after insert of the record, so we put the start/stop test methods here to make sure 
        // that the flow is done before we validate the data that was created. I am not 100% sure those calls are necessary.
        Test.startTest();
        insert raiselyData;
        Test.stopTest();

        Contact contact = VerifyNewContact(raiselyData);

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
                                            RecordType.DeveloperName,
                                            npe01__Do_Not_Automatically_Create_Payment__c,
                                            BYT_Subscription_Uuid__c, Payment_Method__c
                                            FROM Opportunity];
        
        // The system automatically creates an opportunity for each month of the first year.
        system.assertEquals(12, opportunities.size());
        Opportunity opp = opportunities.get(0);
        system.assertEquals(raiselyData.Amount__c, opp.Amount);
        system.assertEquals(raiselyData.Data_Source__c, opp.BYT_Channel__c);
        system.assertEquals(raiselyData.Donation_UUID_c__c, opp.BYT_Donation_UUID__c);
        //system.assertEquals(raisleyData.Profile_Name__c, opp.BYT_Profile_Name__c);
        system.assertEquals(raiselyData.Profile_Type__c, opp.BYT_Profile_Type__c);
        system.assertEquals(raiselyData.Receipt_ID__c, opp.BYT_Receipt_Id__c);
        system.assertEquals(raiselyData.Team_Name__c, opp.BYT_Team_Name__c);
        system.assertEquals(raiselyData.Business_Name_for_Receipt__c, opp.Business_Name_for_Receipt__c);
        system.assertEquals(raiselyData.CampaignID__c, opp.CampaignId);
        system.assertEquals(raiselyData.Transaction_Date__c, opp.CloseDate);
        system.assertEquals(raiselyData.BYT_Your_Message__c, opp.Donor_Message__c);
        system.assertEquals(raiselyData.Keep_Donation_Anonymous__c, opp.Keep_Donation_Anonymous__c);
        system.assertEquals(raiselyData.Data_Source__c, opp.LeadSource);
        system.assertEquals(raiselyData.First_Name__c + ' ' + raiselyData.Last_Name__c + ' Donation (1) ' + Date.today().format(), opp.Name);
        system.assertEquals(donationOppRecordTypeId, opp.RecordTypeId);        
        system.assertEquals('Closed Won', opp.StageName);
        system.assertEquals(raiselyData.Transaction_Date__c, opp.npsp__Acknowledgment_Date__c);
        system.assertEquals(contact.Id, opp.npsp__Primary_Contact__c);
        system.assertEquals(raiselyData.Subscription_UUID__c, opp.BYT_Subscription_Uuid__c);
        system.assertEquals(raiselyData.Data_Source__c, opp.LeadSource);
        system.assertEquals(raiselyData.Payment_Method__c, opp.Payment_Method__c);
        system.assertEquals(raiselyData.Transaction_Date__c, opp.npsp__Acknowledgment_Date__c);
        system.assertEquals('Acknowledged', opp.npsp__Acknowledgment_Status__c);

        
        List<npe03__Recurring_Donation__c> recurringDonations = [SELECT 
                                                                Id, BYT_Lead_Source__c, Name, 
                                                                Subscription_UUID__c, npe03__Contact__c,
                                                                npe03__Installment_Period__c, npe03__Open_Ended_Status__c,
                                                                npe03__Recurring_Donation_Campaign__c,
                                                                npsp__Day_of_Month__c, npe03__Amount__c                                                                
                                                                FROM npe03__Recurring_Donation__c];
        system.assertEquals(1, recurringDonations.size());
        npe03__Recurring_Donation__c recurringDonation = recurringDonations.get(0);
        system.assertEquals(raiselyData.Data_Source__c, recurringDonation.BYT_Lead_Source__c);
        system.assertEquals(raiselyData.First_Name__c + ' ' + raiselyData.Last_Name__c + '\'s Regular Donation', recurringDonation.Name);
        system.assertEquals(raiselyData.Subscription_UUID__c, recurringDonation.Subscription_UUID__c);
        system.assertEquals(raiselyData.Amount__c, recurringDonation.npe03__Amount__c);
        system.assertEquals(contact.Id, recurringDonation.npe03__Contact__c);
        system.assertEquals('Monthly', recurringDonation.npe03__Installment_Period__c);
        system.assertEquals('Open', recurringDonation.npe03__Open_Ended_Status__c);
        system.assertEquals(raiselyData.CampaignID__c, recurringDonation.npe03__Recurring_Donation_Campaign__c);
        system.assertEquals(String.valueOf(Date.today().day()), recurringDonation.npsp__Day_of_Month__c);

        if(!opp.npe01__Do_Not_Automatically_Create_Payment__c) {
            // Verify that all 12 Payment records were created and then updated properly
            List<npe01__OppPayment__c> payments = [SELECT 
                                                    Id, npe01__Check_Reference_Number__c,
                                                    npe01__Payment_Method__c
                                                    FROM npe01__OppPayment__c];                                  
            system.assertEquals(12, payments.size(), 'The Flow did not create the Payment records');
            npe01__OppPayment__c payment = payments.get(0);             
            system.assertEquals(raiselyData.Receipt_ID__c, payment.npe01__Check_Reference_Number__c);
            system.assertEquals(raiselyData.Payment_Method__c, payment.npe01__Payment_Method__c);          
        } 
    }

    private static Get_Raisely_Data__c GenerateRaiselyRecord() {
        
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
        raisleyData.Type__c = 'ONLINE';
        raisleyData.Amount__c = 100;
        raisleyData.Donation_UUID_c__c = '555DDASDFFG';
        raisleyData.Subscription_UUID__c = '44995DDFSF';
        raisleyData.Profile_Name__c = 'SomeProfile';
        raisleyData.Profile_Type__c = 'SomeProfileType';
        raisleyData.Receipt_ID__c = '9938DFFDS';
        raisleyData.Payment_Method__c = 'Credit Card';
        raisleyData.Team_Name__c = 'Dream Team';
        raisleyData.Business_Name_for_Receipt__c = 'Dreams Inc.';
        raisleyData.CampaignID__c = campaign.Id;
        raisleyData.Transaction_Date__c = Date.Today();
        raisleyData.BYT_Your_Message__c = 'Keep Pounding!';

        return raisleyData;
    }

    private static Contact VerifyNewContact(Get_Raisely_Data__c raiselyData) {
         
        // Verify the Contact was created correctly
         List<Contact> contacts = [SELECT Id, Email, FirstName, LastName, LeadSource, 
         MobilePhone, Newsletter_Opt_In__c, Type_of_Contact__c 
         FROM Contact];
                
        system.assertEquals(1, contacts.size());
        Contact contact = contacts.get(0);                                

        system.assertEquals(raiselyData.Email__c, contact.Email);
        system.assertEquals(raiselyData.First_Name__c, contact.FirstName);
        system.assertEquals(raiselyData.Last_Name__c, contact.LastName);
        system.assertEquals(raiselyData.Data_Source__c, contact.LeadSource);
        system.assertEquals(raiselyData.Mobile__c, contact.MobilePhone);
        system.assertEquals(raiselyData.Newsletter_Opt_In__c, contact.Newsletter_Opt_In__c);
        system.assertEquals('Donor', contact.Type_of_Contact__c);

        return contact;
    }
}