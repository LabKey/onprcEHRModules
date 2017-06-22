/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created  3-16-2016  Blasa

Ext4.define('onprc_ehr.form.field.ProjectField', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc-projectfield',


            fieldLabel: 'Center Project',
            caseSensitive: false,
            anyMatch: true,
            editable: true,
            forceSelection: true,
            showInactive: false,
            matchFieldWidth: false,

            initComponent: function(){
                Ext4.apply(this, {
                    displayField: 'projectname',
                    valueField: 'project',
                    queryMode: 'local',
                    store: this.getStoreCfg()
                });


                this.callParent(arguments);
            },


            getStoreCfg: function(){
                var ctx = EHR.Utils.getEHRContext();

                var storeCfg = {
                    type: 'labkey-store',
                    containerPath: ctx ? ctx['EHRStudyContainer'] : null,
                    schemaName: 'onprc_ehr',
                    queryName: 'projectLabel',
                    columns: 'project,centerproject,projectname, investigator, Protocol',
                    filterArray:  [LABKEY.Filter.create('enddate', '-0d', LABKEY.Filter.Types.DATE_GREATER_THAN_OR_EQUAL)]
                                [LABKEY.Filter.create('enddate', true, LABKEY.Filter.Types.ISBLANK)],
                    sort: 'centerproject',
                    autoLoad: true
                };


                if (this.storeConfig){
                    Ext4.apply(storeCfg, this.storeConfig);
                }

                if (this.filterArray){
                    storeCfg.filterArray = storeCfg.filterArray.concat(this.filterArray);
                }

                return storeCfg;
            }
        });