/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.NecropsyRequestInstructionsPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc_ehr_necropsyRequestinstructionspanel',

    initComponent: function(){
        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: [{
                html: 'Below is a web link to the Prime billing codes you can access as a reference guide.<p>' +
                        '<ul>' +
                        '<li><a href="' + LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'ehr', 'query.queryName': 'protocol','query.viewName': 'Active Protocols'}) + '">Click here to view Protocol Codes</a></li>' +
                        '<li><a href="' + LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'ehr', 'query.queryName': 'project','query.viewName': 'Active Projects'}) + '">Click here to view Center Project Codes</a></li>' +
                        '</ul>',
                style: 'padding: 5px;'
            }]
        });

        this.callParent(arguments);
    }
});