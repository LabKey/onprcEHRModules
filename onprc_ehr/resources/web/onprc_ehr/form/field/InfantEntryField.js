/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext4.define('ONPRC_EHR.form.field.InfantEntryField', {
    extend: 'LABKEY.ext4.ComboBox',
    alias: 'widget.onprc_ehr-infantentryfield',


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


        if (!rec || !rec.get('Id')){
            Ext4.Msg.alert('Error', 'No Id Entered');
            return;
        }

        Ext4.Msg.wait('Loading...');


        this.queryValue(rec, function(ret){
            Ext4.Msg.hide();

            if (ret && ret.InfantCageMate){
                this.setValue(ret.InfantCageMate);
                }
        }, true);
    },

    queryValue: function(rec, cb, alwaysUseCallback){
        var date = rec.get('date') || new Date();
        var id = rec.get('Id');

        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'CageMateInfant',
            columns: 'Id,InfantCageMate',
            filterArray: [
                LABKEY.Filter.create('Id', rec.get('Id'), LABKEY.Filter.Types.EQUAL)
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