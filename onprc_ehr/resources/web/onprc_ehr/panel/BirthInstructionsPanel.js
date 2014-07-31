/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.BirthInstructionsPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc-birthinstructionspanel',

    initComponent: function(){
        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: [{
                html: 'This form allows you to enter new birth.  Per birth, the following steps will occur:<p>' +
                        '<ul>' +
                        '<li>If not already present, a demographics record will be created.  This is the table holding 1 row for all known IDs.</li>' +
                        '<li>If date, species, gender, and/or geographic origin are entered at the time the birth record is entered, the demographic record will use these.</li>' +
                        '<li>If room/cage are entered, a housing record will be created starting on the birth date.</li>' +
                        '<li>If a dam is supplied, the infant will be set to the same SPF status as the dam (on the infant\'s DOB, not the current date).</li>' +
                        '<li>If the dam is assigned to a breeding group or U42 on the infant\'s DOB (not the date this was entered), this will be applied to the infant.</li>' +
                        '<li>The infant will be set to Nonrestricted as the animal condition.</li>' +
                        '</ul>',
                style: 'padding: 5px;'
            }]
        });

        this.callParent(arguments);
    }
});