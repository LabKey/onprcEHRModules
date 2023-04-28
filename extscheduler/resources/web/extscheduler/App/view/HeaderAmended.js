Ext.define('App.view.HeaderAmended', {
    extend  : 'Ext.panel.Header',
    alias   : 'widget.appheaderAmended',
    cls     : 'app-header',
    height  : 40,
    padding : '5 10 5 5',
    tpl     : 'Schedule for ; <span style="color:blue;font-weight:bold" class="header-month">{month}</span><span  style="color:blue;font-weight:bold" class="header-year">{year}</span>',
    // tpl     : 'Schedule for <span class="header-month">{month}</span><span class="header-year">{year}</span>',
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