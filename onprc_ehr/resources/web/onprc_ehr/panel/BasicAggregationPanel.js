/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

// Created: 11-10-2023  R. Blasa

Ext4.define('ONPRC_EHR.panel.BasicAggregationPanel', {
    extend: 'Ext.panel.Panel',
// Created: 11-2-2023  R. Blasa
    aggregateResults: function(results, fieldName){
        if (!results || !results.rows || !results.rows.length)
            return;

        var object = {
            total: results.rows.length,
            aggregated: {},
            aggregateField: fieldName
        };

        Ext4.each(results.rows, function(row){
            var rs = new LDK.SelectRowsRow(row);
            var val = rs.getDisplayValue(fieldName);
            if (val === null){
                val = '';
            }

            if (!object.aggregated[val])
                object.aggregated[val] = 0;

            object.aggregated[val]++;
        }, this);

        return object;
    },

    getKeys: function(data){
        return Ext4.Object.getKeys(data.aggregated).sort();
    },

    appendSection: function(label, data, filterCol, operator){
        if (!data){
            return null;
        }

        var keys = this.getKeys(data);

        var rows = [];
        Ext4.each(keys, function(key){
            var rowLabel = key;
            rowLabel = Ext4.isEmpty(rowLabel) ? 'None' : rowLabel;
            if (rowLabel)
                rowLabel = rowLabel.replace(/\n/g, ' ');

            if (Ext4.isEmpty(rowLabel)){
                operator = 'isblank';
            }

            rows.push({
                html: rowLabel,
                style: 'padding-right: 10px;'
            });

            var val = data.aggregated[key];
            var displayVal = Ext4.isDefined(val) ? val.toString() : '';
            var url = displayVal ? this.generateUrl(displayVal, key, data, filterCol, operator) : null;

            rows.push({
                html:  EHR.Utils.getFormattedRowNumber(displayVal, url, false).html,
                style: 'padding: 2px;padding-right: 5px;text-align : right'
            });

            var pct;
            if (Ext4.isDefined(val)){
                //NOTE: this check was added to prevent JS errors.  I think this would only happen as an artifact of page loading, but am not 100% certain.  I was never able to repro it.
                pct = this.demographicsData ? val / this.demographicsData.rowCount : 0;
                pct = pct * 100;
                pct = Ext4.util.Format.round(pct, 2).toFixed(2);
                pct = pct.toString();
            }
            else {
                pct = '';
            }

            rows.push({
                html: pct,
                style: 'padding: 2px;padding-right: 5px;text-align : right'
            });
        }, this);

        return {
            border: false,
            defaults: {
                border: false,
                bodyStyle: 'background-color: transparent;'
            },
            items: [{
                html: '<h4>' + label + ':</h4>'
            },{
                cls: 'ehr-aggregationpanel-table',
                style: 'padding-left: 10px;padding-bottom: 10px;',
                layout: {
                    type: 'table',
                    columns: 3
                },
                border: false,
                defaults: {
                    border: false,
                    bodyStyle: 'background-color: transparent;'
                },
                items: [{
                    html: 'Category',
                    style: 'border-bottom: solid 1px;margin-right: 3px;margin-bottom:3px;'
                },{
                    html: 'Total',
                    style: 'border-bottom: solid 1px;margin-right: 3px;margin-left: 3px;margin-bottom:3px;text-align: center;padding-right: 10px;',
                    width: 80
                },{
                    html: '%',
                    style: 'border-bottom: solid 1px;margin-right: 3px;margin-left: 3px;margin-bottom:3px;text-align: center;padding-right: 10px;',
                    width: 80
                }].concat(rows)
            }]
        };
    },

    generateUrl: function(val, key, data, filterCol, operator){
        if (!val)
            return null;

        operator = operator || 'eq';

        var params = {
            schemaName: 'study',
            'query.queryName': 'Demographics',
            'query.viewName': 'By Location'
        };
        params = this.appendFilterParams(params);
        params['query.' + filterCol + '~' + operator] = key;

        return LABKEY.ActionURL.buildURL('query', 'executeQuery', null, params);
    },

    appendFilterParams: function(params){
        Ext4.each(this.filterArray, function(filter){
            params[filter.getURLParameterName()] = filter.getURLParameterValue();
        }, this);
        return params;
    }
})