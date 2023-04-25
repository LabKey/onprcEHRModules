
Ext.define('App.view.InfoPanelAmended', {
    extend    : 'Ext.Container',
    alias     : 'widget.infopanelamended',
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