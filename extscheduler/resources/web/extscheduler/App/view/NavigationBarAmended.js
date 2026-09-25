Ext.define('App.view.NavigationBarAmended', {
    extend    : 'Ext.panel.Header',
    alias     : 'widget.navigationbarAmended',
    cls       : 'navigationbarAmended',
    // padding   : '0 10 0 5',
    height    : 0,
    border    : false,
    title     : '<img src="' + contextPath + '/extscheduler/images/logo.png" style="height: 25px; margin-top: 8px;"/>',
    items     : [
        {
            // xtype : 'button',
            // text : 'Return to ' + window.location.host,
            // handler : function() {
            //     if (ActionURL.getParameter('returnUrl'))
            //         window.location = ActionURL.getParameter('returnUrl');
            //     else
            //         window.location = ActionURL.buildURL('project', 'begin');
            // }
        }
    ]
});