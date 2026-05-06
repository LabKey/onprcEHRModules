/*
 * Copyright (c) 2025 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('CaseMgmt', {
    byQuery: {
        'study.clinremarks': {
            Id: {
                columnConfig: {
                    getEditor: function(rec){
                        if (rec && rec.get('caseid')){
                            return false;
                        }
                        return {
                            xtype: 'ehr-animalfield',
                            dataIndex: 'Id'
                        };
                    }
                },
                formEditorConfig: {
                    listeners: {
                        afterrender: function(field){
                            var TOOLTIP = 'Refresh the form to enter data for a different animal.';
                            var syncDisabledStyle = function(readOnly){
                                var inputEl = field.inputEl;
                                if (inputEl){
                                    inputEl.setStyle({
                                        'background-color': readOnly ? '#f0f0f0' : '',
                                        color: readOnly ? '#666666' : '',
                                        cursor: readOnly ? 'not-allowed' : ''
                                    });
                                }
                            };
                            var setTooltip = function(readOnly){
                                var el = field.getEl();
                                if (el){
                                    el.set({'data-qtip': readOnly ? TOOLTIP : ''});
                                }
                            };
                            var syncReadOnly = function(){
                                var rec = EHR.DataEntryUtils.getBoundRecord(field);
                                var readOnly = !!(rec && rec.get('caseid'));
                                field.setReadOnly(readOnly);
                                syncDisabledStyle(readOnly);
                                setTooltip(readOnly);
                            };
                            syncReadOnly();
                            var formPanel = field.up('ehr-formpanel');
                            if (formPanel){
                                field.mon(formPanel, 'bindrecord', syncReadOnly, field, {buffer: 50});
                            }
                            if (EHR.DemographicsCache){
                                field.mon(EHR.DemographicsCache, 'casecreated', function(animalId){
                                    var rec = EHR.DataEntryUtils.getBoundRecord(field);
                                    if (rec && rec.get('Id') === animalId){
                                        field.setReadOnly(true);
                                        syncDisabledStyle(true);
                                        setTooltip(true);
                                    }
                                }, field);
                            }
                        }
                    }
                }
            }
        }
    }
});
