/*
 * Copyright (c) 2014-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.form.field.Surg_PlanTextArea', {
    extend: 'Ext.form.field.TextArea',
    alias: 'widget.onprc_ehr-Surg_plantextarea',

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
            html: (this.getValue() ? 'Copy Latest S2' : 'Edit S2')
        });

        var panel = this.up('ehr-formpanel');
        if (panel){
            this.mon(panel, 'bindrecord', this.onAnimalChange, this, {buffer: 100});
        }
        else {
            LDK.Utils.logToServer({
                message: 'Unable to find ehr-formpanel in Surg_PlantextArea'
            })
        }

        var dataEntryPanel = this.up('ehr-dataentrypanel');
        if (dataEntryPanel){
            this.mon(dataEntryPanel, 'animalchange', this.onAnimalChange, this, {buffer: 100});
        }
        else {
            LDK.Utils.logToServer({
                message: 'Unable to find ehr-dataentrypanel in Surg_PlanTextArea'
            })
        }

        this.linkEl.on('click', this.copyMostRecentS2, this);
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
            this.linkEl.update('Copy Latest S2');
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
            this.getMostRecentS2(rec, function(ret, Id){
                if (!ret || !this.displayEl){
                    this.displayEl.update('Either no active case or no S2 for ' + (Id || rec.get('Id')));
                    return;
                }

                if (ret.mostRecentS2 && ret.isActive){
                    this.displayEl.update(ret.mostRecentS2);
                }
                else {
                    this.displayEl.update('Either no active case or no S2 for ' + (Id || rec.get('Id')));
                }
            });
        }
        else {
            this.displayEl.update('No animal entered');
        }
    },

    copyMostRecentS2: function(){
        var rec = EHR.DataEntryUtils.getBoundRecord(this);
        if (!rec || !rec.get('Id')){
            Ext4.Msg.alert('Error', 'No Id Entered');
            return;
        }

        Ext4.Msg.wait('Loading...');
        this.showTextArea();

        this.getMostRecentS2(rec, function(ret){
            Ext4.Msg.hide();

            if (ret && ret.mostRecentS2){
                this.setValue(ret.mostRecentS2);
                this.linkEl.update('Refresh S2');
            }
        }, true);
    },

    getMostRecentS2: function(rec, cb, alwaysUseCallback){
        var date = rec.get('date') || new Date();
        var id = rec.get('Id');
        this.pendingIdRequest = id;

        LABKEY.Query.executeSql({
            schemaName: 'study',
            sql: 'SELECT c.Id, c.p2 as mostRecentS2, c.caseid,  c.category as caseCategory, c.caseid.isActive as isActive FROM study.clinRemarks c WHERE (c.category = \'Surgery\' )  AND c.p2 IS NOT NULL AND c.Id = \'' + rec.get('Id') + '\' ORDER BY c.date DESC LIMIT 1',
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