Ext.define('App.view.InfoPanelAmended', {
    extend    : 'Ext.Container',
    alias     : 'widget.infopanelAmended',
    requires  : [
        'App.view.InfoPanelModelAmended'
    ],
    viewModel : 'infopanelAmended',
    reference : 'infopanelAmended',
    cls       : 'infopanelAmended',
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
