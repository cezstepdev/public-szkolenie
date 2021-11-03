public class OTO_OpportunityToOrder {
    @AuraEnabled
    public static list<Order> createOrder (Id oppId) {
        List<OpportunityLineItem > opl = [SELECT UnitPrice, Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :oppId Order By CreatedDate ASC];
        List<Order> ol = new List<Order>();
        if (opl.size() > 0 && oppId != null) {
            Opportunity OpportunityInfo = [SELECT Pricebook2Id, AccountId, ContactId, Order_Created__c, OwnerId, StageName FROM Opportunity WHERE Id = :oppId];
            List<OpportunityLineItem> OpportunityLineItems = [SELECT UnitPrice, Quantity, PricebookEntryId,Id FROM OpportunityLineItem WHERE Id IN :opl];

            if(OpportunityLineItems == null && OpportunityInfo.StageName != 'Closed Won') {
                return new List<Order>();
            }

            //Insert Order
            Order Oobj = New Order();
            Oobj.AccountId = OpportunityInfo.AccountId;
            Oobj.BillToContactId = OpportunityInfo.ContactId;
            Oobj.EffectiveDate = date.today();
            Oobj.Status = 'Draft';
            Oobj.Pricebook2Id = OpportunityInfo.Pricebook2Id;
            Oobj.EndDate = date.today() + 30;
            Oobj.Opportunity__c = OpportunityInfo.Id;
            Insert Oobj;

            List<OrderItem> OrderLineItems = New List<OrderItem>();
            List<OpportunityLineItem> oplineItems = New List<OpportunityLineItem>();
            for (OpportunityLineItem opli : OpportunityLineItems) {
                OrderItem OLobj = New OrderItem();
                OLobj.Quantity = opli.Quantity;
                PricebookEntry pb = [SELECT Product2Id, Pricebook2Id FROM PricebookEntry WHERE Id = :opli.PricebookEntryId];
                OLobj.Product2Id = pb.Product2Id;
                OLobj.OrderId = Oobj.Id;
                OLobj.UnitPrice = opli.UnitPrice;
                OLobj.PricebookEntryId = opli.PricebookEntryId;
                OrderLineItems.add(OLobj);
            }
            Insert OrderLineItems;

            OpportunityInfo.Order_Created__c = true;
            OpportunityInfo.StageName = 'Closed';
            upsert OpportunityInfo;

            ol = [select Id from Order where Id = :Oobj.Id];

        }
        return ol;
    }

    @AuraEnabled
    public static Opportunity get(String oppId) {
        return [
                SELECT Order_Created__c
                FROM Opportunity
                WHERE Id = :oppId
        ];
    }

    @AuraEnabled
    public static Boolean getProducts(String oppId) {
        List<OpportunityLineItem > opl = [SELECT UnitPrice, Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :oppId Order By CreatedDate ASC];
        List<Order> ol = new List<Order>();
        if (opl.size() > 0 && oppId != null) {
            Opportunity OpportunityInfo = [SELECT Pricebook2Id, AccountId, ContactId, Order_Created__c, OwnerId, StageName FROM Opportunity WHERE Id = :oppId];
            List<OpportunityLineItem> OpportunityLineItems = [SELECT UnitPrice, Quantity, PricebookEntryId,Id FROM OpportunityLineItem WHERE Id IN :opl];

            if(OpportunityLineItems == null) {
                return false;
            }
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Boolean getStage(String oppId) {
        List<OpportunityLineItem > opl = [SELECT UnitPrice, Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :oppId Order By CreatedDate ASC];
        List<Order> ol = new List<Order>();
        if (opl.size() > 0 && oppId != null) {
            Opportunity OpportunityInfo = [SELECT Pricebook2Id, AccountId, ContactId, Order_Created__c, OwnerId, StageName FROM Opportunity WHERE Id = :oppId];
            List<OpportunityLineItem> OpportunityLineItems = [SELECT UnitPrice, Quantity, PricebookEntryId,Id FROM OpportunityLineItem WHERE Id IN :opl];

            if(OpportunityInfo.StageName != 'Closed Won') {
                return false;
            }
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Boolean quoteAccepted(String id){
        List<Quote> quotes = [SELECT Id FROM Quote WHERE Opportunity.Id =: id AND Status = 'Accepted'];
        return quotes.size() > 0;
    }
}