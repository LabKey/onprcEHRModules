/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('EHR.window.ManageProcedureWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            title: 'Copy From Procedure',
            width: 500,
            bodyStyle: 'padding: 5px;',
            modal: true,
            closeAction: 'destroy',
            defaults: {
                border: false
            },
            items: [{
                html: 'This helper allows you to copy the default drugs and SNOMED codes from a different procedure.  Choose the procedure below, and which types of defaults to copy',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'labkey-combo',
                fieldLabel: 'Procedure',
                itemId: 'procedureField',
                forceSelection: true,
                width: 400,
                displayField: 'name',
                valueField: 'rowid',
                store: {
                    type: 'labkey-store',
                    schemaName: 'ehr_lookups',
                    queryName: 'procedures',
                    columns: 'rowid,name',
                    autoLoad: true
                }
            },{
                xtype: 'checkbox',
                boxLabel: 'Include Narrative?',
                itemId: 'narrativeField',
                checked: true
            },{
                xtype: 'checkbox',
                boxLabel: 'Include Meds?',
                itemId: 'drugField',
                checked: true
            },{
                xtype: 'checkbox',
                boxLabel: 'Include SNOMEDs?',
                itemId: 'snomedField',
                checked: true
            },{
                xtype: 'checkbox',
                itemId: 'deleteOriginal',
                boxLabel: 'Delete Existing Records?',
                checked: true
            }],
            buttons: [{
                text: 'Submit',
                scope: this,
                handler: this.onSubmit
            },{
                text: 'Cancel',
                hander: function(btn){
                    btn.up('window').close(0);
                }
            }]
        });

        this.callParent(arguments);
    },

    onSubmit: function(){
        var procedure = this.down('#procedureField').getValue();
        if (!procedure){
            Ext4.Msg.alert('Error', 'Must choose a procedure');
            return;
        }

        var includeNarrative = this.down('#narrativeField').getValue();
        var includeDrugs = this.down('#drugField').getValue();
        var includeSnomed = this.down('#snomedField').getValue();
        var deleteOriginal = this.down('#deleteOriginal').getValue();

        if (!includeNarrative && !includeDrugs && !includeSnomed){
            Ext4.Msg.alert('Error', 'Nothing selected');
            return;
        }

        if (deleteOriginal){
            this.deleteRecords();
        }
        else {
            this.createRecords();
        }
    },

    deleteRecords: function(){
        var procedure = this.down('#procedureField').getValue();
        var includeNarrative = this.down('#narrativeField').getValue();
        var includeDrugs = this.down('#drugField').getValue();
        var includeSnomed = this.down('#snomedField').getValue();

        var multi = new LABKEY.MultiRequest();

        this.deleteCommands = [];
        this.pendingSelects = 0;

        if (includeDrugs){
            this.pendingSelects++;

            LABKEY.Query.selectRows({
                schemaName: 'ehr_lookups',
                queryName: 'procedure_default_treatments',
                columns: 'rowid',
                filterArray: [LABKEY.Filter.create('procedureid', this.procedureId)],
                failure: LDK.Utils.getErrorCallback(),
                scope: this,
                success: function(results){
                    if (results.rows && results.rows.length){
                        var rows = [];
                        Ext4.Array.forEach(results.rows, function(r){
                            rows.push({
                                rowid: r.rowid
                            });
                        }, this);

                        if (rows.length){
                            this.deleteCommands.push({
                                command: 'delete',
                                schemaName: 'ehr_lookups',
                                queryName: 'procedure_default_treatments',
                                rows: rows
                            });
                        }
                    }

                    this.onDeleteSelectComplete();
                }
            });
        }

        if (includeSnomed){
            this.pendingSelects++;

            LABKEY.Query.selectRows({
                schemaName: 'ehr_lookups',
                queryName: 'procedure_default_codes',
                columns: 'rowid',
                filterArray: [LABKEY.Filter.create('procedureid', this.procedureId)],
                failure: LDK.Utils.getErrorCallback(),
                scope: this,
                success: function(results){
                    if (results.rows && results.rows.length){
                        var rows = [];
                        Ext4.Array.forEach(results.rows, function(r){
                            rows.push({
                                rowid: r.rowid
                            });
                        }, this);

                        if (rows.length){
                            this.deleteCommands.push({
                                command: 'delete',
                                schemaName: 'ehr_lookups',
                                queryName: 'procedure_default_codes',
                                rows: rows
                            });
                        }
                    }

                    this.onDeleteSelectComplete();
                }
            });
        }

        if (includeNarrative){
            this.pendingSelects++;

            LABKEY.Query.selectRows({
                schemaName: 'ehr_lookups',
                queryName: 'procedure_default_comments',
                columns: 'rowid',
                filterArray: [LABKEY.Filter.create('procedureid', this.procedureId)],
                failure: LDK.Utils.getErrorCallback(),
                scope: this,
                success: function(results){
                    if (results.rows && results.rows.length){
                        var rows = [];
                        Ext4.Array.forEach(results.rows, function(r){
                            rows.push({
                                rowid: r.rowid
                            });
                        }, this);

                        if (rows.length){
                            this.deleteCommands.push({
                                command: 'delete',
                                schemaName: 'ehr_lookups',
                                queryName: 'procedure_default_comments',
                                rows: rows
                            });
                        }
                    }

                    this.onDeleteSelectComplete();
                }
            });
        }
    },

    onDeleteSelectComplete: function(){
        this.pendingSelects--;
        if (!this.pendingSelects){
            if (this.deleteCommands.length){
                LABKEY.Query.saveRows({
                    commands: this.deleteCommands,
                    failure: LDK.Utils.getErrorCallback(),
                    scope: this,
                    success: function(){
                        this.createRecords();
                    }
                });
            }
            else {
                this.createRecords();
            }
        }
    },

    createRecords: function(){
        var procedure = this.down('#procedureField').getValue();
        var includeNarrative = this.down('#narrativeField').getValue();
        var includeDrugs = this.down('#drugField').getValue();
        var includeSnomed = this.down('#snomedField').getValue();

        var multi = new LABKEY.MultiRequest();
        this.createCommands = [];
        if (includeDrugs){
            multi.add(LABKEY.Query.selectRows, {
                schemaName: 'ehr_lookups',
                queryName: 'procedure_default_treatments',
                columns: 'code,qualifier,route,frequency,concentration,conc_units,dosage,dosage_units,amount,amount_units',
                filterArray: [LABKEY.Filter.create('procedureid', procedure)],
                failure: LDK.Utils.getErrorCallback(),
                scope: this,
                success: function(results){
                    if (results.rows && results.rows.length){
                        var rows = [];
                        Ext4.Array.forEach(results.rows, function(r){
                            r = Ext4.apply({}, r);
                            delete r.rowid;
                            r.procedureid = this.procedureId;

                            rows.push(r);
                        }, this);

                        if (rows.length){
                            this.createCommands.push({
                                schemaName: 'ehr_lookups',
                                queryName: 'procedure_default_treatments',
                                rows: rows
                            });
                        }
                    }
                }
            });
        }

        if (includeSnomed){
            multi.add(LABKEY.Query.selectRows, {
                schemaName: 'ehr_lookups',
                queryName: 'procedure_default_codes',
                columns: 'code,qualifier,sort_order',
                filterArray: [LABKEY.Filter.create('procedureid', procedure)],
                failure: LDK.Utils.getErrorCallback(),
                scope: this,
                success: function(results){
                    if (results.rows && results.rows.length){
                        var rows = [];
                        Ext4.Array.forEach(results.rows, function(r){
                            r = Ext4.apply({}, r);
                            delete r.rowid;
                            r.procedureid = this.procedureId;

                            rows.push(r);
                        }, this);

                        if (rows.length){
                            this.createCommands.push({
                                schemaName: 'ehr_lookups',
                                queryName: 'procedure_default_codes',
                                rows: rows
                            });
                        }
                    }
                }
            });
        }

        if (includeNarrative){
            multi.add(LABKEY.Query.selectRows, {
                schemaName: 'ehr_lookups',
                queryName: 'procedure_default_comments',
                columns: 'comment',
                filterArray: [LABKEY.Filter.create('procedureid', procedure)],
                failure: LDK.Utils.getErrorCallback(),
                scope: this,
                success: function(results){
                    if (results.rows && results.rows.length){
                        var rows = [];
                        Ext4.Array.forEach(results.rows, function(r){
                            r = Ext4.apply({}, r);
                            delete r.rowid;
                            r.procedureid = this.procedureId;

                            rows.push(r);
                        }, this);

                        if (rows.length){
                            this.createCommands.push({
                                schemaName: 'ehr_lookups',
                                queryName: 'procedure_default_comments',
                                rows: rows
                            });
                        }
                    }
                }
            });
        }

        multi.send(this.onComplete, this);
    },

    onComplete: function(){
        if (!this.createCommands.length){
            Ext4.Msg.alert('Complete', 'The selected procedure has no records to copy');
        }
        else {
            this.pendingInserts = 0;
            Ext4.Array.forEach(this.createCommands, function(c){
                this.pendingInserts++;

                LABKEY.Query.insertRows(Ext4.apply({
                    failure: LDK.Utils.getErrorCallback(),
                    scope: this,
                    success: this.onInsertComplete
                }, c));
            }, this);
        }
    },

    onInsertComplete: function(){
        this.pendingInserts--;

        if (!this.pendingInserts){
            console.log('create succes');
            Ext4.Msg.alert('Success', 'Records copied!', function(){
                window.location.reload();
            });
        }
    }
});