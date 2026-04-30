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
                            var TOOLTIP = 'Case opened for this animal, cannot change animal Id.';
                            var setTooltip = function(disabled){
                                var el = field.getEl();
                                if (el){
                                    el.set({'data-qtip': disabled ? TOOLTIP : ''});
                                }
                            };
                            var syncDisabled = function(){
                                var rec = EHR.DataEntryUtils.getBoundRecord(field);
                                var disabled = !!(rec && rec.get('caseid'));
                                field.setDisabled(disabled);
                                setTooltip(disabled);
                            };
                            syncDisabled();
                            var formPanel = field.up('ehr-formpanel');
                            if (formPanel){
                                field.mon(formPanel, 'bindrecord', syncDisabled, field, {buffer: 50});
                            }
                            if (EHR.DemographicsCache){
                                field.mon(EHR.DemographicsCache, 'casecreated', function(animalId){
                                    var rec = EHR.DataEntryUtils.getBoundRecord(field);
                                    if (rec && rec.get('Id') === animalId){
                                        field.setDisabled(true);
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
