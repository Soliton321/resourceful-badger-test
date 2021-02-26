public class DisplayAccountHierachyCtrl {

	@AuraEnabled(cacheable=true)
    public static List<String> getCurrentHierarchy(Id accountId) {
        Map<Id,Account> parentAccId2AccMap = new Map<Id,Account>();
        Map<Id,Account> parentAccId2AccPersistMap = new Map<Id,Account>();
        //reduce to hierarchy from dimension N to dimension 2
        Map<Id,Map<Id,Account>> parentAccId2ChildAccountListMap = new Map<Id,Map<Id,Account>>();
        //construct nested jsonStr for lwc
        String jsonParentStr = ''; 
        
        //just display all parent-children pair on lwc page due to unfinished work
        List<String> displayinLWCList = new List<String>();
		Account currentAcc = [select id, name from account where id=:accountId limit 1];

        parentAccId2AccMap.put(currentAcc.Id,currentAcc);
        jsonParentStr +='{name:"'+currentAcc.name+'",';

        //iterage through all N hierarchy
        while (parentAccId2AccMap.size() > 0) {
            jsonParentStr += '_children: [';
            
            //retrieve all children or current parent acc
            Map<Id,Account> childAccId2AccMap =
                new Map<Id,Account>([
                    SELECT Id, ParentID, Name
                    FROM Account
                    WHERE ParentId IN :parentAccId2AccMap.keySet()
                ]);

            //maintain all accounts which has at least one parent into a map
            parentAccId2AccPersistMap.putAll(childAccId2AccMap);
            
            //refresh value from retrieval of last hierarchy level
            parentAccId2AccMap.clear();
            parentAccId2AccMap.putAll(childAccId2AccMap);

            //iterate next hierarchy level
            //pop any parent and child into a flattened container
            for (Account acc : childAccId2AccMap.values()) {
                if(parentAccId2ChildAccountListMap.containsKey(acc.parentId)){

                    Map<Id,Account> currAccMap = parentAccId2ChildAccountListMap.get(acc.parentId);   
                    currAccMap.put(acc.Id, acc);
                    parentAccId2ChildAccountListMap.put(acc.parentId,  currAccMap);
                }
                else{
                    parentAccId2ChildAccountListMap.put(acc.parentId, new Map<Id,Account>{acc.Id=>acc});
                }    

            }

        }

        for(Id pid: parentAccId2ChildAccountListMap.keySet()){
            displayinLWCList.add('parent '+pid + ' children ' + parentAccId2ChildAccountListMap.get(pid));
        }
 
    return displayinLWCList;
	}
}