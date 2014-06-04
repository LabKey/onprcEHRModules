/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg room
 */
Ext4.define('ONPRC_EHR.window.RoomBulkChangeWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Copy Cages From Room',
            bodyStyle: 'padding: 5px;',
            width: 400,
            defaults: {
                border: false
            },
            items: [{
                html : 'This helper will delete all cages and dividers from this room and copy the cage/divider layout from the room selected below.' +
                '<br><br>Note: this does not transfer any animals, and could result in orphan or otherwise incorrect housing records if you are not careful',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ehr-roomfield',
                width: 370,
                multiSelect: false,
                itemId: 'roomField'
            }],
            buttons: [{
                text: 'Submit',
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

    onSubmit: function(){
        var sourceRoom = this.down('#roomField').getValue();
        if (!sourceRoom){
            Ext4.Msg.alert('Error', 'Must choose a source room');
            return;
        }

        Ext4.Msg.wait('Loading...');
        LABKEY.Query.selectRows({
            schemaName: 'ehr_lookups',
            queryName: 'cage',
            columns: 'location,room,cage,cage_Type,divider',
            scope: this,
            filterArray: [LABKEY.Filter.create('room', this.room + ';' + sourceRoom, LABKEY.Filter.Types.EQUALS_ONE_OF)],
            failure: LDK.Utils.getErrorCallback(),
            success: this.onCageLoad
        });
    },

    onCageLoad: function(results){
        var toDelete = [];
        var toInsert = [];

        if (!results || !results.rows || !results.rows.length){
            Ext4.Msg.hide();
            Ext4.Msg.alert('Error', 'No cages found');
            return;
        }

        Ext4.Array.forEach(results.rows, function(row){
            if (row.room == this.room){
                toDelete.push({
                    location: row.location
                });
            }
            else {
                toInsert.push({
                    location: null, //TODO: due to issue 20067 we need to import rows with this property.  it will be set on the server
                    room: this.room,
                    cage: row.cage,
                    cage_type: row.cage_type,
                    divider: row.divider
                });
            }
        }, this);

        var commands = [];
        if (toDelete.length){
            commands.push({
                command: 'delete',
                schemaName: 'ehr_lookups',
                queryName: 'cage',
                rows: toDelete
            });
        }

        if (toInsert.length){
            commands.push({
                command: 'insert',
                schemaName: 'ehr_lookups',
                queryName: 'cage',
                rows: toInsert
            });
        }

        if (!commands.length){
            Ext4.Msg.hide();
            Ext4.Msg.alert('Error', 'There are no cages to delete or copy');
            return;
        }

        LABKEY.Query.saveRows({
            commands: commands,
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: this.onSaveComplete
        })
    },

    onSaveComplete: function(){
        Ext4.Msg.hide();
        this.close();

        Ext4.Msg.alert('Success', 'Cages have been copied', function(){
            window.location.reload();
        }, this);
    }
});