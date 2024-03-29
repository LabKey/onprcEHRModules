/*
 * Copyright (c) 2014-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Added 2-18-2016 Blasa
Ext4.define('onprc_ehr.panel.AddScheduledTreatmentPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc_AddScheduledTreatmentPanel',

    initComponent: function(){
        Ext4.applyIf(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Import Scheduled Treatments',
            border: true,
            bodyStyle: 'padding: 5px',
            width: 350,
            defaults: {
                width: 330,
                border: false
            },
            items: [{
                html: 'This helper allows you to pull records from the treatment schedule into this form.  It will identify any records matching the criteria below that have not already been marked as completed.  NOTE: it will only return records with a scheduled time that is in the past.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'datefield',
                fieldLabel: 'Date',
                value: new Date(),

                //hidden: !EHR.Security.hasPermission('Completed', 'update', {queryName: 'Blood Draws', schemaName: 'study'}),
                maxValue: (new Date()),
                itemId: 'dateField'
            },/*{
             xtype: 'ehr-timeofdayfield',
             itemId: 'timeField'
             },*/
                {
                    xtype: 'ehr-areafield',
                    multiSelect: true,
                    typeAhead: true,
                    itemId: 'areaField'
                },/*{
                 xtype: 'ehr-roomfield',
                 itemId: 'roomField'
                 },*/{
                    xtype: 'checkcombo',
                    forceSelection: true,
                    multiSelect: true,
                    addAllSelector: true,
                    fieldLabel: 'Treatment Time',
                    itemId: 'timeField',
                    displayField: 'treatmentTime',
                    valueField: 'timeValue',
                    store: {
                        type: 'array',
                        fields: ['timeValue','treatmentTime'],
                        data: [
                            ['800', '8:00 AM'],
                            ['1200', '12:00 Noon'],
                            ['1400', '2:00 PM'],
                            ['1600', '4:00 PM'],
                            ['2000', '8:00 PM']
                        ]
                    }
                },
                {
                    xtype: 'ehr-snomedtreatmentcombo',
                    defaultSubset: 'Post Op Meds' ,
                    fieldLabel: 'Treatment(s)',
                    itemId: 'code'
                },{
                    xtype: 'textfield',
                    fieldLabel: 'Performed By',
                    value: LABKEY.Security.currentUser.displayName,
                    itemId: 'performedBy'
                },{
            buttons: [{
                text: 'Submit',
                itemId: 'submitBtn',
                scope: this,
                handler: this.getTreatments
                 }]
            }]
        });

        this.callParent(arguments);
    },

    getFilterArray: function(){
        var area = this.down('#areaField') ? this.down('#areaField').getValue() : null;

        var times = EHR.DataEntryUtils.ensureArray(this.down('#timeField').getValue()) || []; //changed .getTimeValue to .getValue and ssystem functions 6/24/2015 jones

        // proposed change was to make it so they can only select 1 time slot.  THen we can change the filter to all it to retgrieve
        // any treatment order with the specified time that time of vertificatiopn is in a windos that is greater than or equyal to
        // treatmenttime - 30 ninutes.  This would allow an 8 AM med to be validated at 7:30

        var codes = EHR.DataEntryUtils.ensureArray(this.down('#code').getValue()) || [];
        var date = (this.down('#dateField') ? this.down('#dateField').getValue() : new Date());

        var filterArray = [];

        filterArray.push(LABKEY.Filter.create('date', Ext4.Date.format(date, LABKEY.extDefaultDateFormat), LABKEY.Filter.Types.DATE_EQUAL));
        filterArray.push(LABKEY.Filter.create('taskid', null, LABKEY.Filter.Types.ISBLANK));
        filterArray.push(LABKEY.Filter.create('treatmentStatus', null, LABKEY.Filter.Types.ISBLANK));

        //Modified 7-4-2015 Blasa
        if (area)
            filterArray.push(LABKEY.Filter.create('Id/curLocation/area', area.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF));

        if (times && times.length)      //changed time of day to time  6/23/2015 jones
            filterArray.push(LABKEY.Filter.create('time', times.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF));

        //Added  3-12-2015
        if (codes && codes.length)
            filterArray.push(LABKEY.Filter.create('code', codes.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF));

        return filterArray;
    },

    getTreatments: function(button){
        var filterArray = this.getFilterArray();
        if (!filterArray || !filterArray.length){
            return;
        }

        var date = (this.down('#dateField') ? this.down('#dateField').getValue() : new Date());
        Ext4.Msg.wait("Loading...");
       // this.hide();

        //find distinct animals matching criteria
        LABKEY.Query.selectRows({
            requiredVersion: 9.1,
            schemaName: 'study',
            queryName: 'treatmentSchedule',
            parameters: {
                NumDays: 1,
                StartDate: Ext4.Date.format(date, LABKEY.extDefaultDateFormat)
            },
            sort: 'date,Id/curlocation/room_sortValue,Id/curlocation/cage_sortValue,Id',
            columns: 'primaryKey,lsid,treatmentid,Id,date,project,meaning,code,qualifier,route,concentration,conc_units,amount,amount_units,dosage,dosage_units,volume,vol_units,remark,category,chargetype',
            filterArray: filterArray,
            scope: this,
            success: this.onSuccess,
            failure: LDK.Utils.getErrorCallback()
        });
    },

    onSuccess: function(results){
        if (!results || !results.rows || !results.rows.length){
            Ext4.Msg.hide();
            Ext4.Msg.alert('', 'No uncompleted treatments were found.');
            return;
        }

        var targetStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Drug Administration');
        LDK.Assert.assertNotEmpty('Unable to find targetStore in AddScheduledTreatmentPanel',  targetStore);

        var records = [];
        var performedby = this.down('#performedBy').getValue();

        Ext4.Array.each(results.rows, function(sr){
            var row = new LDK.SelectRowsRow(sr);

            row.date = row.getDateValue('date');

            var date = row.date;
            var treatmentTime = row.datetime;

            /* NOTE: the following block has been disabled.
             we always use the scheduled time, rather than the current time
             we could also consider putting a toggle on the window to switch behavior
               var date = new Date();

            if retroactively entering (more than 2 hours after the scheduled time), we take the time that record was scheduled to be administered.  otherwise we use the current time
           if ((date.getTime() - row.date.getTime()) > (1000 * 60 * 60 * 2))
                date = row.date;       */

            records.push(targetStore.createModel({
                Id: row.getValue('Id'),


               //Modified: 5-19-2016 R.Blasa
                date: row.date,
                project: row.getValue('project'),
                code: row.getValue('code'),
                qualifier: row.getValue('qualifier'),
                route: row.getValue('route'),
                concentration: row.getValue('concentration'),
                conc_units: row.getValue('conc_units'),
                amount: row.getValue('amount'),
                amount_units: row.getValue('amount_units'),
                volume: row.getValue('volume'),
                vol_units: row.getValue('vol_units'),
                dosage: row.getValue('dosage'),
                dosage_units: row.getValue('dosage_units'),
                treatmentid: row.getValue('treatmentid'),
                timeordered: row.getValue('date'),
                performedby: performedby,
                remark: row.getValue('remark'),
                category: row.getValue('category'),
                chargetype: row.getValue('chargetype')
            }));
        }, this);

        targetStore.add(records);

        Ext4.Msg.hide();
    }
});



