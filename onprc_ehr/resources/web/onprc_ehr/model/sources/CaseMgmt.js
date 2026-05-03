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
                            var TOOLTIP = 'A case has been opened in this form for this animal. All records in the form will be collected toward that case. Cannot change animal Id.';
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
