public class HP_DoctorCustomEditController {
    private ApexPages.StandardController m_sc {get; set;}

    public HP_DoctorCustomEditController(ApexPages.StandardController standardController) {
        this.m_sc = standardController;
    }

    public PageReference doSaveAndNew()
    {
        SObject so = m_sc.getRecord();
        upsert so;
        string s = '/' + ('' + so.get('Id')).subString(0, 3) + '/e?';
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, s));
        return new PageReference(s);
    }
}