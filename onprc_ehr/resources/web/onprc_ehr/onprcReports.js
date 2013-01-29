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
    var title = panel.getTitleSuffix();

    tab.add({
        html: 'This report summarizes the blood available for the animals below.  For more detail on this calculation, please see the PDF <a href="https://bridge.ohsu.edu/research/onprc/dcm/DCM%20Standard%20Operatiing%20Procedures/Blood%20Collection%20Volume%20Guidelines.pdf" target="_blank">here</a>.',
        border: false,
        style: 'padding-bottom: 20px;'
    });


    var subjects = tab.filters.subjects || [];

    if (subjects.length){
        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'demographics',
            filterArray: [LABKEY.Filter.create('id', subjects.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)],
            columns: 'id,species,species/blood_per_kg,species/max_draw_pct,species/blood_draw_interval,id/MostRecentWeight/mostRecentWeight,id/MostRecentWeight/mostRecentWeightDate',
            sort: 'id',
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: function(result){
                Ext4.each(result.rows, function(row, idx){
                    var tabId = Ext4.id();
                    var subject = row.Id;

                    var cfg = {
                        border: false,
                        defaults: {
                            border: false
                        },
                        items: [{
                            html: '<b>Id: ' + row.Id + '</b>'
                        },{
                            html: '<hr>'
//                        },{
//                            html: [
//                                'Species: ' + row.species,
//                                'Allowable Blood Per Kg: ' + row['species/blood_per_kg'] + 'mL',
//                                'Percent of Body Weight: ' + row['species/max_draw_pct'] * 100,
//                                'Interval: ' + row['species/blood_draw_interval'] + ' days',
//                                'Last Weight: ' + row['id/MostRecentWeight/mostRecentWeight'] + ' kg (' + (new Date((row['id/MostRecentWeight/mostRecentWeightDate']))).format('Y-m-d') + ')'
//                            ].join('<br>'),
//                            style: 'padding-bottom: 10px;'
                        },{
                            itemId: tabId,
                            style: 'padding-bottom: 20px;',
                            items: [{
                                border: false,
                                html: 'Loading...'
                            }]
                        }]
                    }

                    LABKEY.Query.selectRows({
                        schemaName: 'study',
                        queryName: 'currentBloodDraws',
                        sort: 'Id,date',
                        filterArray: [LABKEY.Filter.create('Id', subject, LABKEY.Filter.Types.EQUAL)],
                        parameters: {
                            DATE_INTERVAL: row['species/blood_draw_interval'],
                            MAX_DRAW_PCT: row['species/max_draw_pct'],
                            ML_PER_KG: row['species/blood_per_kg']
                        },
                        requiredVersion: 9.1,
                        scope: this,
                        failure: LDK.Utils.getErrorCallback(),
                        success: Ext4.Function.pass(function(subj, tabId, results){
                            var target = tab.down('#' + tabId);
                            target.removeAll();
                            results.metaData.fields.push({
                                name: 'allowablePreviousDisplay',
                                jsonType: 'string'

                            });

                            //this assumes we sorted on date
                            var newRows = [];
                            var rowPrevious;
                            Ext4.each(results.rows, function(row, idx){
                                row.allowablePreviousDisplay = row.allowablePrevious;

                                //in order to mimick a stepped graph, add one new point per row using the date of the next draw
                                if (rowPrevious){
                                    var newRow = Ext4.apply({}, row);
                                    newRow.allowablePrevious = rowPrevious.allowablePrevious;
                                    newRows.push(newRow);
                                }
                                rowPrevious = row;

                                newRows.push(row);
                            }, this);
                            results.rows = newRows;

                            target.add({
                                xtype: 'ldk-graphpanel',
                                margin: '0 0 0 0',
                                title: 'Available Blood: ' + subj,
                                plotConfig: {
                                    results: results,
                                    title: 'Available Blood: ' + subj,
                                    height: 400,
                                    width: 800,
                                    yLabel: 'Available Blood (mL)',
                                    xLabel: 'Date',
                                    xField: 'date',
                                    grouping: ['id'],
                                    layers: [{
                                        y: 'allowablePrevious',
                                        hoverText: function(row){
                                            var lines = [];

                                            lines.push('Draw Date: ' + row.date.format('Y-m-d'));
                                            lines.push('Weight: ' + row.mostRecentWeight + ' kg');
                                            lines.push('Weight Date: ' + row.mostRecentWeightDate.format('Y-m-d'));
                                            lines.push('Max Allowable: ' + LABKEY.Utils.roundNumber(row.allowableBlood, 1) + ' mL');
                                            lines.push('Draw on this Date: ' + row.quantity);
                                            lines.push('Drawn in Previous ' + row.DATE_INTERVAL + ' days: ' + LABKEY.Utils.roundNumber(row.bloodPrevious, 1));
                                            lines.push('Drawn in Next ' + row.DATE_INTERVAL + ' days: ' + LABKEY.Utils.roundNumber(row.bloodFuture, 1));
                                            lines.push('Available on this Date: ' + LABKEY.Utils.roundNumber(row.allowablePreviousDisplay, 1) + ' mL');

                                            return lines.join('\n');
                                        },
                                        name: 'Volume'
                                    }]
                                },
                                //@Override
                                appendLayer: function(plot, layerConfig){
                                    var meta = this.findMetadata(layerConfig.y);
                                    var cfg = {
                                        geom: new LABKEY.vis.Geom.Point({size: 5}),
                                        name: layerConfig.name || meta.caption,
                                        aes: {
                                            y: function(row){
                                                return row[layerConfig.y]
                                            },
                                            hoverText: layerConfig.hoverText
                                        }
                                    }

                                    plot.addLayer(new LABKEY.vis.Layer(cfg));

                                    //now add segments
                                    plot.addLayer(new LABKEY.vis.Layer({
                                        geom: new LABKEY.vis.Geom.Path({size: 5, opacity: 2}),
                                        name: layerConfig.name || meta.caption,
                                        aes: {
                                            y: function(row){
                                                return row[layerConfig.y];
                                            },
                                            scales: {
                                                y: {
                                                    min: 0
                                                }
                                            },
                                            hoverText: layerConfig.hoverText
                                        }
                                    }));
                                }
                            });

//                            target.add({
//                                xtype: 'ldk-querypanel',
//                                style: 'margin-bottom: 10px;',
//                                queryConfig: panel.getQWPConfig({
//                                    title: 'Raw Data: ' + subject,
//                                    schemaName: 'study',
//                                    queryName: 'currentBloodDraws',
//                                    sort: 'Id,-date',
//                                    filterArray: [LABKEY.Filter.create('Id', subject, LABKEY.Filter.Types.EQUAL)],
//                                    parameters: {
//                                        DATE_INTERVAL: row['species/blood_draw_interval'],
//                                        MAX_DRAW_PCT: row['species/max_draw_pct'],
//                                        ML_PER_KG: row['species/blood_per_kg']
//                                    }
//                                })
//                            });

                            target.add({
                                xtype: 'ldk-querypanel',
                                style: 'margin-bottom: 10px;',
                                queryConfig: panel.getQWPConfig({
                                    title: 'Recent Blood Draws: ' + subject,
                                    schemaName: 'study',
                                    queryName: 'Blood Draws',
                                    filters: [
                                        LABKEY.Filter.create('Id', subject, LABKEY.Filter.Types.EQUAL),
                                        LABKEY.Filter.create('date', '-' + (row['species/blood_draw_interval'] * 2) + 'd', LABKEY.Filter.Types.DATE_GREATER_THAN_OR_EQUAL)
                                    ],
                                    sort: '-date'
                                })
                            });
                        }, [subject, tabId])
                    });

                    tab.add(cfg);
                }, this);
            }
        });
    }
};

EHR.reports.snapshot = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var tb = tab.getDockedItems('toolbar[dock="top"]');
    if(tb)
        tab.remove(tb);

    tab.add({
        xtype: 'ldk-multirecorddetailspanel',
        store: {
            schemaName: 'study',
            queryName: 'demographics',
            viewName: 'Snapshot',
            filterArray: filterArray.removable.concat(filterArray.nonRemovable)
        },
        detailsConfig: {
            columns: 2,
            DEFAULT_FIELD_WIDTH: 400
        },
        titleField: 'Id',
        titlePrefix: 'Details',
        multiToGrid: true,
        qwpConfig: panel.getQWPConfig({
            title: 'Snapshot'
        })
    });

    tab.add({
        border: false,
        height: 20
    });

    var config = panel.getQWPConfig({
        title: 'Other Notes' + title,
        frame: true,
        schemaName: 'study',
        queryName: 'notes',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    config = panel.getQWPConfig({
        title: 'Active Assignments' + title,
        frame: true,
        schemaName: 'study',
        queryName: 'Assignment',
        viewName: 'Active Assignments',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    config = panel.getQWPConfig({
        title: 'Master Problem List' + title,
        frame: true,
        schemaName: 'study',
        allowChooseView: true,
        queryName: 'Problem List',
        //sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    EHR.reports.weightGraph(panel, tab);
};