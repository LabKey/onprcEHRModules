/*
 * Copyright (c) 2013 LabKey Corporation
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
            filters.push(LABKEY.Filter.create('room/housingType/value', 'Cage Location'));

            multi.add(LABKEY.Query.selectRows, {
                schemaName: 'ehr_lookups',
                queryName: 'cage',
                filterArray: filters,
                requiredVersion: 9.1,
                sort: 'room/sort_order,cagePosition/sort_order',
                columns: 'room,cage,cage_type,cage_type/sqft,cage_type/height,cage_type/cageslots,divider,cagePosition/row,cagePosition/columnIdx,cagePosition/sort_order,totalAnimals/animals,divider/countAsSeparate,divider/countAsPaired,divider/displaychar,divider/bgcolor,divider/border_style,divider/short_description',
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: function(results){
                    ret.cageResults = results;
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

            if (!config.cageResults || !config.cageResults.rows || !config.cageResults.rows.length){
                toAdd.push({
                    html: 'No cages found'
                });
            }
            else {
                if (!config.printMode){
                    toAdd.push({
                        border: false,
                        style: 'margin-bottom: 10px;',
                        html: 'NOTE: Click on either the cage or divider for more information.  A yellow divider indicates the cages are paired.  A black divider indicates the cages are separate.  Cages are colored green when they are empty.'
                    });
                }

                var roomMap = {};
                var colIdxs = {};
                var maxCageMap = {};
                var invertedMap = {};
                Ext4.each(config.cageResults.rows, function(r){
                    var row = new LDK.SelectRowsRow(r);
                    var room = row.getValue('room');
                    var maxCage = maxCageMap[room] || 0;
                    var letter = row.getValue('cagePosition/row');
                    var letterNum = ONPRC.panel.RoomLayoutPanel.getRowNumber(letter);
                    var isInverted = config.doRowInversion ? (Math.round(letterNum / 4) == 1) : false;
                    invertedMap[letter] = isInverted;

                    var col = row.getValue('cagePosition/columnIdx');

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
                var dividerWidth = 8;
                var height = 115;
                var cageWidth = 65;
                var hasCages = false;

                Ext4.each(rooms, function(room, roomIdx){
                    if (roomIdx == 0 && !config.printMode){
                        //TODO
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

                        if ((ONPRC.panel.RoomLayoutPanel.getRowNumber(ri) % 4) == 0){
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
                        else if(rowIdx > 0 && (ONPRC.panel.RoomLayoutPanel.getRowNumber(ri) % 2) == 0){
                            currentSection.push({
                                border: false,
                                height: 30
                            });
                        }
                        prevRowOrientation = isInverted;

                        for (var colIdx = 1;colIdx<=maxCage;colIdx++){
                            var row = cages[colIdx];
                            if (row){
                                var animals = row.getDisplayValue('totalAnimals/animals');
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

                                var isSeparate = row.getValue('divider/countAsSeparate');
                                var isPaired = row.getValue('divider/countAsPaired');

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
                                var cageType = row.getValue('cage_type');
                                var cageAnimals = row.getValue('totalAnimals/animals');
                                if (prevCage){
                                    var prevIsSeparate = prevCage.getValue('divider/countAsSeparate');
                                    var prevAnimals = prevCage.getValue('totalAnimals/animals');

                                    if (!prevIsSeparate && !Ext4.isEmpty(cageAnimals))
                                        bgColor = 'red';

                                    if (prevIsSeparate && Ext4.isEmpty(cageAnimals))
                                        bgColor = emptyCageColor;

                                    if (!prevIsSeparate && Ext4.isEmpty(cageAnimals) && Ext4.isEmpty(prevAnimals))
                                        bgColor = emptyCageColor;

                                    if (cageType == 'No Cage'){
                                        if (!Ext4.isEmpty(cageAnimals))
                                            bgColor = 'red';
                                        else
                                            bgColor = '';
                                    }
                                }
                                else {
                                    //flag cage if empty
                                    if (Ext4.isEmpty(row.getValue('totalAnimals/animals'))){
                                        bgColor = emptyCageColor;
                                    }

                                    //also if no cage present
                                    if (cageType == 'No Cage'){
                                        if (!Ext4.isEmpty(cageAnimals))
                                            bgColor = 'red';
                                        else
                                            bgColor = 'grey';
                                    }
                                }

                                //TODO: do something smarter
                                var type = row.getDisplayValue('cage_type');
                                var suffix = '';
                                if (type.match(/^Tunnel/))
                                    suffix = 'TU';
                                else if (type.match(/^Tall/) || type.match(/[0-9]T$/))
                                    suffix = 'T';

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
                                        html: cageType == 'No Cage' ? 'No Cage' : ('<span style="font-size: 11px;"><a>' + ri + colIdx + '</a>' + (row.getValue('cage_type/sqft') ? ' (' + (row.getValue('cage_type/sqft') / row.getValue('cage_type/cageslots'))+ suffix + ')' : '') + '</span>'),
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
                                    var divider = row.getDisplayValue('divider');
                                    var dividerColor = row.getValue('divider/bgcolor');
                                    var dividerBorderStyle = row.getValue('divider/border_style') || 'none';
                                    var dividerText = ''; //row.getValue('divider/short_description');

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
                                        minHeight: height,
                                        listeners: {
                                            scope: this,
                                            afterrender: Ext4.Function.pass(function(row, config, dividerText, cmp){
                                                cmp.getEl().on('click', function(el){
                                                    Ext4.create('ONPRC.window.CageDividerDetailsWindow', {
                                                        roomPanel: config,
                                                        cageRec: row
                                                    }).show();
                                                }, this);

                                                if (dividerText){
                                                    Ext4.create('Ext.draw.Text', {
                                                        renderTo: cmp.body,
                                                        degrees: 90,
                                                        text: dividerText,
                                                        width: height
                                                    });
                                                }
                                            }, [row, config, dividerText], config)
                                        }
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
        Ext4.apply(this, {
            title: 'Cage: ' + this.cageRec.getDisplayValue('cage'),
            bodyStyle: 'padding: 5px;',
            width: 400,
            defaults: {
                width: 360
            },
            buttons: [{
                text: 'Close',
                handler: function(btn){
                    btn.up('window').destroy();
                }
            }],
            items: this.getItems()
        });

        this.callParent(arguments);
    },

    getItems: function(){
        var items = [];

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Room',
            value: this.cageRec.getDisplayValue('room')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Cage',
            value: this.cageRec.getDisplayValue('cage')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Cage Type',
            value: this.cageRec.getDisplayValue('cage_type')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Sq Ft.',
            value: this.cageRec.getDisplayValue('cage_type/sqft')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Height',
            value: this.cageRec.getDisplayValue('cage_type/height')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Cage Slots',
            value: this.cageRec.getDisplayValue('cage_type/cageslots')
        });

        return items;
    }
});

Ext4.define('ONPRC.window.CageDividerDetailsWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            bodyStyle: 'padding: 5px;',
            title: 'Cage Divider: ' + this.cageRec.getDisplayValue('cage'),
            items: this.getItems(),
            width: 400,
            defaults: {
                width: 360
            },
            buttons: [{
                text: 'Close',
                handler: function(btn){
                    btn.up('window').destroy();
                }
            }]
        });

        this.callParent(arguments);
    },

    getItems: function(){
        var items = [];

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Room',
            value: this.cageRec.getDisplayValue('room')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Cage',
            value: this.cageRec.getDisplayValue('cage')
        });

        items.push({
            xtype: 'displayfield',
            fieldLabel: 'Divider Type',
            value: this.cageRec.getDisplayValue('divider')
        });

        return items;
    }
});