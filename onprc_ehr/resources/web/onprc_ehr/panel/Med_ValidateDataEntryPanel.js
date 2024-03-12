/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

// Created: 3-12-2024
Ext4.define('ONPRC_EHR.panel.ClinicalMedicationDataEntryPanel', {
    extend: 'EHR.panel.TaskDataEntryPanel',


   onBeforeSubmit: function(btn){
       if (!btn || !btn.targetQC || ['Completed'].indexOf(btn.targetQC) == -1){
           return;
       }

       var store = this.storeCollection.getClientStoreByName('Treatment Orders');
       LDK.Assert.assertNotEmpty('Unable to find Treatment Orders store', store);

       var ids = [];
       store.each(function(r){
           if (r.get('Id')&& r.get('code')=='E-85760' && r.get('category') == 'Clinical' )
               ids.push(r.get('Id'))
       }, this);
       ids = Ext4.unique(ids);

       // && r.get('endate') >= new Date()

       if (!ids.length)
           return;

       if (ids.length){
           Ext4.Msg.confirm('Ask  Medication Question', 'You have made a medication entry for this animal, do you want to continue anyway?', function(val){
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

       return false;
    }
    });
