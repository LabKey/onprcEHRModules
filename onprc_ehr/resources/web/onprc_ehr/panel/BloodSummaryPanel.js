/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @param subjects
*/
//This will correcc the various panels and graphs to implement the new method of work
//Need to change t
Ext4.define('ONPRC.panel.BloodSummaryPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc-bloodsummarypanel',

    initComponent: function(){
        Ext4.apply(this, {
            border: false,
            defaults: {
                border: false
            },
            items: [{
                html: 'Loading...'
            }]
        });

        this.callParent();

        this.loadData();
    },

    loadData: function(){
        var multi = new LABKEY.MultiRequest();

        multi.add(LABKEY.Query.selectRows, {
            schemaName: 'study',
            queryName: 'demographicsBloodSummary',
          //  viewName: 'newBloodCalc',
            filterArray: [LABKEY.Filter.create('id', this.subjects.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)],
     //       columns: 'id,species,species/blood_per_kg,species/max_draw_pct,species/blood_draw_interval,id/MostRecentWeight/mostRecentWeight,id/MostRecentWeight/mostRecentWeightDate,Id/demographics/calculated_status',
           columns: 'id,Species,Gender,MostRecentBCS,BCSDate,mostRecentWeight,mostRecentWeightDate,blood_draw_interval,bloodPrevious,bloodFuture,blood_per_kg,FixedRateCalculation,TotalBloodVolume,AllowableBlood,AvailableBlood,Method,Id/demographics/calculated_status',

            requiredVersion: 9.1,
            sort: 'id',
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: function(results){
                this.demographicsMap = {};
                Ext4.each(results.rows, function(row){
                    var map = new LDK.SelectRowsRow(row);
                    this.demographicsMap[map.getValue('id')] = map;
                }, this);
            }
        });

        multi.add(LABKEY.Query.selectRows, {
            schemaName: 'study',
            sort: 'Id,date',
            queryName: 'currentBloodDraws',
            filterArray: [LABKEY.Filter.create('Id', this.subjects.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)],
            parameters: {
                //NOTE: this is currently hard-coded for perf.
                DATE_INTERVAL: 21
            },
            requiredVersion: 9.1,
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: function(results){
                //these will be used for the blood graph
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
                this.bloodDrawResults = results;

                this.currentBloodMap = {};
                Ext4.each(results.rows, function(row){
                    var map = new LDK.SelectRowsRow(row);
                    var id = map.getValue('Id');

                    if (!this.currentBloodMap[id])
                        this.currentBloodMap[id] = [];

                    this.currentBloodMap[id].push(row);
                }, this);
            }
        });

        multi.send(this.onLoad, this);
    },

    onLoad: function(results){
        var toAdd = [];
        Ext4.each(this.subjects, function(subject){
            var dd = this.demographicsMap[subject];
            var bds = this.currentBloodMap[subject];

            var cfg = {
                xtype: 'ldk-webpartpanel',
                style: 'margin-bottom: 20px;',
                title: 'Blood Summary: ' + subject,
                defaults: {
                    border: false
                },
                items: []
            };

            if (!dd){
                cfg.items.push({
                    html: 'Either species or weight information is missing for this animal'
                });
            }
            else {
                var status = dd.getValue('Id/demographics/calculated_status');
                cfg.items.push({
                    html: '<b>Id: ' + dd.getValue('Id') + (status ? ' (' + status + ')' : '') + '</b>'
                });

                cfg.items.push({
                    html: '<hr>'
                });

                if (!bds || !bds.length) {
                    var maxDraw = dd.getValue('species/blood_per_kg') * dd.getValue('species/max_draw_pct') * dd.getValue('id/MostRecentWeight/mostRecentWeight');
                    cfg.items.push({
                        html: 'There are no previous or future blood draws with the relevant timeframe.  The maximum amount of ' + Ext4.util.Format.round(maxDraw, 2) + ' mL can be drawn.',
                        border: false
                    });
                }
                else {
                    cfg.items = cfg.items.concat(this.getGraphCfg(dd, bds));
                }
            }

            toAdd.push(cfg);
        }, this);

        this.removeAll();
        if (toAdd.length){
            this.add(toAdd);
        }
        else {
            this.add({
                html: 'No records found'
            });
        }
    },

    getGraphCfg: function(dd, bds){
        console.log(this.bloodDrawResults);

        var subject = dd.getValue('Id');
        var toAdd = [];
        var results = {
            metaData: this.bloodDrawResults.metaData,
            rows: bds
        };

        //this assumes we sorted on date
        var newRows = [];
        var rowPrevious;
        var seriesIds = [];
        var currentRow;
        Ext4.each(results.rows, function(row, idx){
            //capture the current day's amount
            var rowDate = new Date(row.date.value);
            if (rowDate && rowDate.format(LABKEY.extDefaultDateFormat) == (new Date()).format(LABKEY.extDefaultDateFormat)){
                currentRow = row;
            }

            row.allowableDisplay = row.allowableBlood;
            row.seriesId = {
                value: row.id.value + '/' + row.date.value
            };
            seriesIds.push(row.seriesId.value);

            //in order to mimic a stepped graph, add one new point per row using the date of the next draw
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
                var date = LDK.ConvertUtils.parseDate(row.date.value);
                date = Ext4.Date.add(date, Ext4.Date.DAY, 1);
                newRow.date.value = date.format('Y/m/d H:i:s');
                newRows.push(newRow);
            }
        }, this);

        results.rows = newRows;

        if (currentRow){
            toAdd.push({
                html: 'The amount of blood available if drawn today is: ' + Ext4.util.Format.round(currentRow.allowableDisplay.value, 1) + ' mL.  The graph below shows how the amount of blood available will change over time, including when previous draws will drop off.<br>',
                border: false,
                style: 'margin-bottom: 20px'
            });
        }

        toAdd.push({
            xtype: 'container',
            //title: 'Available Blood: ' + subject,
            items: [{
                xtype: 'ldk-graphpanel',
                margin: '0 0 0 0',
                plotConfig: {
                    results: results,
                    title: 'Blood Available To Be Drawn: ' + subject,
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

                            lines.push('Date: ' + row.date.format(LABKEY.extDefaultDateFormat));
                            lines.push('Drawn on this Date: ' + row.quantity);
                            lines.push('Volume Available on this Date: ' + LABKEY.Utils.roundNumber(row.allowableDisplay, 1) + ' mL');

                            lines.push('Current Weight: ' + row.mostRecentWeight + ' kg (' + row.mostRecentWeightDate.format(LABKEY.extDefaultDateFormat) + ')');

                            lines.push('Drawn in Previous ' + row.blood_draw_interval + ' days: ' + LABKEY.Utils.roundNumber(row.bloodPrevious, 1));
                            lines.push('Drawn in Next ' + row.blood_draw_interval + ' days: ' + LABKEY.Utils.roundNumber(row.bloodFuture, 1));


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
            }]
        });

        toAdd.push({
            html: '',
            border: false,
            style: 'margin-bottom: 10px;'
        });

        toAdd.push({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom: 10px;',
            queryConfig: LDK.Utils.getReadOnlyQWPConfig({
                title: 'Recent/Scheduled Blood Draws: ' + subject,
                schemaName: 'study',
                queryName: 'bloodDrawsByDay',
                allowHeaderLock: false,
                //frame: 'none',
                filters: [
                    LABKEY.Filter.create('Id', subject, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('date', '-' + (dd.getValue('species/blood_draw_interval') * 2) + 'd', LABKEY.Filter.Types.DATE_GREATER_THAN_OR_EQUAL)
                ],
                sort: '-date'
            })
        });

        toAdd.push({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom: 10px;',
            queryConfig: LDK.Utils.getReadOnlyQWPConfig({
                title: 'Pending/Not-Yet-Approved Blood Draws: ' + subject,
                schemaName: 'study',
                queryName: 'blood',
                allowHeaderLock: false,
                //frame: 'none',
                filters: [
                    LABKEY.Filter.create('Id', subject, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('countsAgainstVolume', false, LABKEY.Filter.Types.EQUAL)
                ],
                sort: '-date'
            })
        });

        toAdd.push({
            html: '',
            border: false,
            style: 'margin-bottom: 10px;'
        });

        return toAdd;
    }
});
