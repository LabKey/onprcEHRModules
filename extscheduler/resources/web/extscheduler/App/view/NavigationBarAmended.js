Ext.define('App.view.NavigationBarAmended', {
    extend    : 'Ext.panel.Header',
    alias     : 'widget.navigationbarAmended',
    cls       : 'navigationbarAmended',
    // padding   : '0 10 0 5',
    height    : 0,
    border    : false,
    title     : '<img src="' + LABKEY.contextPath + '/extscheduler/images/logo.png" style="height: 25px; margin-top: 8px;"/>',
    items     : [
        {
            // xtype : 'button',
            // text : 'Return to ' + window.location.host,
            // handler : function() {
            //     if (LABKEY.ActionURL.getParameter('returnUrl'))
            //         window.location = LABKEY.ActionURL.getParameter('returnUrl');
            //     else
            //         window.location = LABKEY.ActionURL.buildURL('project', 'begin');
            // }
        }
    ]
});