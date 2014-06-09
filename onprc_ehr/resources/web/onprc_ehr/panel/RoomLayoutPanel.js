/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * There are two ways to use this panel.  It can be created directly like a typical panel by passing a filterArray.
 * This will create one section per room.  However, since it is also used to printing there is a second approach.
 * In print mode, we want 1 page per room.  Introducing page breaks is problematic across browsers, especially when
 * trying to introduce them within a panel.  Therefore, you can call getPanelSections to return an array of items
 * with 1 item per prinable page.  Code can then create separate top-level panels, which browsers seem to treat
 * better for page breaks
 */
Ext4.define('ONPRC.panel.RoomLayoutPanel', {
    extend: 'Ext.panel.Panel',
    printMode: false,

    statics: {
        getPanelSections: function(filterArray, callback, scope){
            var ret = {};
            var multi = new LABKEY.MultiRequest();
            var filters = [].concat(filterArray);
            filters.push(LABKEY.Filter.create('room/housingType/value', 'Cage Location;Group Location', LABKEY.Filter.Types.EQUALS_ONE_OF));
            filters.push(LABKEY.Filter.create('cage', null, LABKEY.Filter.Types.NONBLANK));

            multi.add(LABKEY.Query.selectRows, {
                schemaName: 'ehr_lookups',
                queryName: 'divider_types',
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: function(results){
                    ret.dividerMap = {};

                    if (results && results.rows && results.rows.length){
                        Ext4.Array.forEach(results.rows, function(r){
                            ret.dividerMap[r.rowid] = r;
                        }, this);
                    }
                }
            });

            multi.add(LABKEY.Query.selectRows, {
                schemaName: 'ehr_lookups',
                queryName: 'cage_type',
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: function(results){
                    ret.cageTypeMap = {};

                    if (results && results.rows && results.rows.length){
                        Ext4.Array.forEach(results.rows, function(r){
                            ret.cageTypeMap[r.cagetype] = r;
                        }, this);
                    }
                }
            });

            multi.add(LABKEY.Query.selectRows, {
                schemaName: 'ehr_lookups',
                queryName: 'cage',
                filterArray: filters,
                sort: 'room/sort_order,cagePosition/sort_order',
                columns: 'location,room,cage,cage_type,divider,cagePosition/row,cagePosition/columnIdx,cagePosition/sort_order,totalAnimals/animals,status',
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: function(results){
                    ret.cageStore = Ext4.create('Ext.data.ArrayStore', {
                        fields: [
                            {name: 'location', type: 'string'},
                            {name: 'room', type: 'string'},
                            {name: 'cage', type: 'string'},
                            {name: 'cage_type', type: 'string'},
                            {name: 'status', type: 'string'},
                            {name: 'divider', type: 'int'},
                            {name: 'cagePosition/row', type: 'string'},
                            {name: 'cagePosition/columnIdx', type: 'int'},
                            {name: 'cagePosition/sort_order', type: 'int'},
                            {name: 'totalAnimals/animals', type: 'string'}
                        ]
                    });

                    Ext4.Array.forEach(results.rows, function(r){
                        ret.cageStore.add(ret.cageStore.createModel(r));
                    }, this);
                }
            });

            var animalFilter = [].concat(filterArray);
            animalFilter.push(LABKEY.Filter.create('isActive', true));

            multi.add(LABKEY.Query.selectRows, {
                schemaName: 'study',
                queryName: 'housing',
                filterArray: animalFilter,
                requiredVersion: 9.1,
                sort: 'cage',
                columns: 'Id,room,cage,Id/demographics/species,Id/demographics/gender,Id/mostRecentWeight/mostRecentWeight',
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: function(results){
                    ret.animalResults = results;

                    ret.animalMap = {};
                    Ext4.Array.forEach(results.rows, function(row){
                        var sr = new LDK.SelectRowsRow(row);
                        ret.animalMap[sr.getValue('Id')] = sr;
                    }, this);
                }
            });

            multi.send(function(){
                callback.call(scope, ret);
            }, this);
        },

        getRowNumber: function(letter){
            return Ext4.isEmpty(letter) ? 0 : letter.toUpperCase().charCodeAt(0) - 65;
        },

        getRowBlockCfg: function(maxCage){
            return {
                layout: {
                    type: 'table',
                    columns: (maxCage * 2) - 1
                },
                items: []
            }
        },

        getRoomItems: function(config){
            var toAdd = [];

            if (!config.cageStore || !config.cageStore.getCount()){
                toAdd.push({
                    html: 'No cages found'
                });
            }
            else {
                if (!config.printMode){
                    toAdd.push({
                        border: false,
                        style: 'margin-bottom: 10px;',
                        html: 'NOTE: Click on either the cage or divider for more information.  A yellow divider indicates the cages are paired.  A black divider indicates the cages are separate.  Cages are colored green when they are empty.  Yellow cages have been flagged as unavailable.'
                    });
                }

                var roomMap = {};
                var colIdxs = {};
                var maxCageMap = {};
                var invertedMap = {};
                config.cageStore.each(function(row){
                    var room = row.get('room');
                    var maxCage = maxCageMap[room] || 0;
                    var letter = row.get('cagePosition/row');
                    var letterNum = ONPRC.panel.RoomLayoutPanel.getRowNumber(letter);
                    var isInverted = config.doRowInversion ? (Math.round(letterNum / 4) == 1) : false;
                    invertedMap[letter] = isInverted;

                    var col = row.get('cagePosition/columnIdx');

                    var cageMap = roomMap[room] || {};

                    if (!cageMap[letter])
                        cageMap[letter] = {};

                    colIdxs[col] = 1;
                    if (col > maxCage){
                        maxCage = col;
                        maxCageMap[room] = maxCage
                    }

                    cageMap[letter][col] = row;

                    roomMap[room] = cageMap;
                }, this);

                var rooms = Ext4.Object.getKeys(roomMap).sort();
                var dividerWidth = 3;
                var height = 115;
                var cageWidth = 65;
                var hasCages = false;

                Ext4.each(rooms, function(room, roomIdx){
                    if (roomIdx == 0 && !config.printMode){
                        toAdd.push(ONPRC.panel.RoomLayoutPanel.getButtonCfgs(config));
                        toAdd.push({
                            style: 'margin-bottom: 20px;',
                            border: false
                        });
                    }

                    var cageMap = roomMap[room];
                    var maxCage = maxCageMap[room];
                    var rowIdxs = Ext4.Object.getKeys(cageMap).sort();

                    var rowBlocks = [];
                    var table = ONPRC.panel.RoomLayoutPanel.getRowBlockCfg(maxCage);
                    var currentSection = [];
                    rowBlocks.push({
                        border: false,
                        defaults: {
                            border: false
                        },
                        items: currentSection
                    });

                    var prevRowOrientation = null;
                    Ext4.each(rowIdxs, function(ri, rowIdx){
                        var cages = cageMap[ri];
                        var rowItems = [];
                        var isInverted = invertedMap[ri] === true;

                        if ((rowIdx % 4) == 0){
                            if (rowIdx > 0){
                                currentSection = [];
                                rowBlocks.push({
                                    border: false,
                                    defaults: {
                                        border: false
                                    },
                                    items: currentSection
                                });
                            }

                            //only show header if this is the 1st row or in print mode
                            if (config.printMode || rowIdx == 0){
                                currentSection.push({
                                    html: '<b>Room: ' + room + '</b>',
                                    style: 'margin-bottom: 10px;',
                                    border: false
                                });

                                currentSection.push({
                                    html: 'Note: a solid line indicates a solid divider, dotted line indicates mesh, and dashed indicates grooming contact.',
                                    style: 'margin-bottom: 10px;',
                                    border: false
                                });
                            }

                            table = ONPRC.panel.RoomLayoutPanel.getRowBlockCfg(maxCage);
                            currentSection.push(table);
                        }
                        else if(rowIdx > 0 && (rowIdx % 2) == 0){
                            currentSection.push({
                                border: false,
                                height: 30
                            });
                        }
                        prevRowOrientation = isInverted;

                        for (var colIdx = 1;colIdx<=maxCage;colIdx++){
                            var row = cages[colIdx];
                            if (row){
                                var animals = row.get('totalAnimals/animals');
                                if (!Ext4.isArray(animals)){
                                    animals = animals || '';
                                    animals = animals.replace(/\n/g, ',');
                                    animals = animals.split(',');
                                }

                                var animalItems = [];
                                if (animals.length > 4){
                                    animalItems.push({
                                        html: '<span style="font-size: 10px;">' + animals.length + ' animals</span>',
                                        border: false,
                                        bodyStyle: {
                                            'background-color': 'transparent'
                                        }
                                    });
                                }
                                else if (animals.length){
                                    Ext4.each(animals, function(animal){
                                        animalItems.push({
                                            html: '<span style="font-size: 9px;"><a>' + animal + '</a>' + (config.animalMap[animal] ? ': ' + Ext4.util.Format.round(config.animalMap[animal].getValue('Id/mostRecentWeight/mostRecentWeight'), 1) : '') + '</span>',
                                            animal: animal,
                                            border: false,
                                            bodyStyle: {
                                                'background-color': 'transparent'
                                            },
                                            listeners: {
                                                scope: this,
                                                afterrender: function(cmp){
                                                    cmp.getEl().on('click', function(el){
                                                        EHR.window.ClinicalHistoryWindow.showClinicalHistory(null, cmp.animal, null);
                                                    }, this);
                                                }
                                            }
                                        });
                                    }, this);
                                }

                                var dividerInfo = config.dividerMap[row.get('divider')] || {};
                                LDK.Assert.assertNotEmpty('No divider info for cage: ' + row.get('location'), config.dividerMap[row.get('divider')]);
                                var isSeparate = !!dividerInfo.countAsSeparate;
                                var isPaired = !!dividerInfo.countAsPaired;

                                var lb = colIdx == 1 ? 2 : 0;
                                var rb = colIdx == maxCage ? 2 : 0;
                                if (isInverted){
                                    var tmp = lb;
                                    lb = rb;
                                    rb = tmp;
                                }

                                var bgColor = '';
                                var emptyCageColor = '#00EE00';
                                var prevCage = (colIdx > 1) ? cages[colIdx - 1] : null;
                                var cageType = row.get('cage_type');
                                var status = row.get('status');
                                var cageAnimals = row.get('totalAnimals/animals');
                                if (prevCage){
                                    var prevDividerInfo = config.dividerMap[prevCage.get('divider')] || {};
                                    LDK.Assert.assertNotEmpty('No divider info for previous cage: ' + prevCage.get('location'), config.dividerMap[prevCage.get('divider')]);

                                    var prevIsSeparate = prevDividerInfo.countAsSeparate;
                                    var prevAnimals = prevCage.get('totalAnimals/animals');

                                    if (!prevIsSeparate && !Ext4.isEmpty(cageAnimals))
                                        bgColor = 'red';

                                    if (prevIsSeparate && Ext4.isEmpty(cageAnimals))
                                        bgColor = emptyCageColor;

                                    if (!prevIsSeparate && Ext4.isEmpty(cageAnimals) && Ext4.isEmpty(prevAnimals))
                                        bgColor = emptyCageColor;

                                    if (cageType == 'No Cage'){
                                        if (!Ext4.isEmpty(cageAnimals))
                                            bgColor = 'red';
                                        else {
                                            //NOTE: this used to use no color.  i'm not sure why
                                            bgColor = 'grey';
                                        }
                                    }
                                    else if (status == 'Unavailable')
                                    {
                                        bgColor = 'yellow';
                                    }
                                }
                                else {
                                    //flag cage if empty
                                    if (Ext4.isEmpty(row.get('totalAnimals/animals'))){
                                        bgColor = emptyCageColor;
                                    }

                                    //also if no cage present
                                    if (cageType == 'No Cage'){
                                        if (!Ext4.isEmpty(cageAnimals))
                                            bgColor = 'red';
                                        else
                                            bgColor = 'grey';
                                    }
                                    else if (status == 'Unavailable')
                                    {
                                        bgColor = 'yellow';
                                    }
                                }

                                var type = row.get('cage_type');
                                var cageType = config.cageTypeMap[row.get('cage_type')] || {};
                                var suffix = cageType.abbreviation || '';
                                rowItems.push({
                                    border: false,
                                    style: {
                                        'margin-bottom': '5px',
                                        'border-top': 2,
                                        'border-bottom': 2,
                                        'border-right': rb,
                                        'border-left': lb,
                                        borderColor: 'black',
                                        borderStyle: 'solid'
                                    },
                                    bodyStyle: {
                                        margin: '2px',
                                        'background-color': bgColor
                                    },
                                    width: cageWidth,
                                    minHeight: height,
                                    defaults: {
                                        border: false
                                    },
                                    items: [{
                                        html: row.get('cage_type') == 'No Cage' ? 'No Cage' : ('<span style="font-size: 11px;"><a>' + ri + colIdx + '</a>' + (cageType.sqft ? ' (' + (cageType.sqft / cageType.cageslots)+ suffix + ')' : '') + '</span>'),
                                        bodyStyle: {
                                            'background-color': 'transparent'
                                        },
                                        listeners: {
                                            scope: this,
                                            afterrender: Ext4.Function.pass(function(row, config, cmp){
                                                cmp.getEl().on('click', function(el){
                                                    Ext4.create('ONPRC.window.CageDetailsWindow', {
                                                        //TODO
                                                        roomPanel: config,
                                                        cageRec: row
                                                    }).show();
                                                }, this);
                                            }, [row, config], config)
                                        }
                                    },{
                                        border: false,
                                        style: 'margin-top: 10px;',
                                        bodyStyle: {
                                            'background-color': 'transparent'
                                        },
                                        items: animalItems
                                    }]
                                });

                                if (colIdx < maxCage){
                                    var dividerInfo = config.dividerMap[row.get('divider')] || {};
                                    LDK.Assert.assertNotEmpty('No divider info for cage: ' + row.get('location'), config.dividerMap[row.get('divider')]);

                                    var divider = dividerInfo.divider || 'Unknown';
                                    var dividerColor = dividerInfo.bgcolor;
                                    var dividerBorderStyle = dividerInfo.border_style || 'none';
                                    var dividerText = ''; //dividerInfo.short_description;

                                    rowItems.push({
                                        cageRec: row,
                                        border: true,
                                        style: {
                                            'margin-bottom': '5px',
                                            'border-top': 2,
                                            'border-bottom': 2,
                                            'border-right': 0,
                                            'border-left': (dividerBorderStyle && dividerBorderStyle != 'none') ? 2 : 0,
                                            borderColor: 'black',
                                            borderStyle: 'solid ' + dividerBorderStyle + ' solid ' + dividerBorderStyle
                                        },
                                        bodyStyle: {
                                            'background-color': dividerColor
                                        },
                                        width: divider != 'Solid Divider' ? dividerWidth : null,
                                        minHeight: height
                                    });
                                }
                            }
                            else {
                                rowItems.push({
                                    border: true,
                                    width: cageWidth,
                                    height: height,
                                    html: 'No Cage'
                                });

                                if (colIdx < maxCage){
                                    rowItems.push({
                                        width: dividerWidth,
                                        height: height,
                                        html: ''
                                    });
                                }
                            }
                        }

                        if (invertedMap[ri] === true)
                            rowItems.reverse();

                        table.items = table.items.concat(rowItems);
                    }, this);

                    if (!table.items.length){
                        table.items.push({
                            html: 'No cages present',
                            border: false,
                            style: 'margin-left: 5px;'
                        });
                    }
                    else {
                        hasCages = true;
                    }

                    toAdd = toAdd.concat(rowBlocks);
                }, this);

                if (hasCages && !config.printMode){
                    toAdd.push(ONPRC.panel.RoomLayoutPanel.getButtonCfgs(config));
                }
            }

            return toAdd;
        },

        getButtonCfgs: function(config){
            if (!config.roomPanel){
                return {};
            }

            var items = [];
            items.push(ONPRC.panel.RoomLayoutPanel.getPrintBtnCfg());

            //spacer
            items.push({
                border: false,
                width: 10
            });

            items.push({
                xtype: 'button',
                border: true,
                text: 'Invert Cages',
                tooltip: 'This allows the cages of C/D rows to be either ordered lowest to highest, or reversed (which matches the room itself, when printed)',
                doRowInversion: !config.doRowInversion,
                scope: config.roomPanel,
                handler: function(btn){
                    this.doRowInversion = !this.doRowInversion;
                    if (this.cachedData)
                        this.cachedData.doRowInversion = this.doRowInversion;

                    this.refresh();
                }
            });

            return {
                layout: 'hbox',
                items: items
            }
        },

        getPrintBtnCfg: function(){
            return {
                xtype: 'button',
                text: 'Print Version',
                itemId: 'roomBtn',
                border: true,
                handler: function(btn){
                    var params = btn.getUrlParams();
                    if (!params)
                        return;

                    var url = LABKEY.ActionURL.buildURL('onprc_ehr', 'printRoom', null, params);
                    window.open(url);
                },
                getUrlParams: function(){
                    var panel = this.up('#roomLayoutPanel');
                    var params = {};
                    params.doRowInversion = !!panel.doRowInversion;

                    Ext4.Array.forEach(panel.filterArray, function(filter){
                        //we support room/area/building on the URL
                        if (filter.getURLParameterName().match(/query.room\/area~/) && filter.getURLParameterValue()){
                            params.area = filter.getURLParameterValue().split(';')
                        }

                        if (filter.getURLParameterName().match(/query.room\/building~/) && filter.getURLParameterValue()){
                            params.building = filter.getURLParameterValue().split(';')
                        }

                        if (filter.getURLParameterName().match(/query.room~/) && filter.getURLParameterValue()){
                            params.rooms = filter.getURLParameterValue().split(';')
                        }
                    }, this);

                    return params;
                }
            }
        }
    },

    initComponent: function(){
        Ext4.apply(this, {
            border: false,
            itemId: 'roomLayoutPanel',
            defaults: {
                border: false
            },
            items: [{
                xtype: this.printMode ? 'panel' : 'ldk-webpartpanel',
                title: this.printMode ? null : 'Room Layout',
                border: false,
                defaults: {
                    border: false
                },
                items: [{
                    html: 'Loading...'
                }]
            }]
        });

        this.doLoadData();

        this.callParent(arguments);
    },

    doLoadData: function(){
        ONPRC.panel.RoomLayoutPanel.getPanelSections(this.filterArray, this.onDataLoad, this);
    },

    refresh: function(){
        this.onDataLoad(this.cachedData);
    },

    onDataLoad: function(ret){
        this.cachedData = ret;
        ret.roomPanel = this;
        ret.cageStore.on('datachanged', this.refresh, this, {single: true});

        var toAdd = ONPRC.panel.RoomLayoutPanel.getRoomItems(ret);

        this.removeAll();
        this.add([{
            xtype: 'ldk-webpartpanel',
            title: 'Room Layout',
            border: false,
            defaults: {
                border: false
            },
            items: toAdd
        }]);
    }
});

Ext4.define('ONPRC.window.CageDetailsWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        this.hasEditPermission = EHR.Security.hasHousingEditorPermission();
        var buttons = [{
            text: 'Close',
            handler: function(btn){
                btn.up('window').destroy();
            }
        }];

        if (this.hasEditPermission){
            buttons.unshift({
                text: 'Edit',
                boundRecord: this.cageRec,
                handler: function(btn){
                    btn.up('window').close();

                    Ext4.create('Ext.window.Window', {
                        modal: true,
                        closeAction: 'destroy',
                        title: 'Edit Cage/Divider',
                        bodyStyle: 'padding: 5px;',
                        width: 400,
                        boundRecord: btn.boundRecord,
                        defaults: {
                            width: 380
                        },
                        items: [{
                            xtype: 'combo',
                            fieldLabel: 'Cage Type',
                            displayField: 'cagetype',
                            valueField: 'cagetype',
                            value: btn.boundRecord.get('cage_type'),
                            //many users can edit dividers, but not all can edit cage type
                            hidden: !EHR.Security.hasLocationEditorPermission(),
                            itemId: 'cageType',
                            store: {
                                type: 'labkey-store',
                                schemaName: 'ehr_lookups',
                                queryName: 'cage_type',
                                autoLoad: true,
                                sort: 'cagetype'
                            }
                        },{
                            xtype: 'combo',
                            fieldLabel: 'Divider Type',
                            displayField: 'divider',
                            valueField: 'rowid',
                            value: btn.boundRecord.get('divider'),
                            itemId: 'divider',
                            store: {
                                type: 'labkey-store',
                                schemaName: 'ehr_lookups',
                                queryName: 'divider_types',
                                filterArray: [LABKEY.Filter.create('datedisabled', null, LABKEY.Filter.Types.ISBLANK)],
                                autoLoad: true,
                                sort: 'divider'
                            }
                        },{
                            xtype: 'combo',
                            fieldLabel: 'Status',
                            displayField: 'value',
                            valueField: 'value',
                            value: btn.boundRecord.get('status'),
                            hidden: !EHR.Security.hasLocationEditorPermission(),
                            itemId: 'cageStatus',
                            store: {
                                type: 'labkey-store',
                                schemaName: 'ehr_lookups',
                                queryName: 'cage_status',
                                autoLoad: true,
                                sort: 'value'
                            }
                        }],
                        buttons: [{
                            text: 'Submit',
                            handler: function(btn){
                                var win = btn.up('window');
                                var cageType = win.down('#cageType');
                                var divider = win.down('#divider');
                                var cageStatus = win.down('#cageStatus');
                                if (!EHR.Security.hasLocationEditorPermission() && !cageType.getValue()){
                                    Ext4.Msg.alert('Error', 'Must enter the cage type');
                                    return;
                                }

                                if (!divider.getValue()){
                                    Ext4.Msg.alert('Error', 'Must enter the divider type');
                                    return;
                                }

                                var boundRecord = win.boundRecord;
                                win.close();
                                Ext4.Msg.wait('Saving...');

                                LABKEY.Query.updateRows({
                                    schemaName: 'ehr_lookups',
                                    queryName: 'cage',
                                    rows: [{
                                        location: boundRecord.get('location'),
                                        cage_type: cageType.getValue(),
                                        divider: divider.getValue(),
                                        status: cageStatus.getValue()
                                    }],
                                    scope: this,
                                    failure: LDK.Utils.getErrorCallback(),
                                    success: function(results){
                                        Ext4.Msg.hide();
                                        boundRecord.set({
                                            cage_type: cageType.getValue(),
                                            divider: divider.getValue(),
                                            status: cageStatus.getValue()
                                        });
                                        boundRecord.store.fireEvent('datachanged', boundRecord.store);
                                    }
                                });
                            }
                        },{
                            text: 'Cancel',
                            handler: function(btn){
                                btn.up('window').close();
                            }
                        }]
                    }).show();
                }
            });
        }

        Ext4.apply(this, {
            title: 'Cage: ' + this.cageRec.get('cage'),
            bodyStyle: 'padding: 5px;',
            width: 400,
            defaults: {
                width: 360
            },
            buttons: buttons,
            items: this.getItems()
        });

        this.callParent(arguments);
    },

    getItems: function(){
        var items = [];
        var cageType = this.roomPanel.cageTypeMap[this.cageRec.get('cage_type')] || {};
        var dividerRec = this.roomPanel.dividerMap[this.cageRec.get('divider')] || {};

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Room',
            value: this.cageRec.get('room')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Cage',
            value: this.cageRec.get('cage')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Cage Type',
            value: this.cageRec.get('cage_type')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Sq Ft.',
            value: cageType.sqft
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Height',
            value: cageType.height
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Cage Slots',
            value: cageType.cageslots
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Divider',
            value: dividerRec.divider
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Status',
            value: this.cageRec.get('status')
        });

        return items;
    }
});