/*
 * Copyright (c) 2013-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 7-29-2020  R.Blasa

Ext4.define('ONPRC_EHR.data.TreatmentOrdersClientStore', {
    extend: 'EHR.data.DrugAdministrationRunsClientStore',

    constructor: function(){
        this.callParent(arguments);

        this.on('add', this.onAddRecord, this);
    },

    onAddRecord: function(store, records){
        Ext4.each(records, function(record){
            this.onRecordUpdate(record, ['objectid', 'code']);
        }, this);
    },

    afterEdit: function(record, modifiedFieldNames){
        this.onRecordUpdate(record, modifiedFieldNames);

        this.callParent(arguments);
    },

    onRecordUpdate: function(record, modifiedFieldNames){
        if (record.get('code')){
            modifiedFieldNames = modifiedFieldNames || [];

            if (modifiedFieldNames.indexOf('code') == -1){
                return;
            }

            if (record.get('code') == 'E-85760' && record.get('remark')== null){
                record.beginEdit();
                record.set('remark', 'Please make a clinical prime entry at each administration once the administration is complete.');
                record.endEdit(true);
            }

            if (!this.formularyStore){
                LDK.Utils.logToServer({
                    message: 'Unable to find formulary store in DrugAdministrationRunsClientStore'
                });
                console.error('Unable to find formulary store in DrugAdministrationRunsClientStore');

                return;
            }

            var values = this.formularyStore.getFormularyValues(record.get('code'));
            if (!Ext4.Object.isEmpty(values)){
                var params = {};

                for (var fieldName in this.fieldMap){
                    if (!this.getFields().get(fieldName)){
                        continue;
                    }

                    if (modifiedFieldNames.indexOf(this.fieldMap[fieldName]) != -1){
                        //console.log('field already set: ' + fieldName);
                        continue;
                    }

                    var def = values[fieldName];
                    if (Ext4.isDefined(def)){
                        params[this.fieldMap[fieldName]] = def;
                    }
                }

                if (!LABKEY.Utils.isEmptyObj(params)){
                    record.beginEdit();
                    record.set(params);
                    record.endEdit(true);
                }
            }
        }
    }


});
