/*
 * Copyright (c) 2012-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('EHR.reports');

//this contains ONPRC-specific reports that should be loaded on the animal history page
//this file is registered with EHRService, and should auto-load whenever EHR's
//dependencies are requested, provided this module is enabled

EHR.reports.hematology = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    var miscConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyMisc',
        title: "Misc Tests" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: miscConfig
    });

    var resultsConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyRefRange',
        //viewName: 'Plus Ref Range',
        title: "Reference Ranges:",
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: resultsConfig
    });
};

EHR.reports.antibioticSensitivity = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'antibioticSensitivityPivoted',
        title: "Common Antibiotics" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    var miscConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'antibioticSensitivityMisc',
        title: "Misc Antibiotics" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: miscConfig
    });
};

EHR.reports.iStat = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'iStatPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    var miscConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'iStatMisc',
        title: "Misc Tests" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: miscConfig
    });

    var resultsConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'iStatRefRange',
        title: "Reference Ranges:",
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: resultsConfig
    });
}

EHR.reports.currentBlood = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        html: 'This report summarizes the blood available for the animals below.  For more detail on this calculation, please see the PDF <a href="https://bridge.ohsu.edu/research/onprc/dcm/DCM%20Standard%20Operatiing%20Procedures/Blood%20Collection%20Volume%20Guidelines.pdf" target="_blank">here</a>.' +
                '<br><br>If there have been recent blood draws for the animal, a graph will show the available blood over time.  On the graph, dots indicate dates when either blood was drawn or a previous blood draw fell off.  The horizontal lines indicate the maximum allowable blood that can be drawn on that date.',
        border: false,
        style: 'padding-bottom: 20px;'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom: 10px;',
        queryConfig: panel.getQWPConfig({
            title: 'Summary',
            schemaName: 'study',
            queryName: 'Demographics',
            viewName: 'Blood Draws',
            filterArray: filterArray.removable.concat(filterArray.nonRemovable)
        })
    });

    var subjects = tab.filters.subjects || [];

    if (subjects.length){
        tab.add({
            xtype: 'onprc-bloodsummarypanel',
            subjects: subjects
        });
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, function(subjects, tab){
            tab.add({
                xtype: 'onprc-bloodsummarypanel',
                subjects: subjects
            });
        }, this);
    }
};

EHR.reports.clinMedicationSchedule = function(panel, tab){
    EHR.reports.medicationSchedule(panel, tab, 'Clinical Medications');
};

EHR.reports.dietSchedule = function(panel, tab){
    EHR.reports.medicationSchedule(panel, tab, 'Diets');
};

EHR.reports.surgMedicationSchedule = function(panel, tab){
    EHR.reports.medicationSchedule(panel, tab, 'Surgical Medications');
};

EHR.reports.incompleteTreatments = function(panel, tab){
    EHR.reports.medicationSchedule(panel, tab, 'Incomplete Treatments');
};

EHR.reports.medicationSchedule = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var date = (new Date()).format('Y-m-d');
    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'treatmentSchedule',
            viewName: viewName,
            title: viewName + ' ' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            parameters: {
                StartDate: date,
                NumDays: 1
            }
        })
    });
}

EHR.reports.bloodSchedule = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    filterArray.removable = filterArray.removable || [];
    filterArray.removable.push(LABKEY.Filter.create('date', new Date(), LABKEY.Filter.Types.DATE_EQUAL));

    filterArray.nonRemovable = filterArray.nonRemovable || [];
    filterArray.nonRemovable.push(LABKEY.Filter.create('qcstate/label', 'Request:', LABKEY.Filter.Types.STARTS_WITH));

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'blood',
            viewName: 'Requests',
            title: 'Daily Blood Schedule' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });
}

EHR.reports.pairHistory = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var date = (new Date()).add(Date.YEAR, -5).format('Y-m-d');
    tab.add({
        html: 'This report summarizes all animals paired in a cage in the past 5 years, along with any pairing comments entered during this time period.  Note: periods of group housing are not displayed on this report.',
        border: false,
        style: 'padding-bottom: 20px;'
    },{
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'pairHistory',
            title: 'Pair History' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            parameters: {
                StartDate: date
            }
        })
    });
}

EHR.reports.underConstruction = function(panel, tab){
    tab.add({
        html: 'This report is being developed and should be added soon',
        border: false
    });
};

EHR.reports.potentialParents = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        border: false,
        style: 'padding-bottom: 20px;',
        html: 'This report calculates potential parents for the selected animal(s).  The potential parents are determined as follows:' +
            '<br><br>' +
            '<ul style="margin-left: 20px">' +
            '<li style="list-style-type: disc;">Potential dams are determined by finding any female housed in the animal\'s birth location at the time of birth, which were at least 2.5 years old at the time</li>' +
            '<li style="list-style-type: disc;">Potential sires are determined by finding the locations where all potential dams were housed during the conception window (defined below) relative to the animal\'s birth.  The potential sires are any male animals housed in these locations during the conception window, which are at least 2.5 years old at the time.</li>' +
            '</ul>'
    });

    tab.add({
        xtype: 'panel',
        ownerTabbedPanel: panel,
        itemId: 'potentialParents',
        border: false,
        items: [{
            itemId: 'filterArea',
            style: 'padding-bottom: 10px;',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                layout: 'hbox',
                defaults: {
                    border: false
                },
                items: [{
                    html: 'Choose Conception Range (Days Prior To Birth):',
                    style: 'padding-bottom: 10px;'
                },{
                    xtype: 'numberfield',
                    hideTrigger: true,
                    itemId: 'rangeMin',
                    style: 'margin-left: 10px;',
                    value: 155
                },{
                    html: 'through',
                    style: 'margin-left: 10px;'
                },{
                    xtype: 'numberfield',
                    itemId: 'rangeMax',
                    style: 'margin-left: 10px;',
                    hideTrigger: true,
                    value: 180
                }]
            }],
            buttonAlign: 'left',
            buttons: [{
                text: 'Submit',
                handler: function(btn){
                    var panel = btn.up('#potentialParents');
                    var rangeMin = panel.down('#rangeMin').getValue();
                    var rangeMax = panel.down('#rangeMax').getValue();

                    if (Ext4.isEmpty(rangeMin) || Ext4.isEmpty(rangeMax)){
                        Ext4.Msg.alert('Error', 'Must provide a range');
                        return;
                    }

                    var target = panel.down('#target');
                    target.removeAll();

                    target.add({
                        xtype: 'ldk-querypanel',
                        style: 'margin-bottom:20px;',
                        queryConfig: panel.ownerTabbedPanel.getQWPConfig({
                            schemaName: 'study',
                            queryName: 'potentialDams',
                            title: "Potential Dams" + title,
                            filters: filterArray.nonRemovable,
                            removeableFilters: filterArray.removable
                        })
                    });

                    target.add({
                        xtype: 'ldk-querypanel',
                        style: 'margin-bottom:20px;',
                        queryConfig: panel.ownerTabbedPanel.getQWPConfig({
                            schemaName: 'study',
                            queryName: 'potentialSires',
                            title: "Potential Sires" + title,
                            filters: filterArray.nonRemovable,
                            removeableFilters: filterArray.removable,
                            parameters: {
                                RangeMin: rangeMin,
                                RangeMax: rangeMax
                            }
                        })
                    });
                }
            }]
        },{
            border: false,
            defaults: {
                border: false
            },
            itemId: 'target'
        }],
    })
};

EHR.reports.reproSummary = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'reproSummary',
            title: "Repro Summary" + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });

    tab.add({
        xtype: 'panel',
        bodyStyle: 'padding: 10px;',
        border: false,
        defaults: {
            border: false
        },
        items: [{
            html: '<b>Key:</b>',
            style: 'padding-bottom: 5px;'
        },{
            html: 'C: C-Section'
        },{
            html: 'F: Fetus Not Recovered'
        },{
            html: 'M: Menses'
        },{
            html: 'N: No Delivery - Fetus Recovered'
        },{
            html: 'R: Resorbtion'
        },{
            html: 'T: Timed Mating'
        },{
            html: 'V: Vaginal'
        },{
            html: '*: Other Mating'
        }]
    });
};


EHR.reports.delivery = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        html: 'This tab was essentially redundant with the Offspring tab (to the right).  The only difference is that the Offspring tab also includes genetic offspring (lacking the observed mother), and that report also included the outcome of the birth.  Please use the other report, and this tab will be removed after Oct 17th.',
        border: false,
        style: 'padding-bottom: 20px;'
    });
};

EHR.reports.measurementsPivoted = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsPivotedFetal',
            title: 'Fetal Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsPivotedPlacental',
            title: 'Placental Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsPivotedHeart',
            title: 'Heart Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsPivotedBody',
            title: 'Body Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsMisc',
            title: 'Misc Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });
};


