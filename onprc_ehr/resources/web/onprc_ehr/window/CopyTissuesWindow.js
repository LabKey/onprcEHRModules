/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.CopyTissuesWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        LABKEY.ExtAdapter.apply(this, {
            modal: true,
            closeAction: 'destroy',
            bodyStyle: 'padding: 5px;',
            title: 'Copy Tissues',
            width: 800,
            defaults: {
                border: false
            },
            items: this.getSearchItems(),
            buttons: [{
                text: 'Search',
                scope: this,
                handler: this.onSubmit
            },{
                text: 'Cancel',
                handler: function(btn){
                    btn.up('window').close();
                }
            }]
        });

        this.callParent(arguments);
    },

    getSearchItems: function(){
        return [{
            html: 'This helper allows you to copy a set of tissues previously used in any necropsy.  You can search by project, animal or recipient.  When you search, it will return all distinct sets of tissues matching your criteria, and you can choose which to use in this form.',
            style: 'padding-bottom: 10px;'
        },{
            xtype: 'textfield',
            fieldLabel: 'Animal Id',
            itemId: 'idField',
            width: 400
        },{
            xtype: 'ehr-projectfield',
            fieldLabel: 'Project',
            itemId: 'projectField',
            width: 400
        },{
            xtype: 'ehr-simplecombo',
            fieldLabel: 'Recipient',
            itemId: 'recipientField',
            valueField: 'rowId',
            displayField: 'lastName',
            schemaName: 'onprc_ehr',
            queryName: 'tissue_recipients',
            matchFieldWidth: false,
            forceSelection: true,
            sortFields: 'lastName',
            filterArray: [LABKEY.Filter.create('dateDisabled', null, LABKEY.Filter.Types.ISBLANK)],
            width: 400
        },{
            xtype: 'datefield',
            fieldLabel: 'Date Limit',
            itemId: 'dateField',
            value: Ext4.Date.add(new Date(), Ext4.Date.YEAR, -1)
        },{
            xtype: 'container',
            itemId: 'results',
            defaults: {
                border: false
            }
        }];
    },

    onSubmit: function(){
        var animal = this.down('#idField').getValue();
        var project = this.down('#projectField').getValue();
        var recipient = this.down('#recipientField').getValue();
        var date = this.down('#dateField').getValue();

        if (!animal && !project && !recipient){
            Ext4.Msg.alert('Error', 'Must enter either an animal Id, project or recipient');
            return;
        }

        var filterArray = [];
        if (animal){
            filterArray.push(LABKEY.Filter.create('Id', animal, LABKEY.Filter.Types.EQUAL));
        }

        if (project){
            filterArray.push(LABKEY.Filter.create('project', project, LABKEY.Filter.Types.EQUAL));
        }

        if (recipient){
            filterArray.push(LABKEY.Filter.create('recipient', recipient, LABKEY.Filter.Types.EQUAL));
        }

        if (date){
            filterArray.push(LABKEY.Filter.create('date', date, LABKEY.Filter.Types.DATE_GREATER_THAN_OR_EQUAL));
        }

        Ext4.Msg.wait('Loading...');
        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'tissueDistributions',
            columns: 'Id,tissue,tissue/meaning,project,project/displayName,project/investigatorId/lastName,recipient,recipient/lastname,dateOnly,parentid',
            sort: '-dateOnly,formSort',
            requiredVersion: 9.1,
            filterArray: filterArray,
            failure: LDK.Utils.getErrorCallback(),
            success: this.onLoad,
            scope: this
        });
    },

    onLoad: function(results){
        Ext4.Msg.hide();
        if (!results || !results.rows || !results.rows.length){
            Ext4.Msg.alert('No Records', 'No matching records found');
            return;
        }

        //first build a map showing each combination of codes
        var tissueMap = {};
        this.snomedMap = {};
        Ext4.Array.forEach(results.rows, function(r){
            var row = new LDK.SelectRowsRow(r);
            var key = [row.getValue('recipient/lastName'), row.getValue('Id'), row.getValue('dateOnly'), row.getValue('parentid')].join('<>');

            if (!tissueMap[key]){
                tissueMap[key] = {
                    rows: [],
                    orderedCodes: [],
                    recipients: [],
                    recipientIds: [],
                    titles: []
                };
            }

            if (!this.snomedMap[row.getValue('tissue')]){
                this.snomedMap[row.getValue('tissue')] = row.getValue('tissue/meaning');
            }

            tissueMap[key].rows.push(row);
            if (tissueMap[key].orderedCodes.indexOf(row.getValue('tissue')) == -1){
                tissueMap[key].orderedCodes.push(row.getValue('tissue'));
            }

            if (tissueMap[key].recipients.indexOf(row.getValue('recipient/lastName')) == -1){
                tissueMap[key].recipients.push(row.getValue('recipient/lastName'));
            }

            if (tissueMap[key].recipientIds.indexOf(row.getValue('recipient')) == -1){
                tissueMap[key].recipientIds.push(row.getValue('recipient'));
            }

            var title = row.getValue('recipient/lastName') + ' (' + row.getFormattedDateValue('dateOnly', 'Y-m-d') + ')';
            if (tissueMap[key].titles.indexOf(title) == -1){
                tissueMap[key].titles.push(title);
            }
        }, this);

        //then find all distinct combinations and present these
        var distinctCombinations = {};
        for (var key in tissueMap){
            var obj = tissueMap[key];
            var codeStr = Ext4.Array.clone(obj.orderedCodes).sort().join(';');
            if (!distinctCombinations[codeStr]){
                distinctCombinations[codeStr] = {
                    orderedCodes: obj.orderedCodes,
                    recipients: [],
                    recipientIds: [],
                    titles: [],
                    rows: []
                }
            }

            distinctCombinations[codeStr].rows.push(obj);

            distinctCombinations[codeStr].recipients = distinctCombinations[codeStr].recipients.concat(obj.recipients);
            distinctCombinations[codeStr].recipients = Ext4.Array.unique(distinctCombinations[codeStr].recipients);

            distinctCombinations[codeStr].recipientIds = distinctCombinations[codeStr].recipientIds.concat(obj.recipientIds);
            distinctCombinations[codeStr].recipientIds = Ext4.Array.unique(distinctCombinations[codeStr].recipientIds);

            distinctCombinations[codeStr].titles = distinctCombinations[codeStr].titles.concat(obj.titles);
            distinctCombinations[codeStr].titles = Ext4.Array.unique(distinctCombinations[codeStr].titles);
        }

        var toAdd = [];
        for (var combination in distinctCombinations){
            var tc = distinctCombinations[combination];
            var title = tc.recipients.length == 1 ? tc.recipients[0] : 'Multiple';

            var html = '';
            Ext4.Array.forEach(tc.titles, function(t){
                html += t + '<br>';
            }, this);
            html += '<br>';

            Ext4.Array.forEach(tc.orderedCodes, function(code){
                html += this.snomedMap[code] + ' (' + code + ')<br>'
            }, this);

            toAdd.push({
                title: title,
                bodyStyle: 'padding: 5px',
                items: [{
                    xtype: 'button',
                    text: 'Use This Set',
                    handler: function(btn){
                        var panel = btn.up('panel');
                        var codes = panel.orderedCodes;
                        var recipientId = panel.recipientIds.length == 1 ? panel.recipientIds[0] : null;
                        var win = btn.up('window');

                        var toAdd = [];
                        Ext4.Array.forEach(codes, function(c){
                            toAdd.push(win.targetStore.createModel({
                                tissue: c,
                                recipient: recipientId
                            }));
                        }, this);

                        if (toAdd.length){
                            win.targetStore.add(toAdd);
                            win.close();
                        }
                    }
                },{
                    html: html,
                    border: false,
                    style: 'padding-top: 10px;'
                }],
                orderedCodes: tc.orderedCodes,
                recipientIds: tc.recipientIds
            });
        };

        if (toAdd.length){
            var target = this.down('#results');
            target.removeAll();
            target.add({
                html: 'Total combinations: ' + toAdd.length,
                style: 'padding-bottom: 10px;'
            });

            target.add({
                xtype: 'tabpanel',
                items: toAdd
            })
        }
        else {
            Ext4.Msg.alert('No Results', 'No matching tissues were found');
        }
    }
});

EHR.DataEntryUtils.registerGridButton('COPY_TISSUES', function(config){
    config = config || {};

    return Ext4.Object.merge({
        text: 'Copy Previous Tissues',
        itemId: 'copyTissues',
        handler: function(btn){
            var grid = btn.up('gridpanel');
            LDK.Assert.assertNotEmpty('Unable to find gridpanel in COPY_TISSUES button', grid);

            Ext4.create('ONPRC_EHR.window.CopyTissuesWindow', {
                targetStore: grid.store
            }).show();
        }
    }, config);
});