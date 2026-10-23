/**
 * Created: R.Blasa on 10/25/2017.
 */
/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.form.field.CEG_PlantextArea', {
    extend: 'Ext.form.field.TextArea',
    alias: 'widget.onprc_ehr-CEG_Plantextarea',

    onAnimalChange: function(){
        this.updateDisplayEl();
    },

    onRender : function(ct, position){
        this.callParent(arguments);

        this.wrap = this.inputEl.wrap({
            tag: 'div',
            cls: 'x4-form-field-wrap'
        });

        this.linkDiv = this.wrap.createChild({
            tag: 'div',
            style: 'vertical-align:top;'
        }, this.inputEl);

        this.linkEl = this.linkDiv.createChild({
            tag: 'a',
            cls: 'labkey-text-link',
            html: (this.getValue() ? 'Copy Latest CEG_Plan' : 'Edit CEG_Plan')
        });

        var panel = this.up('ehr-formpanel');
        if (panel){
            this.mon(panel, 'bindrecord', this.onAnimalChange, this, {buffer: 100});
        }
        else {
            LDK.Utils.logToServer({
                message: 'Unable to find ehr-formpanel in PlanTextArea'
            })
        }

        var dataEntryPanel = this.up('ehr-dataentrypanel');
        if (dataEntryPanel){
            this.mon(dataEntryPanel, 'animalchange', this.onAnimalChange, this, {buffer: 100});
        }
        else {
            LDK.Utils.logToServer({
                message: 'Unable to find ehr-dataentrypanel in PlanTextArea'
            })
        }

        this.linkEl.on('click', this.copyMostRecentCEG_Plan, this);
        this.setupMask();
    },

    setupMask: function(){
        if (this.getValue()){
            this.showTextArea();
            return;
        }

        this.inputEl.setVisibilityMode(Ext4.dom.AbstractElement.DISPLAY);
        this.inputEl.setVisible(false);

        this.displayEl = this.wrap.createChild({
            tag: 'div',
            style: 'vertical-align:top;',
            html: ''
        });

        this.displayEl.setWidth(this.width - this.labelWidth);
        this.displayEl.setHeight(this.getHeight());

        this.updateDisplayEl();
    },

    showTextArea: function(){
        if (!this.rendered){
            return;
        }

        if (this.displayEl){
            this.displayEl.remove();
            delete this.displayEl;
        }

        if (this.linkEl){
            this.linkEl.update('Copy Latest CEG_Plan');
        }

        if (this.inputEl)
            this.inputEl.setVisible(true);
    },

    updateDisplayEl: function(){
        if (!this.displayEl){
            return;
        }

        var rec = EHR.DataEntryUtils.getBoundRecord(this);
        if (rec && rec.get('Id')){
            this.getMostRecentCEG_Plan(rec, function(ret, Id){
                if (!ret || !this.displayEl){
                    return;
                }

                if (ret.mostRecentCeg_Plan && ret.isActive){
                    this.displayEl.update(ret.mostRecentCeg_Plan);
                }
                else {
                    this.displayEl.update('Either no active case or no CEG_Plan for ' + (Id || rec.get('Id')));
                }
            });
        }
        else {
            this.displayEl.update('No animal entered');
        }
    },

    copyMostRecentCEG_Plan: function(){
        var rec = EHR.DataEntryUtils.getBoundRecord(this);
        if (!rec || !rec.get('Id')){
            Ext4.Msg.alert('Error', 'No Id Entered');
            return;
        }

        Ext4.Msg.wait('Loading...');
        this.showTextArea();

        this.getMostRecentCEG_Plan(rec, function(ret){
            Ext4.Msg.hide();

            if (ret){
                this.setValue(ret.mostRecentCeg_Plan);
                this.linkEl.update('Refresh CEG Plan');
            }
        }, true);
    },

    getMostRecentCEG_Plan: function(rec, cb, alwaysUseCallback){
        var date = rec.get('date') || new Date();
        var id = rec.get('Id');
        this.pendingIdRequest = id;

        LABKEY.Query.executeSql({
            schemaName: 'study',
            sql: 'SELECT c.Id, c.CEG_Plan as mostRecentCeg_Plan, c.caseid, c.caseid.category as caseCategory, c.caseid.isActive as isActive FROM study.clinRemarks c WHERE (c.category != \'Replaced SOAP\' OR c.category IS NULL) AND c.CEG_Plan IS NOT NULL AND c.Id = \'' + rec.get('Id') + '\' ORDER BY c.date DESC LIMIT 1',
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: function(results){
                if (!alwaysUseCallback && id != this.pendingIdRequest){
                    console.log('more recent request, aborting');
                    return;
                }

                if (results && results.rows && results.rows.length && results.rows[0].mostRecentCeg_Plan){
                    cb.call(this, results.rows[0], results.rows[0].Id);
                }
                else {
                    cb.call(this, null, id);
                }
            }
        });
    },

    onDestroy : function(){
        if (this.linkEl){
            this.linkEl.removeAllListeners();
            this.linkEl.remove();
        }

        if (this.linkDiv){
            this.linkDiv.removeAllListeners();
            this.linkDiv.remove();
        }

        if (this.displayEl){
            //NOTE: no listeners were added
            //this.displayEl.removeAllListeners();
            this.displayEl.remove();
        }

        if (this.wrap){
            this.wrap.remove();
        }

        this.callParent(this);
    },

    setValue: function(){
        this.callParent(arguments);

        if (this.getValue()){
            this.showTextArea();
        }
    }
});