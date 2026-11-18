/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext.define('App.view.Header', {
    extend  : 'Ext.panel.Header',
    alias   : 'widget.appheader',
    cls     : 'app-header',
    height  : 40,
    padding : '5 10 5 5',
    tpl     : 'Schedule for <span class="header-month">{month}</span><span class="header-year">{year}</span>',
    bind    : {
        //each bind should have corresponding setter
        date: '{endDate}'
    },
    setDate : function (date) {
        this.setData(
                {
                    month : Ext.Date.format(date, 'F'),
                    year  : Ext.Date.format(date, 'Y')
                }
        );
    }
});