
Ext.define('App.view.InfoPanelAmended', {
    extend    : 'Ext.Container',
    alias     : 'widget.infopanelAmended',
    requires  : [
        'App.view.InfoPanelModelAmended'
    ],
    viewModel : 'infopanelamended',
    reference : 'infopanelamended',
    cls       : 'infopanelamended',
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