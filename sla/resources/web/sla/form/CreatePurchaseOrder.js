
/**
 * Ext component for creating the input form and species grid for collecting/updating information about
 * a purchase order (see createPurchaseOrder.html and updatePurchaseOrder.html for usages).
 */
Ext4.define('SLA.panel.PurchaseOrderRequest', {

    extend: 'Ext.panel.Panel',

    bodyStyle: 'background-color: transparent;',
    border: false,
    autoScroll: true,

    isUpdate: false,
    adminContainer: null, // from the sla module SLAPurchaseOrderAdminContainer property
    initData: null, // provide on initialization for updating a purchase order
    savedDraftId: null, // provide on initialization to populate the order from a saved draft

    /**
     * This function will be called to initialize this Ext component.
     * Note the call to this.callParent as this is an override.
     */
    initComponent: function()
    {
        //Ext4.apply(this, {
        //    bodyStyle: 'padding: 5px;',
        //    defaults: {
        //        border: false
        //    },
        //    items: [{
        //        html: 'The birth/arrival screen will be disabled as a default.  You must enable the form in order to: <br> <ul><li>Get an Animal ID(s)</li><li>Secure the numbers for processing</li><li>Finish entering data on acquired numbers</li></ul><br><b>When you enable the form for data entry all others will automatically be blocked from using the form.</b> <br>Once you "Submit for Review" or "Save and Close", the birth/arrival form will be automatically be available for all other users. If you do not submit/save <i>please click the button below to exit data entry before leaving</i>, otherwise all other users will be permanently locked out. <br><br> If the birth/arrival form is unavailable and you believe it has been kept locked by mistake please first contact the person who locked the form. If they cannot be reached and it is a weekday please e-mail onprcitsupport@ohsu.edu with the subject "Priority 1 Work Stoppage: birth/arrival Form Locked". If it is a weekend please contact an RFO lead tech. Please take care not to request the birth/arrival form be unlocked unless you are confident the lock is in error, otherwise you will kick a user out of the birth/arrival form and prevent data entry.' ,
        //        style: 'padding-bottom: 10px;'
        //    },{
        //        itemId: 'infoArea',
        //        border: false
        //    },{
        //        layout: 'hbox',
        //        defaults: {
        //            style: 'margin-right: 5px;'
        //        },
        //    }]
        //});


        // add the initial form sections, start with just the protocol form if this is not an update
        var items = [
            this.getProtocolForm(),
            this.getPurchaseForm(),
            this.getPurchaseSpeciesGrid()
        ];

        // only add the confirmation details section in the insert new case for Editors
        if (this.isUpdate || LABKEY.user.canUpdate)
            items.push(this.getOrderDetailsForm());

        items.push(this.getFormFooter());

        this.items = items;

        this.dockedItems = [
            this.getBottomButtonBar()
        ];

        this.callParent();
    },



    /**
     * Initialize the Ext panel for selecting the IACUC protocol for a purchase order.
     * @returns {SLA.form.ProtocolForm}
     */
    getProtocolForm : function()
    {
        if (!this.protocolForm)
        {
            this.protocolForm = Ext4.create('SLA.form.ProtocolForm', {
                isUpdate: this.isUpdate,
                initData: this.initData ? this.initData.purchase.project : null,
                width: 1000,
                listeners: {
                    scope: this,
                    protocolselect: function(form, protocolData)
                    {
                        if (Ext4.isDefined(protocolData))
                        {
                            // update the related purchase form fields
                            this.getPurchaseForm().setFormValues({
                                project: protocolData['ProjectID'],
                                account: protocolData['Alias'],
                                grant: protocolData['OGAGrantNumber']
                            });
                        }
                    },
                    validitychange: function(form, isValid)
                    {
                        // when the validity of the form changes (i.e. required field completed),
                        // enable or disable the submit button accordingly
                        this.toggleSubmitButton();
                    }
                }
            });
        }

        return this.protocolForm;
    },

    /**
     * Initialize the Ext form panel to insert/update top-level information for a purchase order.
     * @returns {SLA.form.PurchaseForm}
     */
    getPurchaseForm : function()
    {
        if (!this.purchaseForm)
        {
            this.purchaseForm = Ext4.create('SLA.form.PurchaseForm', {
                isUpdate: this.isUpdate,
                initData: this.initData != null ? this.initData.purchase : {},
                width: 1000,
                padding: '15px 0 0 0',
                listeners: {
                    scope: this,
                    validitychange: function(form, isValid)
                    {
                        // when the validity of the form changes (i.e. required field completed),
                        // enable or disable the submit button accordingly
                        this.toggleSubmitButton();
                    },
                    noRequestorRecord: function(form)
                    {
                        Ext4.get('purchaseOrderErrors').update('<p class="labkey-error">'
                                + 'No requestor record found for your user account. Please contact an administrator to get '
                                + 'this issue resolved.</p>');
                        this.disable();
                    }
                }
            });
        }

        return this.purchaseForm;
    },

    /**
     * Initialize the Ext grid panel to insert/update species information for a purchase order.
     * @returns {SLA.form.SpeciesGrid}
     */
    getPurchaseSpeciesGrid : function()
    {
        if (!this.speciesGrid)
        {
            this.speciesGrid = Ext4.create('SLA.form.SpeciesGrid', {
                isUpdate: this.isUpdate,
                initData: this.initData != null ? this.initData.species : null,
                width: 1700,
                padding: '15px 0 5px 0',
                listeners: {
                    scope: this,
                    rowchange: function(grid)
                    {
                        // when the validity of the grid changes (i.e. rows added/removed/updated),
                        // enable or disable the submit button accordingly
                        this.toggleSubmitButton();
                    }
                }
            });
        }

        return this.speciesGrid;
    },

    /**
     * Initialize the Ext form panel used by admins after for submission to enter order confirmation details.
     * @returns {SLA.form.OrderConfirmationForm}
     */
    getOrderDetailsForm : function()
    {
        if (!this.orderDetailsForm)
        {
            this.orderDetailsForm = Ext4.create('SLA.form.OrderConfirmationForm', {
                initData: this.initData != null ? this.initData.purchase : {},
                width: 1275,
                padding: '10px 0 5px 0'
            });
        }

        return this.orderDetailsForm;
    },

    /**
     * Return true if this form does have the order confirmation form initialized.
     * @returns {boolean}
     */
    hasOrderDetailsForm : function()
    {
        return Ext4.isDefined(this.orderDetailsForm);
    },

    getFormFooter : function()
    {
        return {
            xtype: 'box',
            style: 'font-size: 11px; padding-left: 5px;',
            html: '* Required fields&nbsp;&nbsp;** At least one of the fields are required'
        };
    },

    /**
     * Helper function to create the config object for the bottom toolbar of the form panel.
     * @returns {Object} - Ext toolbar config object
     */
    getBottomButtonBar : function()
    {
        return {
            xtype: 'toolbar',
            dock: 'bottom',
            ui: 'footer',
            style: 'background-color: transparent;',
            padding: '10px 0',
            items: [
                this.getSubmitButton(),
                this.getSaveDraftButton(),
                this.getCancelButton()
            ]
        };
    },

    /**
     * Initialize the submit button for the form panel.
     * Note that it is initially disabled until the form panel and species grid have valid values.
     * @returns {Ext.button.Button|*}
     */
    getSubmitButton : function()
    {
        if (!this.submitButton)
        {
            this.submitButton = Ext4.create('Ext.button.Button', {
                text: 'Submit',
                hidden: this.isUpdate && !LABKEY.user.canUpdate,
                disabled: this.initData == null,
                handler: this.submitForm,
                scope: this
            });
        }

        return this.submitButton;
    },

    /**
     * Helper function to determine if the submit button should be enabled/disbaled based
     * on the form panela nd species grid values.
     */
    toggleSubmitButton : function()
    {
        var protocolValid = this.getProtocolForm().isValid(),
                formValid = this.getPurchaseForm().isValid(),
                speciesGridValid = this.getPurchaseSpeciesGrid().isValid();

        this.getSubmitButton().setDisabled(this.adminContainer == null || !protocolValid || !formValid || !speciesGridValid);
    },

    /**
     * Initialize the cancel button for the form panel.
     * @returns {Ext.button.Button}
     */
    getCancelButton : function()
    {
        if (!this.cancelButton)
        {
            this.cancelButton = Ext4.create('Ext.button.Button', {
                text: (this.isUpdate && !LABKEY.user.canUpdate) ? 'Done' : 'Cancel',
                handler: function() {
                    // use the ActionURL builder to generate a URL to go back to the project/container begin page
                    window.location = LABKEY.ActionURL.buildURL('project', 'begin');
                }
            });
        }

        return this.cancelButton;
    },

    /**
     * Initialize the save draft button for the form panel.
     * @returns {Ext.button.Button}
     */
    getSaveDraftButton : function()
    {
        if (!this.saveDraftButton)
        {
            this.saveDraftButton = Ext4.create('Ext.button.Button', {
                text: 'Save Draft',
                hidden: this.isUpdate,
                handler: this.saveDraft,
                scope: this
            });
        }

        return this.saveDraftButton;
    },

    /**
     * Helper function to loop through the keys of an object and replace the empty string values with null.
     * @param obj - the JavaScript object to update
     * @returns {Object}
     */
    trimEmptyValues : function(obj)
    {
        var newObj = {};
        Ext4.Object.each(obj, function(key, value)
        {
            newObj[key] = Ext4.isString(value) && value == "" ? null : value;
        });
        return newObj;
    },

    /**
     * Helper function to loop through the keys of an object and remove the null values.
     * @param obj - the JavaScript object to update
     * @returns {Object}
     */
    trimNullValues : function(obj)
    {
        var newObj = {};
        Ext4.Object.each(obj, function(key, value)
        {
            if (value != null)
                newObj[key] = value;
        });
        return newObj;
    },

    /**
     * Helper function to loop through the keys of an object and convert date values to strings.
     * @param obj - the JavaScript object to update
     * @returns {Object}
     */
    convertDateValuesToStr : function(obj)
    {
        var newObj = {};
        Ext4.Object.each(obj, function(key, value)
        {
            newObj[key] = Ext4.isDate(value) ? Ext4.util.Format.date(value, 'Y-m-d') : value;
        });
        return newObj;
    },

    /**
     * Helper function to consolidate the form values for the sla.purchase table record.
     * @returns {Object}
     */
    getFormPurchaseValues : function()
    {
        // if this is an admin update of the confirmation details, get those values
        var purchaseData = this.hasOrderDetailsForm()
                ? this.trimEmptyValues(this.getOrderDetailsForm().getForm().getValues())
                : {};

        // and get the values fromt eh main purchase order information form
        purchaseData = Ext4.apply(purchaseData, this.trimEmptyValues(this.getPurchaseForm().getForm().getValues()));

        return purchaseData;
    },

    /**
     * Function called when the save draft button is clicked for the form panel to persist a JSON version of the
     * current state of the purchase order.
     */
    saveDraft : function()
    {
        this.getSaveDraftButton().disable();

        var purchaseData = this.convertDateValuesToStr(this.trimNullValues(this.getFormPurchaseValues()));
        // objectid is a generated value, so don't persist it with the saved draft
        delete purchaseData['objectid'];

        var purchaseDetailsRows = [];
        Ext4.each(this.getPurchaseSpeciesGrid().getStore().getRange(), function(gridRow)
        {
            var detailRow = this.convertDateValuesToStr(this.trimNullValues(this.trimEmptyValues(gridRow.data)));
            // objectid is a generated value, so don't persist it with the saved draft
            delete detailRow['objectid'];
            // purchaseid will always be null for the draft, so don't persist it
            delete detailRow['purchaseid'];

            purchaseDetailsRows.push(detailRow);
        }, this);

        LABKEY.Ajax.request({
            url: LABKEY.ActionURL.buildURL('sla', 'savePurchaseOrderDraft.api'),
            method : 'POST',
            jsonData: {
                rowid: this.savedDraftId != null ? this.savedDraftId : undefined,
                owner: LABKEY.user.id,
                content: Ext4.JSON.encode({
                    purchase: purchaseData,
                    species: purchaseDetailsRows
                })
            },
            scope: this,
            failure: LABKEY.Utils.getCallbackWrapper(function(response) {
                this.getSaveDraftButton().enable();
                this.showErrorMsg(response.exception);
            }),
            success: function(response)
            {
                // on success, get the rowId primary key for the sla.purchaseDrafts table record
                var o = Ext4.JSON.decode(response.responseText);
                this.savedDraftId = o['rowid'];

                this.showSuccessMsg('Draft saved successfully.', function()
                {
                    this.getSaveDraftButton().enable();
                }, this);
            }
        });
    },

    /**
     * Function called when the submit button is clicked for the form panel to insert/update/delete
     * rows in the sla schema purchase and purchaseDetails tables.
     */
    submitForm : function()
    {
        this.getSubmitButton().disable();

        // build up the insert/update commands for the sla.purchase table
        var commands = [], purchaseData = this.getFormPurchaseValues();
        commands.push({
            command: this.isUpdate ? 'update' : 'insert',
            schemaName: 'sla',
            queryName: 'purchase',
            rows: [purchaseData]
        });

        // additional insert/update/delete commands for the sla.purchaseDetails table for each of the species grid row changes
        var speciesInserts = [], speciesUpdates = [], speciesDeletes = [], speciesObjectIds = {}, isHazardsRequired = false;
        Ext4.each(this.getPurchaseSpeciesGrid().getStore().getRange(), function(gridRow)
        {
            var speciesRowData = this.trimEmptyValues(gridRow.data);

            // generate a new objectid for the species grid row if one does not exist
            // (note: this will happen for viewing a saved draft)
            if (!speciesRowData.objectid)
            {
                speciesRowData.objectid = LABKEY.Utils.generateUUID();
            }

            // track objectids for inserts and updates so we know which ones were deleted
            speciesObjectIds[speciesRowData.objectid] = true;

            if (speciesRowData.purchaseid)
            {
                speciesUpdates.push(speciesRowData);
            }
            else
            {
                speciesRowData.purchaseid = purchaseData.objectid;
                speciesInserts.push(speciesRowData);
            }

            //added by Kolli
            if (speciesRowData.room == 'NSI 0123D' || speciesRowData.room == 'NSI 0125D' )
            {
                isHazardsRequired = true;
            }

        }, this);
        //if (isHazardsRequired && (purchaseData.listHazard == null || purchaseData.listHazard == ''))
        if (isHazardsRequired && (purchaseData.hazardslist == null || purchaseData.hazardslist == ''))
        {
            this.showErrorMsg('You have selected Location(s): NSI 0123D or NSI 0125D. Please list the biological or chemical agents! ');
            return;
        }

        // if we have at least one species grid row that is new, add an insert command
        if (speciesInserts.length > 0)
        {
            commands.push({
                command: 'insert',
                schemaName: 'sla',
                queryName: 'purchaseDetails',
                rows: speciesInserts
            });
        }
        // if we have at least one species grid row which previously existed and was updated, add an update command
        if (speciesUpdates.length > 0)
        {
            commands.push({
                command: 'update',
                schemaName: 'sla',
                queryName: 'purchaseDetails',
                rows: speciesUpdates
            });
        }

        // determine if any of the original species rows were deleted
        if (this.initData != null)
        {
            Ext4.each(this.initData.species, function(origSpeciesRow)
            {
                if (origSpeciesRow.objectid && !speciesObjectIds[origSpeciesRow.objectid])
                {
                    speciesDeletes.push({rowid: origSpeciesRow.rowid, objectid: origSpeciesRow.objectid})
                }
            });
        }
        // if we have at least one species grid row which was removed, add a delete command
        if (speciesDeletes.length > 0)
        {
            commands.push({
                command: 'delete',
                schemaName: 'sla',
                queryName: 'purchaseDetails',
                rows: speciesDeletes
            });
        }

        // Users with at least Editor permissions can use the standard LabKey saveRows API to insert/update
        // records in the adminContainer. Other users with only Author permissions (i.e. PIs and Technicians)
        // will need to use a custom SLAController API action to insert the data.
        if (LABKEY.user.canUpdate)
        {

            purchaseData.details = speciesInserts.concat(speciesUpdates);

            this.validateAnimalUsage(purchaseData, function()
            {
                var warnMsg = 'Please review all the entries before you submit the Purchase order! <br/>Press YES to proceed or NO to edit the order.<br/>';
                Ext4.Msg.confirm('Confirmation Message', warnMsg, function (btn)
                {
                    if (btn == 'yes')
                    //successCallback.call(scope);
                        this.saveRows(commands, purchaseData);
                    else
                        this.getSubmitButton().enable();
                }, this);

                // save all rows with a single API call so that they are transacted
                //this.saveRows(commands, purchaseData);
            }, this);
        }
        else
        {
            purchaseData.details = speciesInserts;

            // convert date values to strings for submit
            Ext4.each(purchaseData.details, function(detailRow)
            {
                detailRow = this.convertDateValuesToStr(detailRow);
            }, this);

            this.validateAnimalUsage(purchaseData, function()
            {
                var warnMsg = 'Please review all the entries before you submit the Purchase order! <br/>Press YES to proceed or NO to edit the order.<br/>Only SLAU Admin can make changes to the order after the submission!<br/>';
                Ext4.Msg.confirm('Confirmation Message', warnMsg, function (btn)
                {
                    if (btn == 'yes')
                    //successCallback.call(scope);
                        this.insertPurchaseOrder(purchaseData);
                    else
                        this.getSubmitButton().enable();
                }, this);

                // this.insertPurchaseOrder(purchaseData);
            }, this);
        }
    },

    validateAnimalUsage : function(purchaseData, successCallback, scope)
    {
        // on new order submission, validate the requested animal count against the allowable animal count
        if (!this.isUpdate)
        {
            this.queryProjectAnimalAllowedUsage(purchaseData, successCallback, scope);
        }
        else
        {
            successCallback.call(scope);
        }
    },

    queryProjectAnimalAllowedUsage : function(purchaseData, successCallback, scope)
    {
        LABKEY.Query.selectRows({
            schemaName: 'sla_public',
            queryName: 'ProtocolProjectsUsage',
            //columns: 'Species,Gender,Strain,NumAllowed,NumUsed',
            columns: 'Species,Gender,NumAllowed,NumUsed',
            filterArray: [LABKEY.Filter.create('ProjectID', purchaseData.project)],
            scope: this,
            success: function(data)
            {
                var allowableAnimalUsage = {};
                Ext4.each(data.rows, function(row)
                {
                    //var key = row.Species + '|' + row.Gender + '|' + row.Strain;
                    var key = row.Species + '|' + row.Gender;

                    if (!allowableAnimalUsage[key])
                    {
                        allowableAnimalUsage[key] = {
                            Species: row.Species,
                            Gender: row.Gender,
                            //Strain: row.Strain,
                            NumAllowed: 0,
                            NumUsed: 0
                        };
                    }

                    allowableAnimalUsage[key].NumAllowed += row.NumAllowed;
                    allowableAnimalUsage[key].NumUsed += row.NumUsed;
                });

                this.checkProjectAnimalUsage(allowableAnimalUsage, purchaseData, successCallback, scope);
            },
            failure: function(response)
            {
                this.getSubmitButton().enable();
                this.showErrorMsg(response.exception);
            }
        });
    },

    checkProjectAnimalUsage : function(allowableAnimalUsage, purchaseData, successCallback, scope)
    {
        var requestedAnimalUsage = {}, requestedKeyDoesNotExist = {};
        Ext4.each(purchaseData.details, function(detail)
        {
            //var key = detail.species + '|' + detail.gender + '|' + detail.strain;
            var key = detail.species + '|' + detail.gender;

            if (!requestedAnimalUsage[key])
            {
                requestedAnimalUsage[key] = {
                    NumAnimalsOrdered: 0,
                    Species: '',
                    Gender: '',
                    //Strain: '',
                    NumAllowed: 0,
                    PercentUsed: 0
                };
            }

            requestedAnimalUsage[key].NumAnimalsOrdered += (detail.animalsordered != null ? detail.animalsordered : 0);

            var allowableAnimalData = allowableAnimalUsage[key];

            // for gender "Male" or "Female" also check "Male or Female"
            if (!allowableAnimalData)
                allowableAnimalData = allowableAnimalUsage[detail.species + '|Male or Female'];

            if (!allowableAnimalData)
            {
                requestedKeyDoesNotExist[key] = detail;
            }
            else if (allowableAnimalData.NumAllowed > 0)
            {
                var perc = (allowableAnimalData.NumUsed + requestedAnimalUsage[key].NumAnimalsOrdered) / allowableAnimalData.NumAllowed;
                requestedAnimalUsage[key].PercentUsed = Ext4.util.Format.round(perc * 100, 1);

                requestedAnimalUsage[key].Species = detail.Species;
                requestedAnimalUsage[key].Gender = detail.Gender;
                //requestedAnimalUsage[key].Strain = detail.Strain;
                requestedAnimalUsage[key].NumAllowed = allowableAnimalData.NumAllowed;
            }
        });

        // give an error for any requested Species/Gender/Strain combinations that don't exist for the selected project allowableAnimals
        if (Object.keys(requestedKeyDoesNotExist).length > 0)
        {
            var errorMsg = '', sep = '';
            Ext4.Object.each(requestedKeyDoesNotExist, function(key, value)
            {
                //errorMsg += sep + 'This order cannot be completed as the IACUC approval data is not available for:<br/>Species = '
                //        + value.species + ', Sex = ' + value.gender + ', Strain = ' + value.strain + '<br/><br/>Please contact SLAU administrator for more information!';
                errorMsg += sep + 'This order cannot be completed as the IACUC approval data is not available for:<br/>Species = '
                        + value.species + ', Sex = ' + value.gender + '<br/><br/>Please contact SLAU administrator for more information!';
                sep = '<br/><br/>';
            });

            this.getSubmitButton().enable();
            this.showErrorMsg(errorMsg);
        }
        else
        {
            // Allable animal validation: error if ordered + received > 105% and warn if > 90% ordered + received
            var errorMsg = '', errorSep = '', warnMsg = '', warnSep = '';
            Ext4.Object.each(requestedAnimalUsage, function(key, value)
            {
                //var baseMsg = 'Total number of animals originally approved by the IACUC committee is: '
                //        + 'Species = ' + value.Species + ', Sex = ' + value.Gender
                //        + ', Strain = ' + value.Strain + ', <b>Num approved = ' + value.NumAllowed + '</b>.';

                var baseMsg = 'Total number of animals originally approved by the IACUC committee is: '
                        + 'Species = ' + value.Species + ', Sex = ' + value.Gender
                        + ', <b>Num approved = ' + value.NumAllowed + '</b>.';

                if (value.PercentUsed > 105)
                {
                    errorMsg += errorSep + 'With the current order, you have <b>exceeded 100% plus 5% more</b> animal usage of the approved quantity. ' + baseMsg
                            + ' You are not authorized to purchase any more animals at this point. If you wish to purchase more animals, please contact the IACUC committee for approval!';
                    errorSep = '<br/><br/>';
                }
                else if (value.PercentUsed > 100)
                {
                    warnMsg += warnSep + 'With the current order, you have <b>exceeded 100%</b> animal usage of the approved quantity. ' + baseMsg
                            + ' According to IACUC committee, you can order 5% more animals than the approved quantity without IACUC approval. '
                            + 'Therefore in this order, you can order an <b>extra ' + Math.floor(value.NumAllowed * 0.05) + '</b> animal(s). '
                            + 'If you wish to purchase more animals, please contact the IACUC committee for approval!';
                    warnSep = '<br/><br/>';
                }
                else if (value.PercentUsed == 100)
                {
                    warnMsg += warnSep + 'With the current order, you have <b>reached 100%</b> animal usage of the approved quantity. ' + baseMsg;
                    warnSep = '<br/><br/>';
                }
                else if (value.PercentUsed > 90)
                {
                    warnMsg += warnSep + 'With the current order, you have <b>exceeded 90%</b> animal usage of the approved quantity. ' + baseMsg;
                    warnSep = '<br/><br/>';
                }
                else if (value.PercentUsed == 90)
                {
                    warnMsg += warnSep + 'With the current order, you have <b>reached 90%</b> animal usage of the approved quantity. ' + baseMsg;
                    warnSep = '<br/><br/>';
                }
            });

            if (errorMsg.length > 0)
            {
                this.getSubmitButton().enable();
                this.showErrorMsg(errorMsg);
            }
            else if (warnMsg.length > 0)
            {
                warnMsg += '<br/><br/>Would you like to proceed?';
                Ext4.Msg.confirm('Warning', warnMsg, function (btn)
                {
                    if (btn == 'yes')
                        successCallback.call(scope);
                    else
                        this.getSubmitButton().enable();
                }, this);
            }
            else
            {
                successCallback.call(scope);
            }
        }
    },

    saveRows : function(commands, purchaseData)
    {
        LABKEY.Query.saveRows({
            containerPath: this.adminContainer,
            commands: commands,
            scope: this,
            success: function(response)
            {
                // on success, get the rowId primary key for the sla.purchase table record
                var purchaseRowId = null, objectId = null;
                for (var i = 0; i < response.result.length; i++)
                {
                    if (response.result[i].queryName == 'purchase')
                    {
                        purchaseRowId = response.result[i].rows[0].rowid;
                        objectId = response.result[i].rows[0].objectid;
                        break;
                    }
                }

                this.sendOrderNotification(purchaseRowId, objectId, purchaseData);
            },
            failure: function(response)
            {
                this.getSubmitButton().enable();
                this.showErrorMsg(response.exception);
            }
        });
    },

    insertPurchaseOrder : function(purchaseData)
    {
        LABKEY.Ajax.request({
            url: LABKEY.ActionURL.buildURL('sla', 'insertPurchaseOrder.api'),
            method : 'POST',
            jsonData: purchaseData,
            scope: this,
            failure: LABKEY.Utils.getCallbackWrapper(function(response) {
                this.getSubmitButton().enable();
                this.showErrorMsg(response.exception);
            }),
            success: function(response)
            {
                // on success, get the rowId primary key for the sla.purchase table record
                var o = Ext4.JSON.decode(response.responseText);
                this.sendOrderNotification(o['rowid'], o['objectid'], purchaseData);
            }
        });
    },

    /**
     * Send an email notification with a link to the review page.
     * @param rowId - rowId for the sla.purchase table record for this submission
     * @param objectid - objectid for the sla.purchase table record for this submission
     */
    sendOrderNotification : function(rowId, objectid, newPurchaseData)
    {
        // send email notifications for new order submission or order details updates to key fields
        var sendNotification = !this.isUpdate;
        if (!sendNotification && this.initData != null)
        {
            var prevConfNum = this.initData.purchase['confirmationnum'],
                    newConfNum = newPurchaseData['confirmationnum'],
                    prevOrderDt = this.trimDateToYMDStr(this.initData.purchase['orderdate']),
                    newOrderDt = this.trimDateToYMDStr(newPurchaseData['orderdate']),
                    prevHousingAvail = this.initData.purchase['housingconfirmed'],
                    newHousingAvail = newPurchaseData['housingconfirmed'];

            sendNotification = prevConfNum != newConfNum || prevOrderDt != newOrderDt;

            // send notification if Housing Availability is Denied
            if (!sendNotification && prevHousingAvail != 3 && newHousingAvail == 3)
                sendNotification = true;

            // verify if any key fields in purchaseDetails records updated (receiveddate, receivedby, datecancelled, cancelledby, housingconfirmed)
            if (!sendNotification)
            {
                var prevDetailsMap = {};
                Ext4.each(this.initData.species, function (speciesRow)
                {
                    prevDetailsMap[speciesRow['objectid']] = speciesRow;
                });

                Ext4.each(newPurchaseData.details, function (detailsRow)
                {
                    var objectid = detailsRow['objectid'],
                            receiveddate = Ext4.isDate(detailsRow['receiveddate']) ? Ext4.util.Format.date(detailsRow['receiveddate'], 'Y-m-d') : this.trimDateToYMDStr(detailsRow['receiveddate']),
                            receivedby = detailsRow['receivedby'],
                            datecancelled = Ext4.isDate(detailsRow['datecancelled']) ? Ext4.util.Format.date(detailsRow['datecancelled'], 'Y-m-d') : this.trimDateToYMDStr(detailsRow['datecancelled']),
                            cancelledby = detailsRow['cancelledby'];

                    // compare new values to previous, or if this is a new species row, check for non-null key values
                    if (Ext4.isDefined(prevDetailsMap[objectid]))
                    {
                        var prevReceiveddate = this.trimDateToYMDStr(prevDetailsMap[objectid]['receiveddate']),
                                prevReceivedby = prevDetailsMap[objectid]['receivedby'],
                                prevDatecancelled = this.trimDateToYMDStr(prevDetailsMap[objectid]['datecancelled']),
                                prevCancelledby = prevDetailsMap[objectid]['cancelledby'];

                        sendNotification = prevReceiveddate != receiveddate || prevReceivedby != receivedby
                                || prevDatecancelled != datecancelled || prevCancelledby != cancelledby;
                    }
                    else if (receiveddate != null || receivedby != null || datecancelled != null || cancelledby != null)
                    {
                        sendNotification = true;
                    }

                    if (sendNotification)
                        return false; // break from loop
                }, this);
            }
        }

        if (sendNotification)
        {
            LABKEY.Ajax.request({
                url: LABKEY.ActionURL.buildURL('sla', 'sendPurchaseOrderNotification.api'),
                method: 'POST',
                params: {
                    rowId: rowId,
                    objectId: objectid,
                    action: this.isUpdate ? 'UPDATED' : 'SUBMITTED'
                },
                scope: this,
                failure: LABKEY.Utils.getCallbackWrapper(function (response)
                {
                    this.getSubmitButton().enable();
                    this.showErrorMsg(response.exception);
                }),
                success: function (response)
                {
                    this.showSuccess(rowId);
                    this.insertMiscCharges(rowId,newPurchaseData);
                }
            });
        }
        else
        {
            this.showSuccess(rowId);
            this.insertMiscCharges(rowId,newPurchaseData);
        }

    },

    ////Kollil: If the new receiving info is entered, Insert a row into the onprc_billing.miscCharges table
    //insertMiscCharges : function (rowId,newPurchaseData)
    //{
    //    var miscCharges=[];
    //    var prevDetailsMap = {};
    //    var vendor_id ;
    //
    //    //Get the vendor id for the given name
    //    LABKEY.Query.executeSql({
    //        method: 'POST',
    //        schemaName: 'sla_public',
    //        sql: "Select objectid from vendors where name = 'ONPRC Weaning - SLA'",
    //        //failure: LDK.Utils.getErrorCallback(),
    //        success: function(data)
    //        {
    //            // we expect exactly one row in the response, so if that is not the case return an 'Invalid' error
    //            if (data.rows.length != 1)
    //            {
    //                response.error = 'Invalid vendorid';
    //                callback.call(scope, response);
    //            }
    //            else
    //            {
    //                vendor_id = data.rows[0].objectid;
    //
    //    //        }
    //    //    }
    //    //});
    //                // Get previous purchase data
    //                Ext4.each(this.initData.species, function (speciesRow)
    //                {
    //                    prevDetailsMap[speciesRow['objectid']] = speciesRow;
    //                });
    //                // Get New purchase data
    //                Ext4.each(newPurchaseData.details, function (detailsRow)
    //                {
    //                    var objectid = detailsRow['objectid'],
    //                            receiveddate = Ext4.isDate(detailsRow['receiveddate']) ? Ext4.util.Format.date(detailsRow['receiveddate'], 'Y-m-d') : this.trimDateToYMDStr(detailsRow['receiveddate']),
    //                            receivedby = detailsRow['receivedby'];
    //
    //                    if (Ext4.isDefined(prevDetailsMap[objectid]))
    //                    {
    //                        var prevReceiveddate = this.trimDateToYMDStr(prevDetailsMap[objectid]['receiveddate']),
    //                                prevReceivedby = prevDetailsMap[objectid]['receivedby'];
    //
    //                        //Compare the receiving info with the previous data
    //                        if ((prevReceiveddate == null & receiveddate != null) || (prevReceivedby == null & receivedby != null))
    //                        {
    //                            //if (newPurchaseData['vendorid.name'] == 'ONPRC Weaning - SLA')
    //                            if (newPurchaseData['vendorid'] == vendor_id)
    //                            {
    //                                miscCharges.push({
    //                                    "date": receiveddate,
    //                                    "project": newPurchaseData['project'],
    //                                    "objectid": LABKEY.Utils.generateUUID(),
    //                                    //"category": 'SLA Fees',
    //                                    "chargeType": 'SLAU',
    //                                    "chargeId": 5398, //Chargeableitem: ChargeName = 'SLAU Weaning Fee', ChargeID = 5398
    //                                    "quantity": 1, //detailsRow['NumAnimalsReceived'],
    //                                    "comment": 'SLA Weaning',
    //                                });
    //                            }
    //                            else
    //                            {
    //                                miscCharges.push({
    //                                    "date": receiveddate,
    //                                    "project": newPurchaseData['project'],
    //                                    "objectid": LABKEY.Utils.generateUUID(),
    //                                    //"category": 'SLA Fees',
    //                                    "chargeType": 'SLAU',
    //                                    "chargeId": 5331, //Chargeableitem: ChargeName = 'SLAU Animal Purchase', ChargeID = 5331
    //                                    "quantity": 1, //detailsRow['NumAnimalsReceived'],
    //                                    "comment": 'SLA Purchase billing',
    //                                });
    //                            }
    //                        }
    //                    }
    //                },this);
    //
    //                if (miscCharges.length > 0 )
    //                {
    //                    LABKEY.Query.insertRows({
    //                        containerPath: '/ONPRC/EHR',
    //                        schemaName: 'onprc_billing',
    //                        queryName: 'miscCharges',
    //                        rows: miscCharges,
    //                        scope: this,
    //                        success: function ()
    //                        {
    //                            this.showSuccess(rowId);
    //                        },
    //                        failure: function(response)
    //                        {
    //                            console.error(response.exception);
    //                            this.showErrorMsg(response.exception);
    //                        }
    //                    });
    //                }
    //                else
    //                {
    //                    this.showSuccess(rowId);
    //                }
    //
    //            }
    //        }
    //    });
    //},


    //Kollil: If the new receiving info is entered, Insert a row into the onprc_billing.miscCharges table
    insertMiscCharges : function (rowId,newPurchaseData)
    {
        var miscCharges=[];
        var prevDetailsMap = {};
        //var vendor_id ;

        ////Get the vendor id for the given name
        //LABKEY.Query.executeSql({
        //    method: 'POST',
        //    schemaName: 'sla_public',
        //    sql: "Select objectid from vendors where name = 'ONPRC Weaning - SLA'",
        //    //failure: LDK.Utils.getErrorCallback(),
        //    success: function(data)
        //    {
        //        // we expect exactly one row in the response, so if that is not the case return an 'Invalid' error
        //        if (data.rows.length != 1)
        //        {
        //            response.error = 'Invalid vendorid';
        //            callback.call(scope, response);
        //        }
        //        else
        //        {
        //            vendor_id = data.rows[0].objectid;
        //        }
        //    }
        //});

        // Get previous purchase data
        Ext4.each(this.initData.species, function (speciesRow)
        {
            prevDetailsMap[speciesRow['objectid']] = speciesRow;
        });
        // Get New purchase data
        Ext4.each(newPurchaseData.details, function (detailsRow)
        {
            var objectid = detailsRow['objectid'],
                    receiveddate = Ext4.isDate(detailsRow['receiveddate']) ? Ext4.util.Format.date(detailsRow['receiveddate'], 'Y-m-d') : this.trimDateToYMDStr(detailsRow['receiveddate']),
                    receivedby = detailsRow['receivedby'];

            if (Ext4.isDefined(prevDetailsMap[objectid]))
            {
                var prevReceiveddate = this.trimDateToYMDStr(prevDetailsMap[objectid]['receiveddate']),
                        prevReceivedby = prevDetailsMap[objectid]['receivedby'];

                //Compare the receiving info with the previous data
                if ((prevReceiveddate == null & receiveddate != null) || (prevReceivedby == null & receivedby != null))
                {
                    if (this.initData.purchase.vendor == 'ONPRC Weaning - SLA')
                    //if (newPurchaseData['vendorid'] == vendor_id)
                    {
                        miscCharges.push({
                            "date": receiveddate,
                            "project": newPurchaseData['project'],
                            "objectid": LABKEY.Utils.generateUUID(),
                            //"category": 'SLA Fees',
                            "chargeType": 'SLAU',
                            "chargeId": 5398, //Chargeableitem: ChargeName = 'SLAU Weaning Fee', ChargeID = 5398
                            "quantity": 1, //detailsRow['NumAnimalsReceived'],
                            "comment": 'SLA Weaning'
                        });
                    }
                    //Added by Kolli on 03-01-2019
                    else if (this.initData.purchase.vendor == 'ONPRC Weaning - Self Prepared')
                    {
                        miscCharges.push({
                            "date": receiveddate,
                            "project": newPurchaseData['project'],
                            "objectid": LABKEY.Utils.generateUUID(),
                            //"category": 'SLA Fees',
                            "chargeType": 'SLAU',
                            "chargeId": 5614, //Chargeableitem: ChargeName = 'SLAU Weaning - No Staff', ChargeID = 5398
                            "quantity": 1, //detailsRow['NumAnimalsReceived'],
                            "comment": 'SLA Weaning - Self Prepared'
                        });
                    }
                    else
                    {
                        miscCharges.push({
                            "date": receiveddate,
                            "project": newPurchaseData['project'],
                            "objectid": LABKEY.Utils.generateUUID(),
                            //"category": 'SLA Fees',
                            "chargeType": 'SLAU',
                            "chargeId": 5331, //Chargeableitem: ChargeName = 'SLAU Animal Purchase', ChargeID = 5331
                            "quantity": 1, //detailsRow['NumAnimalsReceived'],
                            "comment": 'SLA Purchase billing'
                        });
                    }
                }
            }
        },this);

        if (miscCharges.length > 0 )
        {
            LABKEY.Query.insertRows({
                containerPath: '/ONPRC/EHR',
                schemaName: 'onprc_billing',
                queryName: 'miscCharges',
                rows: miscCharges,
                scope: this,
                success: function ()
                {
                    this.showSuccess(rowId);
                },
                failure: function(response)
                {
                    console.error(response.exception);
                    this.showErrorMsg(response.exception);
                }
            });
        }
        else
        {
            this.showSuccess(rowId);
        }
    },


    trimDateToYMDStr : function(val)
    {
        var newVal = val != null && val.indexOf(' ') > 0 ? val.substring(0, val.indexOf(' ')) : val;
        newVal = newVal != null ? newVal.replace(/\//g, '-') : newVal;
        return newVal;
    },

    /**
     * If we were using a saved draft for the form submission, delete it.
     */
    deleteSavedDraft : function(callbackFn, callbackScope)
    {
        if (this.savedDraftId != null)
        {
            LABKEY.Ajax.request({
                url: LABKEY.ActionURL.buildURL('sla', 'savePurchaseOrderDraft.api'),
                method : 'POST',
                jsonData: {
                    rowid: this.savedDraftId,
                    toBeDeleted: true
                },
                scope: this,
                failure: LABKEY.Utils.getCallbackWrapper(function(response) {
                    this.showErrorMsg(response.exception);
                    callbackFn.call(callbackScope);
                }),
                success: function(response)
                {
                    callbackFn.call(callbackScope);
                }
            });
        }
        else
        {
            callbackFn.call(callbackScope);
        }
    },

    /**
     * Display a success message to the user and navigate to the review order page on alert close.
     */
    showSuccess : function(purchaseRowId)
    {
        var msg = 'Purchase order ' + (this.isUpdate ? 'updated' : 'submitted') + ' successfully.';
        this.showSuccessMsg(msg, function()
        {
            this.deleteSavedDraft(function()
            {
                // redirect to the purchase order review page
                window.location = LABKEY.ActionURL.buildURL('sla', 'reviewPurchaseOrder', null, {rowId: purchaseRowId});
            }, this);
        }, this);
    },

    showSuccessMsg : function(msg, successCallback, scope)
    {
        var msgBox = Ext4.Msg.show({
            title: 'Success',
            msg: '<span class="labkey-message">' + msg + '</span>',
            icon: Ext4.Msg.INFO,
            closable: false
        });

        var msgBoxCloseTask = new Ext.util.DelayedTask(function(){
            msgBox.close();
            successCallback.call(scope);
        }, this);

        msgBoxCloseTask.delay(2000);
    },

    showErrorMsg : function(msg)
    {
        Ext4.Msg.show({
            title: 'Error',
            msg: msg,
            buttons: Ext4.Msg.OK,
            icon: Ext4.Msg.ERROR
        });
    }
});




