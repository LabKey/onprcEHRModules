/*
 * Copyright (c) 2012-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('EHR.reports');

//this contains ONPRC-specific reports that should be loaded on the animal history page
//this file is registered with EHRService, and should auto-load whenever EHR's
//dependencies are reuqested, provided this module is enabled

EHR.reports.hematology = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitle();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyPivot',
        title: "By Panel:",
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
        title: "Misc Tests:",
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    var resultsConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'Hematology Results',
        viewName: 'Plus Ref Range',
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
    var title = panel.getTitle();

    tab.add({
        html: 'This report summarizes the blood available for the animals below.  For more detail on this calculation, please see the PDF <a href=="https://bridge.ohsu.edu/research/onprc/dcm/DCM%20Standard%20Operatiing%20Procedures/Blood%20Collection%20Volume%20Guidelines.pdf" target="_blank">here</a>.',
        style: 'padding-bottom: 20px;'
    });

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'currentBloodSummary',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

};