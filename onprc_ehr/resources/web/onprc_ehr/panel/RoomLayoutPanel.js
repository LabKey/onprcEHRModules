/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC.panel.RoomLayoutPanel', {
    extend: 'Ext.panel.Panel',
    printMode: false,

    initComponent: function(){
        Ext4.apply(this, {
            border: false,
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

        this.loadData();

        this.callParent(arguments);
    },

    loadData: function(){
        LABKEY.Query.selectRows({
            schemaName: 'ehr_lookups',
            queryName: 'cage',
            filterArray: this.filterArray,
            requiredVersion: 9.1,
            sort: 'room/sort_order,cagePosition/sort_order',
            columns: 'room,cage,cage_type,cage_type/sqft,cage_type/height,cage_type/cageslots,divider,cagePosition/row,cagePosition/columnIdx,cagePosition/sort_order,totalAnimals/animals,divider/countAsSeparate,divider/countAsPaired,divider/displaychar,divider/bgcolor,divider/border_style,divider/short_description',
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: this.onDataLoad
        });
    },

    getRowNumber: function(letter){
        return Ext4.isEmpty(letter) ? 0 : letter.toUpperCase().charCodeAt(0) - 65;
    },

    onDataLoad: function(results){
        this.results = results;

        var toAdd = [];

        if (!results || !results.rows || !results.rows.length){
            toAdd.push({
                html: 'No cages found'
            });
        }
        else {
            if (!this.printMode){
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
            Ext4.each(results.rows, function(r){
                var row = new LDK.SelectRowsRow(r);
                var room = row.getValue('room');
                var maxCage = maxCageMap[room] || 0;
                var letter = row.getValue('cagePosition/row');
                var letterNum = this.getRowNumber(letter);
                var isInverted = this.doRowInversion ? (Math.round(letterNum / 4) == 1) : false;
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
            var dividerWidth = 18;
            var height = 90;
            var cageWidth = 60;
            var hasCages = false;

            Ext4.each(rooms, function(room, roomIdx){
                if (roomIdx == 0 && !this.printMode){
                    toAdd.push(this.getButtonCfg());
                    toAdd.push({
                        style: 'margin-bottom: 20px;',
                        border: false
                    });
                }

                var cageMap = roomMap[room];
                var maxCage = maxCageMap[room];
                var rowIdxs = Ext4.Object.getKeys(cageMap).sort();
                var cfg = {
                    layout: {
                        type: 'table',
                        columns: (maxCage * 2) - 1
                    },
                    items: []
                };

                var prevRowOrientation = null;
                Ext4.each(rowIdxs, function(ri, rowIdx){
                    var cages = cageMap[ri];
                    var rowItems = [];
                    var isInverted = invertedMap[ri] === true;

                    if(rowIdx > 0 && (this.getRowNumber(ri) % 2) == 0){
                        cfg.items.push({
                            colspan: (maxCage * 2) - 1,
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
                            if (animals.length){
                                Ext4.each(animals, function(animal){
                                    animalItems.push({
                                        html: '<a>' + animal + '</a>',
                                        animal: animal,
                                        border: false,
                                        bodyStyle: {
                                            'background-color': 'transparent'
                                        },
                                        listeners: {
                                            scope: this,
                                            afterrender: function(cmp){
                                                cmp.getEl().on('click', function(el){
                                                    EHR.Utils.showClinicalHistory(null, cmp.animal, null);
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
                                        bgColor = 'grey';
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
                                    padding: '2px',
                                    'background-color': bgColor
                                },
                                width: cageWidth,
                                height: height,
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: '<a>' + ri + colIdx + '</a>',
                                    bodyStyle: {
                                        'background-color': 'transparent'
                                    },
                                    listeners: {
                                        scope: this,
                                        afterrender: Ext4.Function.pass(function(row, panel, cmp){
                                            cmp.getEl().on('click', function(el){
                                                Ext4.create('ONPRC.window.CageDetailsWindow', {
                                                    roomPanel: panel,
                                                    cageRec: row
                                                }).show();
                                            }, this);
                                        }, [row, this], this)
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
                                var dividerText = row.getValue('divider/short_description');

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
                                    height: height,
                                    listeners: {
                                        scope: this,
                                        afterrender: Ext4.Function.pass(function(row, panel, dividerText, cmp){
                                            cmp.getEl().on('click', function(el){
                                                Ext4.create('ONPRC.window.CageDividerDetailsWindow', {
                                                    roomPanel: panel,
                                                    cageRec: row
                                                }).show();
                                            }, this);

                                            if (dividerText){
                                                Ext4.create('Ext.draw.Text', {
                                                    renderTo: cmp.body,
                                                    degrees: 90,
                                                    text: dividerText,
                                                    width: height,
                                                    textStyle: {

                                                    }
                                                });
                                            }
                                        }, [row, this, dividerText], this)
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

                    cfg.items = cfg.items.concat(rowItems);
                }, this);

                if (!cfg.items.length){
                    cfg.items.push({
                        html: 'No cages present',
                        border: false,
                        style: 'padding-left: 5px;'
                    });
                }
                else {
                    hasCages = true;
                }

                var panelCfg = {
                    itemId: room,
                    style: 'margin-bottom: 30px;',
                    border: false,
                    defaults: {
                        border: false
                    },
                    items: [{
                        html: '<b>Room: ' + room + '</b>',
                        style: 'margin-bottom: 10px;'
                    },
                        cfg
                        ,{
                            html: '<div class="page-break"></div>'
                        }]
                };

                toAdd.push(panelCfg);
            }, this);

            if (hasCages && !this.printMode){
                toAdd.push(this.getButtonCfg());
            }
        }

        this.removeAll();
        this.add({
            xtype: this.printMode ? 'ldk-contentresizingpanel' : 'ldk-webpartpanel',
            title: this.printMode ? null : 'Room Layout',
            border: false,
            defaults: {
                border: false
            },
            items: toAdd
        });

        this.doLayout();
    },

    getButtonCfg: function(){
        var items = [];
        items.push(this.getPrintBtnCfg());

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
            doRowInversion: !this.doRowInversion,
            scope: this,
            handler: function(btn){
                this.doRowInversion = !this.doRowInversion;
                this.onDataLoad(this.results);
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
            border: true,
            scope: this,
            handler: function(btn){
                var params = {};
                params.doRowInversion = !!this.doRowInversion;

                Ext4.Array.forEach(this.filterArray, function(filter){
                    //we only support room/area on the URL
                    if (filter.getURLParameterName().match(/query.room\/area~/) && filter.getURLParameterValue()){
                        params.area = filter.getURLParameterValue().split(';')
                    }
                    else if (filter.getURLParameterName().match(/query.room~/) && filter.getURLParameterValue()){
                        params.rooms = filter.getURLParameterValue().split(';')
                    }
                }, this);

                window.open(LABKEY.ActionURL.buildURL('onprc_ehr', 'printRoom', null, params));
            }
        }
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
                width: 380
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
                width: 380
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