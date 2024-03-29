/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg demographicsFilterArray
 * @cfg filterArray
 */

// Created: 11-10-2023  R. Blasa
Ext4.define('ONPRC_EHR.panel.ClinicalSummaryPanel', {
    extend: 'ONPRC_EHR.panel.BasicAggregationPanel',
    alias: 'widget.onprc_ehr-clinicalsummarypanel',

    border: false,
    defaults: {
        border: false
    },

    initComponent: function(){

        this.items = [
            Ext4.create('LDK.panel.WebpartPanel', {
                title: 'Clinical Summary',
                useDefaultPanel: true,
                items: [{
                    itemId: 'childPanel',
                    border: false,
                    defaults: {
                        border: false,
                        bodyStyle: 'background-color: transparent;'
                    },
                    items: [{
                        html: '<i class="fa fa-spinner fa-pulse"></i> loading...'
                    }]
                }]
            })
        ];

        this.callParent(arguments);

        this.loadData();
    },

    loadData: function(){
        var multi = new LABKEY.MultiRequest();

        multi.add(LABKEY.Query.selectRows, {
            requiredVersion: 9.1,
            schemaName: 'study',
            queryName: 'Demographics',
            filterArray: this.demographicsFilterArray,
            columns: ['Id'].join(','),
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: function(results){
                this.demographicsData = results;
            }
        });

        multi.add(LABKEY.Query.selectRows, {
            requiredVersion: 9.1,
            schemaName: 'study',
            queryName: 'Problem List', // TODO should change this to dataset name instead of label
            viewName: 'Unresolved Problems',
            filterArray: this.filterArray,
            columns: ['Id', 'date', 'category'].join(','),
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: function(results){
                this.problemData = this.aggregateResults(results, 'category');
            }
        });

        multi.add(LABKEY.Query.selectRows, {
            requiredVersion: 9.1,
            schemaName: 'study',
            queryName: 'cases',
            filterArray: [LABKEY.Filter.create('isActive', true, LABKEY.Filter.Types.EQUAL)].concat(this.filterArray),
            columns: ['Id', 'date', 'category'].join(','),
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: function(results){
                this.caseData = this.aggregateResults(results, 'category');
            }
        });

        multi.send(this.onLoad, this);
    },

    onLoad: function(){
        var target = this.down('#childPanel');
        target.removeAll();

        var cfg = {
            defaults: {
                border: false
            },
            items: []
        };

        var cases = this.appendSection('Open Cases', this.caseData, 'Id/activeCases/categories', 'contains');
        if (cases)
            cfg.items.push(cases);
        var problems = this.appendSection('Open Problems', this.problemData, 'Id/openProblems/problems', 'contains');
        if (problems)
            cfg.items.push(problems);

        if (!cfg.items.length){
            cfg.items.push({
                html: 'There are no open cases or problems'
            });
        }
        target.add(cfg);
    }
});