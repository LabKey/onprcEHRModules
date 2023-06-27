Ext.define('App.view.SchedulerAmended', {
    extend        : 'Sch.panel.SchedulerGrid',
    alias         : 'widget.schedulerAmended',
    reference     : 'schedulerAmended',
    startDate     : new Date(),
    //endDate       : new Date(),
    startTime     : 6,
    endTime       : 20,
    resourceStore : 'resource',
    eventStore    : 'event',
    style         : 'border: 1px solid #d0d0d0;',

    readOnly             : true,  // disables the abilitiy to click in calendar to create event
    showTodayLine        : true,
    calendarViewPreset   : 'week',
    mode                 : 'calendar',
    eventResizeHandles   : 'none',
    eventBodyTemplate    :'<b>{ResourceName:htmlEncode}</b><br/>{Alias:htmlEncode}<br/>{Project:htmlEncode}<br/>{fasting:htmlEncode}<br/>{delivery:htmlEncode}',
    snapToIncrement      : true,
    allowOverlap         : true,
    highlightCurrentTime : true,
    calendarTimeAxisCfg  : {
        height : 30
    },

    tbar: [
        {
            text : 'Previous',
            iconCls: 'x-fa fa-arrow-circle-left',
            handler: function (btn) {
                var scheduler = btn.up('schedulerAmended');
                scheduler.timeAxis.shift(-7, Sch.util.Date.DAY);
            }
        },
        {
            text : 'Today',
            handler: function (btn) {
                var scheduler = btn.up('schedulerAmended');
                // Clear time here so date adjustment wouldn't result in 2 days span
                scheduler.setStart(Sch.util.Date.clearTime(new Date()));
            }
        },
        {
            text : 'Next',
            iconCls: 'x-fa fa-arrow-circle-right',
            iconAlign: 'right',
            handler: function (btn) {
                var scheduler = btn.up('schedulerAmended');
                scheduler.timeAxis.shift(7, Sch.util.Date.DAY);
            }
        },
        '',
        {
            text         : 'Select Date...',
            scope        : this,
            menu         : Ext.create('Ext.menu.DatePicker', {
                handler : function (dp, date) {
                    var scheduler = dp.up('schedulerAmended');
                    scheduler.setStart(Sch.util.Date.clearTime(date));
                }
            })
        },        '->',
        {

        }
    ],

    eventRenderer : function (event, resource, data) {
        data.style = 'background-color:' + resource.get('Color');
        event.data['ResourceName'] = resource.get('Name');
        event.data['Project'] = event.get('project');
        event.data['fasting'] = event.get('fasting');
        event.data['delivery'] = event.get('delivery');
        // event.data['Alias'] = event.get('Alias');
        var userRecord = Ext.getStore('users').findRecord('UserId', event.get('UserId'));
        event.data['UserDisplayName'] = userRecord != null ? userRecord.get('DisplayName') : event.get('UserId');
        return event.data;
    },

    onEventCreated : function (newEventRecord) {
        this.getEventSelectionModel().select(newEventRecord);
    }
});