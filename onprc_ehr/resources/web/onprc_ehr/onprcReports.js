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
        queryConfig: miscConfig
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
        html: 'This report summarizes the blood available for the animals below.  For more detail on this calculation, please see the PDF <a href="https://bridge.ohsu.edu/research/onprc/dcm/DCM%20Standard%20Operatiing%20Procedures/Blood%20Collection%20Volume%20Guidelines.pdf" target="_blank">here</a>.' +
                '<br><br>If there have been recent blood draws for the animal, a graph will show the available blood over time.  On the graph, dots indicate dates when either blood was drawn or a previous blood draw fell off.  The horizontal lines indicate the maximum allowable blood that can be drawn on that date.',
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
                if (!result.rows || !result.rows.length){
                    tab.add({
                        html: 'Either species or weight information is missing from the selected animals',
                        border: false
                    });

                    return;
                }

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
                        success: Ext4.Function.pass(function(subj, idRow, tabId, results){
                            var target = tab.down('#' + tabId);
                            target.removeAll();

                            if (!results.rows || results.rows.length <= 1){
                                var maxDraw = idRow['species/blood_per_kg'] * idRow['species/max_draw_pct'] * idRow['id/MostRecentWeight/mostRecentWeight']
                                target.add({
                                    html: 'There are no previous or future blood draws with the relevant timeframe.  The maximum amount of ' + maxDraw + ' mL can be drawn.',
                                    border: false
                                });
                                return;
                            }

                            results.metaData.fields.push({
                                name: 'allowableDisplay',
                                jsonType: 'string'
                            });
                            results.metaData.fields.push({
                                name: 'seriesId',
                                jsonType: 'string'
                            });
                            results.metaData.fields.push({
                                name: 'isHidden',
                                jsonType: 'boolean'
                            });

                            //this assumes we sorted on date
                            var newRows = [];
                            var rowPrevious;
                            var seriesIds = [];
                            Ext4.each(results.rows, function(row, idx){
                                row.allowableDisplay = row.allowableBlood;
                                row.seriesId = {
                                    value: row.id.value + '/' + row.date.value
                                };
                                seriesIds.push(row.seriesId.value);

                                //in order to mimick a stepped graph, add one new point per row using the date of the next draw
                                if (rowPrevious){
                                    var newRow = Ext4.apply({}, row);
                                    newRow.allowableBlood = rowPrevious.allowableBlood;
                                     newRow.seriesId = rowPrevious.seriesId;
                                    newRow.isHidden = {value: true};
                                    newRows.push(newRow);
                                }
                                rowPrevious = row;
                                newRows.push(row);

                                //always append one additional datapoint in order to emphasize the ending
                                if (idx == (results.rows.length - 1)){
                                    var newRow = Ext4.Object.merge({}, row);
                                    newRow.isHidden = {value: true};
                                    var date = new Date(Date.parse(row.date.value));
                                    date = Ext4.Date.add(date, Ext4.Date.DAY, 1);
                                    newRow.date.value = date.format('Y-m-d');
                                    newRows.push(newRow);
                                }
                            }, this);

                            results.rows = newRows;

                            target.add({
                                xtype: 'ldk-graphpanel',
                                margin: '0 0 0 0',
                                title: 'Available Blood: ' + subj,
                                plotConfig: {
                                    results: results,
                                    title: 'Blood Available To Be Drawn: ' + subj,
                                    height: 400,
                                    width: 800,
                                    yLabel: 'Available Blood (mL)',
                                    xLabel: 'Date',
                                    xField: 'date',
                                    grouping: ['seriesId'],
                                    layers: [{
                                        y: 'allowableBlood',
                                        hoverText: function(row){
                                            var lines = [];

                                            lines.push('Date: ' + row.date.format('Y-m-d'));
                                            lines.push('Drawn on this Date: ' + row.quantity);
                                            lines.push('Volume Available on this Date: ' + LABKEY.Utils.roundNumber(row.allowableDisplay, 1) + ' mL');

                                            lines.push('Weight: ' + row.mostRecentWeight + ' kg (' + row.mostRecentWeightDate.format('Y-m-d') + ')');
                                            //lines.push('Max Allowable: ' + LABKEY.Utils.roundNumber(row.maxAllowableBlood, 1) + ' mL');

                                            lines.push('Drawn in Previous ' + row.DATE_INTERVAL + ' days: ' + LABKEY.Utils.roundNumber(row.bloodPrevious, 1));
                                            lines.push('Drawn in Next ' + row.DATE_INTERVAL + ' days: ' + LABKEY.Utils.roundNumber(row.bloodFuture, 1));


                                            return lines.join('\n');
                                        },
                                        name: 'Volume'
                                    }]
                                },
                                getPlotConfig: function(){
                                    var cfg = LDK.panel.GraphPanel.prototype.getPlotConfig.call(this);
                                    cfg.legendPos = 'none';
                                    cfg.aes.color = null;
                                    cfg.aes.shape = null;

                                    return cfg;
                                },

                                //@Override
                                appendLayer: function(plot, layerConfig){
                                    var meta = this.findMetadata(layerConfig.y);
                                    plot.addLayer(new LABKEY.vis.Layer({
                                        geom: new LABKEY.vis.Geom.Point({size: 5}),
                                        name: layerConfig.name || meta.caption,
                                        aes: {
                                            y: function(row){
                                                if (row.isHidden)
                                                    return null;

                                                return row[layerConfig.y]
                                            },
                                            hoverText: layerConfig.hoverText
                                        }
                                    }));

                                    //now add segments.  this is an odd way to accomplish grouping, but
                                    //otherwise Vis will give each segment a different color
                                    Ext4.each(seriesIds, function(seriesId){
                                        plot.addLayer(new LABKEY.vis.Layer({
                                            geom: new LABKEY.vis.Geom.Path({size: 5, opacity: 2}),
                                            name: layerConfig.name || meta.caption,
                                            aes: {
                                                y: function(row){
                                                    if (row.seriesId != seriesId)
                                                        return null;

                                                    return row[layerConfig.y];
                                                },
                                                group: 'none'
                                            }
                                        }));
                                    }, this);
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
                        }, [subject, row, tabId])
                    });

                    tab.add(cfg);
                }, this);
            }
        });
    }
    else
    {
        tab.add({
            border: false,
            html: 'This report cannot be loaded using the selected filter type.  Please choose either a single subject or multiple subjects'
        })
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