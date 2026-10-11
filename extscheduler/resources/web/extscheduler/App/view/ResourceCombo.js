/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext.define('App.view.ResourceCombo', {
    extend       : 'Ext.form.field.ComboBox',
    alias        : 'widget.resourcecombo',
    store        : 'resource',
    queryMode    : 'local',
    valueField   : 'Id',
    displayField : 'Name',
    editable     : false
});