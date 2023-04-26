Ext.define('App.view.EventFormAmended', {
    extend    : 'Ext.form.Panel',
    alias     : 'widget.eventformAmended',
    reference : 'eventformAmended',
    cls       : 'eventformAmended',
    width     : 340,
    bodyPadding : 15,
    defaults    : {
        anchor     : '100%',
        labelWidth : 80
    },

    editable : false,
    scheduler : null,

    eventPeriodLength: 30,

    initComponent: function()
    {
        var context = LABKEY.getModuleContext('extscheduler');
        this.eventPeriodLength = parseInt(context['ExtSchedulerEventPeriodLength']);
        this.eventFormColumns = context['ExtSchedulerEventFormColumns'].split(',');

        this.items = [

            {
                xtype      : 'resourcecombo',
                fieldLabel : 'Resource',
                name       : 'ResourceId',
                reference  : 'eventResourceField',
                allowBlank : !this.editable,
                hidden     : this.eventFormColumns.indexOf('ResourceId') === -1,
                bind       : {
                    value    : '{eventRecord.ResourceId}',
                    readOnly : !this.editable

                }
            },

            {
                xtype      : 'textfield',
                fieldLabel : 'Animal ID',
                name       : 'Alias',
                reference  : 'eventAliasField',
                //allowBlank : !this.editable,
                allowBlank: true,
                hidden     : this.eventFormColumns.indexOf('Alias') === -1,
                bind       : {
                    value    : '{eventRecord.Alias}',
                    readOnly : !this.editable
                }
            },

            {
                xtype      : 'textfield',
                labelAlign: 'left',
                width: 120,
                height: 20,
                fieldLabel : 'Center Project',
                name :  'location',
                reference  : 'eventProjectField',
                style: 'margin-top: 20px;',
                allowBlank : true,
                hidden     : this.eventFormColumns.indexOf('project') === -1,
                bind       : {
                    value    : '{eventRecord.project}',
                    readOnly : !this.editable
                }
            },
            {
                xtype      : 'textfield',
                labelAlign: 'left',
                width: 120,
                height: 20,
                fieldLabel : 'Type of Fasting Requested',
                name :  'Fasting',
                reference  : 'eventFastimgField',
                style: 'margin-top: 20px;',
                allowBlank : true,
                hidden     : this.eventFormColumns.indexOf('fasting') === -1,
                bind       : {
                    value    : '{eventRecord.fasting}',
                    readOnly : !this.editable
                }
            },
            {
                xtype      : 'textfield',
                labelAlign: 'left',
                width: 120,
                height: 20,
                fieldLabel : 'Animal Delivery Requested',
                name :  'deliveryrequest',
                reference  : 'eventDeliveryRequestField',
                style: 'margin-top: 20px;',
                allowBlank : true,
                hidden     : this.eventFormColumns.indexOf('deliveryrequest') === -1,
                bind       : {
                    value    : '{eventRecord.deliveryrequestt}',
                    readOnly : !this.editable
                }
            },
            {
                xtype      : 'textfield',
                labelAlign: 'top',
                width: 320,
                height: 20,
                fieldLabel : 'Necropsy Location',
                name :  'location',
                reference  : 'eventLocationField',
                style: 'margin-top: 20px;',
                allowBlank : true,
                hidden     : this.eventFormColumns.indexOf('location') === -1,
                bind       : {
                    value    : '{eventRecord.location}',
                    readOnly : !this.editable
                }
            },
            {
                xtype: 'textarea',
                labelAlign: 'top',
                width: 320,
                height: 50,
                fieldLabel: 'CommentsXX',
                name: 'Comments',
                reference: 'eventCommentsField',
                style: 'margin-top: 20px;',
                allowBlank: true,
                hidden: this.eventFormColumns.indexOf('Comments') === -1,
                bind: {
                    value: '{eventRecord.Comments}',
                    readOnly: !this.editable
                }
            },

            {
                xtype  : 'fieldcontainer',
                layout : 'hbox',
                hidden     : this.eventFormColumns.indexOf('StartDate') === -1,
                items  : [
                    this.getStartDateField(),
                    this.getStartTimeField()
                ]
            },
            {
                xtype  : 'fieldcontainer',
                layout : 'hbox',
                hidden     : this.eventFormColumns.indexOf('EndDate') === -1,
                items  : [
                    this.getEndDateField(),
                    this.getEndTimeField()
                ]
            },

        ];

        if (this.editable)
        {
            this.buttons = [
                {
                    text: 'Cancel',
                    scope: this,
                    handler: function()
                    {
                        this.up('window').close();
                    }
                },
                {
                    text: 'Create',
                    formBind: true,
                    scope: this,
                    handler: function()
                    {
                        var values = this.getValues();

                        // concat the start/end date and times
                        values.StartDate = values.StartDate + ' ' + values.StartTime;
                        values.EndDate = values.EndDate + ' ' + values.EndTime;

                        var userRecord = Ext.getStore('users').findRecord('UserId', values.UserId);
                        values.UserID = userRecord.get('UserId');

                        if (values.Name == null || values.Name == '')
                        {
                            if (userRecord.get('LastName') != null && userRecord.get('LastName') != '')
                                values.Name = userRecord.get('FirstName') + ' ' + userRecord.get('LastName'); //updated 9/2/2016 per user request
                            else
                                values.Name = userRecord.get('DisplayName')
                        }

                        LABKEY.Query.insertRows({
                            schemaName: 'extscheduler',
                            queryName: 'events',
                            rows: [values],
                            scope: this,
                            success: function(response)
                            {
                                window.location.reload();
                            },
                            failure: function(response)
                            {
                                Ext.Msg.alert('Error', response.exception);
                            }
                        });

                    }
                }
            ];
        }

        this.callParent();
    },

    getStartDateField : function()
    {
        if (!this.startDateField)
        {
            this.startDateField = Ext.create('Ext.form.field.Date', {
                fieldLabel : 'Starts',
                labelWidth : 80,
                flex       : 1,
                name       : 'StartDate',
                format     : 'Y-m-d',
                allowBlank : !this.editable,
                bind       : {
                    value    : '{StartDate}',
                    readOnly : !this.editable
                }
            });

            this.startDateField.on('change', function(datefield, newValue){
                this.getEndDateField().setMinValue(newValue);
                if (this.getEndDateField().getValue() < newValue)
                    this.getEndDateField().setValue(newValue);
                this.getEndDateField().clearInvalid();

                if (this.getStartTimeField().getValue() == null)
                    this.getStartTimeField().setValue('8:00');

                this.ensureEndTimeAfterStart();

                this.getStartTimeField().enable();
                this.getEndDateField().enable();
                this.getEndTimeField().enable();
            }, this);
        }

        return this.startDateField;
    },

    getStartTimeField : function()
    {
        if (!this.startTimeField)
        {
            this.startTimeField = Ext.create('Ext.form.field.Time', {
                margin    : '0 0 0 10',
                width     : 90,
                name      : 'StartTime',
                format    : 'H:i',
                increment : this.eventPeriodLength,
                allowBlank : !this.editable,
                bind      : {
                    minValue : '{defaultMinTime}',
                    maxValue : '{defaultMaxTime}',
                    value    : '{StartTime}',
                    readOnly : !this.editable,
                    disabled : this.editable
                }
            });

            this.startTimeField.on('change', function(timefield, newValue){
                if (this.getEndTimeField().getValue() == null)
                    this.getEndTimeField().setValue(new Date(newValue.getTime() + (this.eventPeriodLength*60*1000)));

                this.ensureEndTimeAfterStart();
            }, this);
        }

        return this.startTimeField;
    },

    getEndDateField : function()
    {
        if (!this.endDateField)
        {
            this.endDateField = Ext.create('Ext.form.field.Date', {
                fieldLabel : 'Ends',
                labelWidth : 80,
                flex       : 1,
                name       : 'EndDate',
                format     : 'Y-m-d',
                allowBlank : !this.editable,
                bind       : {
                    minValue : '{minEndDate}',
                    value    : '{EndDate}',
                    readOnly : !this.editable,
                    disabled : this.editable
                }
            });

            this.endDateField.on('change', function(dateField, newValue){
                this.ensureEndTimeAfterStart();
            }, this);
        }

        return this.endDateField;
    },

    getEndTimeField : function()
    {
        if (!this.endTimeField)
        {
            this.endTimeField = Ext.create('Ext.form.field.Time', {
                margin    : '0 0 0 10',
                name      : 'EndTime',
                width     : 90,
                format    : 'H:i',
                increment : this.eventPeriodLength,
                allowBlank : !this.editable,
                bind      : {
                    minValue : '{minEndTime}',
                    maxValue : '{defaultMaxTime}',
                    value    : '{EndTime}',
                    readOnly : !this.editable,
                    disabled : this.editable
                }
            });

            this.endTimeField.on('change', function(timefield, newValue){
                this.ensureEndTimeAfterStart();
            }, this);
        }

        return this.endTimeField;
    },

    ensureEndTimeAfterStart : function()
    {
        var startDate = this.getStartDateField().getValue(),
                startTime = this.getStartTimeField().getValue(),
                endDate = this.getEndDateField().getValue(),
                endTime = this.getEndTimeField().getValue(),
                allNonNull = startDate != null && startTime != null && endDate != null && endTime != null;

        if (allNonNull && startDate.getTime() == endDate.getTime())
        {
            var d = new Date(startTime.getTime() + (this.eventPeriodLength*60*1000));
            this.getEndTimeField().setMinValue(d);

            if (startTime.getTime() >= endTime.getTime())
                this.getEndTimeField().setValue(d);
        }
        else
        {
            this.getEndTimeField().setMinValue('0:00');
        }
    }
});
