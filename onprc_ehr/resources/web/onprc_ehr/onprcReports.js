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
        sort: '-date',
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

EHR.reports.snapshot = function(panel, tab){
    if (tab.filters.subjects){
        renderSubjects(tab.filters.subjects, tab);
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, renderSubjects, this);
    }

    function renderSubjects(subjects, tab){
        var toAdd = [];
        if (!subjects.length){
            toAdd.push({
                html: 'No animals were found.',
                border: false
            });
        }
        else if (subjects.length < 10) {
            for (var i=0;i<subjects.length;i++){
                toAdd.push({
                    xtype: 'ldk-webpartpanel',
                    title: 'Overview: ' + subjects[i],
                    items: [{
                        xtype: 'ehr-snapshotpanel',
                        showExtendedInformation: true,
                        hrefTarget: '_blank',
                        border: false,
                        subjectId: subjects[i]
                    }]
                });

                toAdd.push({
                    border: false,
                    height: 20
                });

                toAdd.push(EHR.reports.renderWeightData(panel, tab, subjects[i]));
            }
        }
        else {
            toAdd.push({
                html: 'Because more than 10 subjects were selected, the condensed report is being shown.  Note that you can click the animal ID to open this same report in a different tab, showing that animal in more detail or click the link labeled \'Display History\'.',
                style: 'padding-bottom: 20px;',
                border: false
            });

            var filterArray = panel.getFilterArray(tab);
            var title = panel.getTitleSuffix();
            toAdd.push({
                xtype: 'ldk-querypanel',
                style: 'margin-bottom:20px;',
                queryConfig: {
                    title: 'Overview' + title,
                    schemaName: 'study',
                    queryName: 'demographics',
                    viewName: 'Snapshot',
                    filterArray: filterArray.removable.concat(filterArray.nonRemovable)
                }
            });
        }

        if (toAdd.length)
            tab.add(toAdd);
    }

};

EHR.reports.clinicalHistory = function(panel, tab){
    if (tab.filters.subjects){
        renderSubjects(tab.filters.subjects, tab);
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, renderSubjects, this);
    }

    function renderSubjects(subjects, tab){
        if (subjects.length > 10){
            tab.add({
                html: 'Because more than 10 subjects were selected, the condensed report is being shown.  Note that you can click the animal ID to open this same report in a different tab, showing that animal in more detail or click the link labeled \'Display History\'.',
                style: 'padding-bottom: 20px;',
                border: false
            });

            var filterArray = panel.getFilterArray(tab);
            var title = panel.getTitleSuffix();
            tab.add({
                xtype: 'ldk-querypanel',
                style: 'margin-bottom:20px;',
                queryConfig: {
                    title: 'Overview' + title,
                    schemaName: 'study',
                    queryName: 'demographics',
                    viewName: 'Snapshot',
                    filterArray: filterArray.removable.concat(filterArray.nonRemovable)
                }
            });

            return;
        }

        if (!subjects.length){
            tab.add({
                html: 'No animals were found.',
                border: false
            });

            return;
        }

        var minDate = Ext4.Date.add(new Date(), Ext4.Date.YEAR, -2);
        var toAdd = [];
        Ext4.each(subjects, function(s){
            toAdd.push({
                html: '<span style="font-size: large;"><b>Animal: ' + s + '</b></span>',
                style: 'padding-bottom: 20px;',
                border: false
            });

            toAdd.push({
                xtype: 'ehr-smallformsnapshotpanel',
                hrefTarget: '_blank',
                border: false,
                subjectId: s
            });

            toAdd.push({
                html: '<b>Chronological History:</b><hr>',
                style: 'padding-top: 5px;',
                border: false
            });

            toAdd.push({
                xtype: 'ehr-clinicalhistorypanel',
                border: true,
                subjectId: s,
                autoLoadRecords: true,
                minDate: minDate,
                //maxGridHeight: 1000,
                hrefTarget: '_blank',
                style: 'margin-bottom: 20px;'
            });
        }, this);

        if (toAdd.length){
            tab.add(toAdd);
        }
    }
}

EHR.reports.treatmentSchedule = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var date = (new Date()).format('Y-m-d');
    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'treatmentSchedule',
            title: 'Treatment Schedule ' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            parameters: {
                StartDate: date,
                NumDays: 0
            }
        })
    });
}

EHR.reports.bloodSchedule = function(panel, tab){
    tab.add({
        html: 'This report will show a schedule of blood draws to be performed today.  This will be added once blood draws are required through PRIMe.',
        border: false
    });
}

EHR.reports.underConstruction = function(panel, tab){
    tab.add({
        html: 'This report is being developed and should be added soon',
        border: false
    });
}

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
            removeableFilters: filterArray.removable,
            sort: 'Id,-year,monthnum'
        })
    });

}