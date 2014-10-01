/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.ns('ONPRC_EHR.Buttons');

ONPRC_EHR.Buttons.bulkEditRequestHandler = function(dataRegionName, formType, isRequestAdmin){
    var dataRegion = LABKEY.DataRegions[dataRegionName];
    var checked = dataRegion.getChecked();
    if(!checked || !checked.length){
        alert('No records selected');
        return;
    }

    var checkedRows = dataRegion.getChecked();
    var selectorCols = !Ext4.isEmpty(dataRegion.selectorCols) ? dataRegion.selectorCols : dataRegion.pkCols;
    LDK.Assert.assertNotEmpty('Unable to find selector columns for: ' + dataRegion.schemaName + '.' + dataRegion.queryName, selectorCols);
    var selectorCol = selectorCols[0];

    Ext4.Msg.wait('Loading...');
    LABKEY.Query.selectRows({
        method: 'POST',
        schemaName: dataRegion.schemaName,
        queryName: dataRegion.queryName,
        columns: selectorCol + ',createdby,qcstate/metadata/isRequest',
        filterArray: [LABKEY.Filter.create(selectorCol, checkedRows.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)],
        scope: this,
        success: function(results){
            Ext4.Msg.hide();

            if (!results || !results.rows || !results.rows.length){
                Ext4.Msg.alert('Error', 'No rows were found');
                return;
            }

            var keys = [];
            var nonRequest = [];
            var noPermission = [];
            Ext4.Array.forEach(results.rows, function(row){
                LDK.Assert.assertTrue('Row lacks request field', row.hasOwnProperty('qcstate/metadata/isRequest'));
                LDK.Assert.assertTrue('Row lacks createdby field', row.hasOwnProperty('createdby'));

                if (!row['qcstate/metadata/isRequest']){
                    nonRequest.push(row);
                }
                else {
                    if (isRequestAdmin || row.createdby == LABKEY.Security.currentUser.id){
                        keys.push(row[selectorCol]);
                    }
                    else {
                        noPermission.push(row);
                    }
                }
            }, this);

            if (nonRequest.length || noPermission.length){
                var msgs = [];
                if (nonRequest.length){
                    msgs.push('One or more rows is not a request and will be skipped');
                }

                if (noPermission.length){
                    msgs.push('You do not have permission to update one of more of these rows because you did not create it, which will be skipped');
                }

                Ext4.Msg.alert('Records Will Be Skipped', msgs.join('<br>'), function(){
                    if (keys.length)
                        viewForm(keys);
                }, this);
            }
            else if (keys.length){
                viewForm(keys);
            }

            function viewForm(keys){
                var re = new RegExp('^' + window.location.origin);
                var srcURL = window.location.href.replace(re, '');

                if (keys.length < 10){
                    window.location = LABKEY.ActionURL.buildURL('ehr', 'dataEntryForm', null, {formType: formType, pkValues: keys.join(';'), srcURL: srcURL});
                }
                else {
                    var newForm = Ext4.DomHelper.append(document.getElementsByTagName('body')[0],
                            '<form method="POST" action="' + LABKEY.ActionURL.buildURL('ehr', 'dataEntryForm', null, {formType: formType, srcURL: srcURL}) + '">' +
                                '<input type="hidden" name="pkValues" value="' + Ext4.htmlEncode(keys.join(';')) + '" />' +
                            '</form>');
                    newForm.submit();
                }
            }
        },
        failure: LDK.Utils.getErrorCallback()
    });

};