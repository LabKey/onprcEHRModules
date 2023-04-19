
Ext.define('App.view.InfoPanel', {
    extend    : 'Ext.Container',
    alias     : 'widget.infopanelAmended',
    requires  : [
        'App.view.InfoPanelModelAmended'
    ],
    viewModel : 'infopanelAmended',
    reference : 'infopanelAmended',
    cls       : 'infopanelAmended',
    width     : 540,
    layout    : {
        type  : 'vbox',
        align : 'stretch'
    },
    items : [
        {
            xtype : 'eventform',
            title : 'Necropsy Calendar Schedule',
            editable : false
        }

    ]
});