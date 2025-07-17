/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created: 2-4-2021  R.Blasa

Ext4.define('ONPRC_EHR.panel.ExamCasesDataEntryPanel', {
    extend: 'EHR.panel.TaskDataEntryPanel',


   onBeforeSubmit: function(btn){
       if (!btn || !btn.targetQC || ['Completed', 'Review Required'].indexOf(btn.targetQC) == -1){
           return;
       }

       var store = this.storeCollection.getClientStoreByName('Clinical Remarks');
       LDK.Assert.assertNotEmpty('Unable to find clinical remarks store', store);

       var ids = [];
       store.each(function(r){
           if (r.get('Id'))
               ids.push(r.get('Id'))
       }, this);
       ids = Ext4.unique(ids);

       if (!ids.length)
           return;

       EHR.DemographicsCache.getDemographics(ids, function(ids, idMap){
           var missingCases = [];
           Ext4.Array.forEach(ids, function(id){
               if (idMap[id]){
                   var cases = idMap[id].getActiveCases();
                   if (!cases || !cases.length){
                       missingCases.push(id);
                   }
                   else {
                       var found = false;
                       Ext4.Array.forEach(cases, function(c){
                           if (c.category == 'Clinical' && c.isActive){
                               found = true;
                           }
                       }, this);

                       if (!found){
                           missingCases.push(id);
                       }
                   }
               }
           }, this);

           if (missingCases.length){
               Ext4.Msg.confirm('No Case', 'There is no active clinical case for this animal, do you want to continue anyway?', function(val){
                   if (val == 'yes'){
                       this.onSubmit(btn, true);
                   }
                   else {

                   }
               }, this);
           }
           else {
               this.onSubmit(btn, true);
           }
       }, this);

       return false;
    },

    onStoreCollectionCommitComplete: function(sc, extraContext){
        if (Ext4.Msg.isVisible())
            Ext4.Msg.hide();


        var store = sc.getClientStoreByName('housing');
        LDK.Assert.assertNotEmpty('Unable to find housing store in HousingDataEntryPanel', store);

        if (extraContext && extraContext.successURL  && store.getCount() > 0){
            Ext4.Msg.confirm('Success', 'Do you want to view the room layout now?  This will allow you to verify and/or change dividers', function(val){
                window.onbeforeunload = Ext4.emptyFn;
                if (val == 'yes'){

                    var rooms = [];
                    store.each(function(r){
                        if (r.get('room') && rooms.indexOf(r.get('room')) == -1){
                            rooms.push(r.get('room'));
                        }
                    }, this);
                    window.location = LABKEY.ActionURL.buildURL('onprc_ehr', 'printRoom', null, {rooms: rooms});

                }
                else {
                    window.location = extraContext.successURL;
                }
            }, this);

            return;
        }

        this.callParent(arguments);
    }
    });
