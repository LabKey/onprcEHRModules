Ext.define('App.view.InfoPanelAmended', {
    extend    : 'Ext.Container',
    alias     : 'widget.infopanelAmended',
    requires  : [
        'App.view.InfoPanelModelAmended'
    ],
    viewModel : 'infopanelamended',
    reference : 'infopanelamended',
    cls       : 'infopanelamended',
    width     : 340,
    layout    : {
        type  : 'vbox',
        align : 'stretch'
    },
    items : [
        {
            xtype : 'eventform_Amended',
            title : 'Radiology Calendar Schedule',
            editable : false
        }

    ]
});
