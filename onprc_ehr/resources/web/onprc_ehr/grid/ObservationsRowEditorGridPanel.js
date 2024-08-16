/*
 * Copyright (c) 2014-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * This is used within the RowEditor in the clinical rounds form
 *
 * @cfg observationFilterArray
 *
 */
Ext4.define('ONPRC_EHR.grid.ObservationsRowEditorGridPanel', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.onprc_ehr-observationsroweditorgridpanel',

    initComponent: function(){
        Ext4.apply(this, {
            columns: this.getColumns(),
            boundRecord: null,
            boundRecordId: null,
            selModel: {
                mode: 'MULTI'
            },
            plugins: [{
                ptype: 'clinicalobservationscellediting',
                pluginId: 'cellediting',
                clicksToEdit: 1
            }],
            dockedItems: [{
                xtype: 'toolbar',
                position: 'top',
                items: [{
                    text: 'Add',
                    scope: this,
                    handler: function(btn){
                        var rec = this.createModel();
                        if (!rec)
                            return;

                        this.store.add(rec);
                        this.getPlugin('cellediting').startEdit(rec, 0);
                    }
                },{
                    text: 'Remove',
                    scope: this,
                    handler: function(btn){
                        var recs = this.getSelectionModel().getSelection();
                        this.store.remove(recs);
                    }
                }]
            }]
        });

        this.callParent();

        this.mon(this.remarkStore, 'update', this.onRecordUpdate, this);
    },

    createModel: function(data){
        var form = this.up('window').down('ehr-formpanel');
        var br = form.getRecord();
        LDK.Assert.assertNotEmpty('No bound record in ObservationsRowEditorGridPanel', br);
        if (!br){
            Ext4.Msg.alert('Error', 'Unable to find record');
            return;
        }

        LDK.Assert.assertNotEmpty('No animal Id in ObservationsRowEditorGridPanel', br.get('Id'));
        if (!br.get('Id')){
            Ext4.Msg.alert('Error', 'No animal Id provided');
            return;
        }

        return this.store.createModel(Ext4.apply({
            Id: br.get('Id'),
            date: new Date(),
            caseid: br.get('caseid')
        }, data));
    },

    getColumns: function(){
        return [{
            header: 'Category',
            dataIndex: 'category',
            editable: true,
            renderer: function(value, cellMetaData, record){
                if (Ext4.isEmpty(value)){
                    cellMetaData.tdCls = 'labkey-grid-cell-invalid';
                }

                return value;
            },
            editor: {
                xtype: 'labkey-combo',
                editable: true,
                displayField: 'value',
                valueField: 'value',
                forceSelection: true,
                queryMode: 'local',
                anyMaych: true,
                store: {
                    type: 'labkey-store',
                    schemaName: 'ehr',
                    queryName: 'observation_types',
                    filterArray: this.observationFilterArray,
                    columns: 'value,editorconfig',
                    autoLoad: true
                }
            }
        },{
            header: 'Area',
            width: 200,
            editable: true,
            dataIndex: 'area',
            editor: {
                xtype: 'labkey-combo',
                displayField: 'value',
                valueField: 'value',
                forceSelection: true,
                queryMode: 'local',
                anyMaych: true,
                value: 'N/A',
                store: {
                    type: 'labkey-store',
                    schemaName: 'ehr_lookups',
                    queryName: 'observation_areas',
                    autoLoad: true
                }
            }
        },{
            header: 'Observation/Score',
            width: 200,
            editable: true,
            dataIndex: 'observation',
            renderer: function(value, cellMetaData, record){
                if (Ext4.isEmpty(value) && ['Vet Attention'].indexOf(record.get('category')) == -1){
                    cellMetaData.tdCls = 'labkey-grid-cell-invalid';
                }

                return value;
            },
            editor: {
                xtype: 'textfield'
            }
        },{
                header: 'inflammtion',
                width: 200,
                editable: true,
                dataIndex: 'inflammation',
                editor: {
                    xtype: 'labkey-combo',
                    displayField: 'state',
                    valueField: 'state',
                    forceSelection: true,
                    defaultValue:'Normal',
                    queryMode: 'local',
                    anyMaych: true,
                    value: 'N/A',
                    store: {
                        type: 'labkey-store',
                        schemaName: 'ehr_lookups',
                        queryName: 'normal_abnormal',
                        autoLoad: true
                    }
               }
         },{

            header: 'bruising',
            width: 200,
            editable: true,
            dataIndex: 'bruising',
            editor: {
                xtype: 'labkey-combo',
                displayField: 'state',
                valueField: 'state',
                forceSelection: true,
                defaultValue:'Normal',
                queryMode: 'local',
                anyMaych: true,
                value: 'N/A',
                store: {
                    type: 'labkey-store',
                    schemaName: 'ehr_lookups',
                    queryName: 'normal_abnormal',
                    autoLoad: true
                }
            }
         },{

               header: 'other',
               width: 200,
               editable: true,
               dataIndex: 'other',
               editor: {
                   xtype: 'labkey-combo',
                   displayField: 'state',
                   valueField: 'state',
                   forceSelection: true,
                   defaultValue:'Normal',
                   queryMode: 'local',
                   anyMaych: true,
                   value: 'N/A',
                   store: {
                       type: 'labkey-store',
                       schemaName: 'ehr_lookups',
                       queryName: 'normal_abnormal',
                       autoLoad: true
                   }
               }
           },{
            header: 'Remarks',
            width: 200,
            editable: true,
            dataIndex: 'remark',
            editor: {
                xtype: 'textarea',
                width: 200,
                height: 100
            }
        }]
    },

    onRecordUpdate: function(store, rec){
        if (rec === this.boundRecord){
            var newId = rec.get('Id');
            var newDate = rec.get('date');

            if (rec.get('Id') != this.boundRecordId){
                this.store.each(function(r){
                    //update any record from the bound animal
                    if (r.get('Id') === this.boundRecordId){
                        r.set({
                            Id: newId,
                            date: newDate
                        });
                    }
                }, this);
            }
        }
    },

    loadRecord: function(rec){
        var id = rec.get('Id');

        this.boundRecord = rec;
        this.boundRecordId = rec.get('Id');

        this.store.clearFilter();
        this.store.filter('Id', id);
    }
});