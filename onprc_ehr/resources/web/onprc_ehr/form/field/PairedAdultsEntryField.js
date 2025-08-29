/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext4.define('ONPRC_EHR.form.field.PairedAdultsEntryField', {
    extend: 'LABKEY.ext4.ComboBox',
    alias: 'widget.onprc_ehr-pairedadultsentryfield',


    trigger1Cls: 'x4-form-search-trigger',

    initComponent: function(){
        this.callParent(arguments);
    },

    onTrigger1Click: function(){
        var rec = EHR.DataEntryUtils.getBoundRecord(this);
        if (!rec){
            Ext4.Msg.alert('Error', 'Unable to locate associated animal Id');
            return;
        }

        if (!rec || !rec.get('room')){
            Ext4.Msg.alert('Error', 'No room Entered');
            return;
        }
        if (!rec || !rec.get('cage')){
            Ext4.Msg.alert('Error', 'No cage Entered');
            return;
        }
        Ext4.Msg.wait('Loading...');


        this.queryValue(rec, function(ret){
            Ext4.Msg.hide();

            if (ret && ret.adultcagemate){
                this.setValue(ret.adultcagemate);
                }


        }, true);
    },

    queryValue: function(rec, cb, alwaysUseCallback){
        var roomt = rec.get('room');
        var caget = rec.get('cage');

        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'CageMateAdults',
            columns: 'adultcagemate',
            sort:'Id',
            filterArray: [
                LABKEY.Filter.create('room', roomt , LABKEY.Filter.Types.EQUAL),
                LABKEY.Filter.create('cage', caget , LABKEY.Filter.Types.EQUAL)
            ],
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: function(results){
                if (!alwaysUseCallback && id != this.pendingIdRequest){
                    console.log('more recent request, aborting');
                    return;
                }

                if (results && results.rows && results.rows.length){
                    cb.call(this, results.rows[0], results.rows[0].Id);
                }
                else {
                    cb.call(this, null, id);
                }
            }
        });
    }

});