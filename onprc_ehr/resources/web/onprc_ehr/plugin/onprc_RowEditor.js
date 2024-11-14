/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * Created by Kollil on 11/12/24 in efforts to create the MPA pop up message display
 */
Ext4.onReady(function(){
Ext4.define('ONPRC_EHR.plugin.RowEditor', {
    extend: 'EHR.plugin.RowEditor',

    getDetailsPanelCfg: function () {
        return {
            xtype: 'onprc_ehr-animaldetailspanels',
            itemId: 'detailsPanel',
            showDisableButton: false
        }
    },

    getWindowCfg: function(){
        return {
            modal: true,
            width: 900,
            border: false,
            items: [{
                items: [this.getDetailsPanelCfg(), this.getFormPanelCfg()]
            }],
            buttons: this.getWindowButtons(),
            closeAction: 'destroy',
            listeners: {
                scope: this,
                close: this.onWindowClose,
                destroy: this.onWindowClose,
                beforerender: function(win){
                    var cols = win.down('#formPanel').items.get(0).items.getCount();
                    if (cols > 1){
                        var newWidth = cols * (EHR.form.Panel.defaultFieldWidth + 20);
                        if (newWidth > win.width) {
                            win.setWidth(newWidth);
                        }
                    }
                },
                afterrender: function(editorWin){
                    this.keyNav = new Ext4.util.KeyNav({
                        target: editorWin.getId(),
                        scope: this,
                        up: function(e){
                            if (e.ctrlKey){
                                this.loadPreviousRecord();
                            }
                        },
                        down: function (e){
                            if (e.ctrlKey){
                                this.loadNextRecord();
                            }
                        }
                    });
                },
                animalchange: {
                    fn: function(id){
                        this.getEditorWindow().down('#detailsPanel').loadAnimal(id);
                    },
                    scope: this,
                    buffer: 200
                }
            }
        }
    },

});
    EHR.Utils.rowEditorPlugin = 'ONPRC_EHR.plugin.RowEditor';
});