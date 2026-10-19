/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('DrugField_Lock', {
    allQueries: {

    },
    byQuery: {
        'study.drug': {
            Id: {
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
                                var IDreadOnly = !!(rec && rec.get('Id'));
                                field.setReadOnly(IDreadOnly);
                                syncDisabledStyle(IDreadOnly);
                                setTooltip(IDreadOnly);

                                var DatereadOnly = !!(rec && rec.get('date'));
                                field.setReadOnly(DatereadOnly);
                                syncDisabledStyle(DatereadOnly);
                                setTooltip(DatereadOnly);
                            };
                            syncReadOnly();
                            var formPanel = field.up('ehr-formpanel');
                            if (formPanel){
                                field.mon(formPanel, 'bindrecord', syncReadOnly, field, {buffer: 50});
                            }

                        }
                    }
                }

            }

        }
    }
});