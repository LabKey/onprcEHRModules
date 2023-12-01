Ext.define('App.view.HeaderAmended', {
    extend  : 'Ext.panel.Header',
    alias   : 'widget.appheaderAmended',
    cls     : 'app-header',
    height  : 40,
    layout: {
        pack: 'center'
    },
    padding : '5 10 5 5',
    // tpl     : 'Schedule for : <span style="color:blue;padding-left : 380px;div {text-align: center;};font-size: 34px;font-weight:bold" class="header-month">{month}</span><span  style="color:blue;padding-left : 50px;font-size: 34px;font-weight:bold" class="header-year">{year}</span>',
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
