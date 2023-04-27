//This viewport takes a role of container that contains a scheduler.
//If you need more than one scheduler on the page, you need to wrap viewport items in your own view.
Ext.define('App.view.ViewportAmended', {
    extend     : 'Ext.Viewport',
    requires   : [
        'App.view.ViewportControllerAmended'
    ],
    controller : 'viewportAmended',
    viewModel  : {},
    layout     : 'border',
    items      : [
        {
            xtype   : 'navigationbar',
            region  : 'north'
        },
        {
            xtype   : 'appheader',
            region  : 'north'
        },
        {
            xtype   : 'infopanelAmended',
            region  : 'east'
        },
        {
            xtype   : 'schedulerAmended',
            region  : 'center'
        }
    ]
});