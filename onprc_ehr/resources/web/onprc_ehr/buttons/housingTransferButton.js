/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.ns('ONPRC_EHR.Buttons');

ONPRC_EHR.Buttons.markTransferComplete = function(dataRegionName){
    var dataRegion = LABKEY.DataRegions[dataRegionName];
    var checked = dataRegion.getChecked();
    if(!checked || !checked.length){
        alert('No records selected');
        return;
    }

    Ext4.create('Ext.window.Window', {
        title: 'Mark Transfers Complete',
        modal: true,
        closeAction: 'destroy',
        width: 375,
        bodyStyle: 'padding: 5px;',
        items: [{
            html: 'Please enter the time these transfers were completed below',
            border: false,
            style: 'padding-bottom: 10px;'
        },{
            xtype: 'xdatetime',
            itemId: 'dateField',
            fieldLabel: 'Date',
            timeFormat: 'H:i',
            width: 350,
            value: new Date()
        },{
            xtype: 'textfield',
            itemId: 'performedBy',
            fieldLabel: 'Performed By',
            width: 350,
            value: LABKEY.Security.currentUser.displayName
        }],
        buttons: [{
            text: 'Submit',
            scope: this,
            handler: function(btn){
                var date = btn.up('window').down('#dateField').getValue();
                var performedBy = btn.up('window').down('#performedBy').getValue();
                if (!date){
                    Ext4.Msg.alert('Error', 'Must enter a date');
                    return;
                }

                Ext4.Msg.wait('Loading...');
                LABKEY.Query.selectRows({
                    method: 'POST',
                    schemaName: 'onprc_ehr',
                    queryName: 'housing_transfer_requests',
                    columns: 'Id,date,room,cage,reason,objectid,qcstate/PublicData',
                    filterArray: [LABKEY.Filter.create('objectid', checked.join(';'), LABKEY.Filter.Types.IN)],
                    failure: LDK.Utils.getErrorCallback(),
                    success: function(results){
                        Ext4.Msg.hide();
                        if (!results || !results.rows || !results.rows.length){
                            Ext4.Msg.alert('Error', 'No rows found');
                            return;
                        }

                        var rows = [];
                        var skipped = 0;
                        Ext4.Array.forEach(results.rows, function(r){
                            if (r['qcstate/PublicData']){
                                skipped++;
                            }
                            else {
                                var obj = {
                                    Id: r.Id,
                                    date: date,
                                    room: r.room,
                                    cage: r.cage,
                                    reason: r.reason,
                                    parentid: r.objectid
                                };

                                if (performedBy){
                                    obj.performedby = performedBy;
                                }

                                rows.push(obj);
                            }
                        });

                        if (skipped && rows.length){
                            Ext4.Msg.alert('Skipping Rows', 'One or more rows have already been completed and will be skipped.', function(val){
                                doPost(rows);
                            }, this);
                        }
                        else if (skipped && !rows.length){
                            Ext4.Msg.alert('Skipping Rows', 'All of the selected rows have already been completed, nothing to do.');
                        }
                        else if (!rows.length){
                            Ext4.Msg.alert('No Rows', 'No rows were returned, nothing to do.');
                        }
                        else {
                            doPost(rows);
                        }

                        //now post to target form
                        function doPost(rows){
                            var initialData = {
                                'housing': rows
                            };

                            var newForm = Ext4.DomHelper.append(document.getElementsByTagName('body')[0],
                                    '<form method="POST" action="' + LABKEY.ActionURL.buildURL('ehr', 'dataEntryForm', null, {formType: 'housing'}) + '">' +
                                            '<input type="hidden" name="initialData" value="' + Ext4.htmlEncode(Ext4.encode(initialData)) + '" />' +
                                            '</form>');
                            newForm.submit();
                        }
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