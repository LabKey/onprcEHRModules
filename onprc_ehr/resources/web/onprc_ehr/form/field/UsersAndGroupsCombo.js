/*
 * Copyright (c) 2014-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('EHR.form.field.UsersAndGroupsCombo', {
    extend: 'LABKEY.ext4.ComboBox',
    alias: 'widget.onprc_ehr-usersandgroupscombo',

    initComponent: function(){
        Ext4.apply(this, {
            displayField: 'DisplayName',
            valueField: 'UserId',
            queryMode: 'local',
            forceSelection: true,
            matchFieldWidth: false,
            store: {
                type: 'labkey-store',
                schemaName: 'onprc_ehr',
                queryName: 'PrincipalsWithoutAdminUpdate',
                columns: 'UserId,DisplayName,FirstName,LastName,Type,Active',
                sort: 'Type,DisplayName',
                autoLoad: true
            },
            anyMatch: true,
            caseSensitive: false,
            listConfig: {
                innerTpl: '{[LABKEY.Utils.encodeHtml(values.DisplayName + (values.LastName ? " (" + values.LastName + (values.FirstName ? ", " + values.FirstName : "") + ")" : ""))]}',
                getInnerTpl: function(){
                    return this.innerTpl;
                }
            }
        });

        this.callParent(arguments);
    }
});