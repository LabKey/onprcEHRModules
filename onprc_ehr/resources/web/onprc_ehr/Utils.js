/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.ns('ONPRC.Utils');

ONPRC.Utils = new function(){


    return {
        sessionId: null,

        getNavItems: function(config){
            return LABKEY.Ajax.request({
                url : LABKEY.ActionURL.buildURL('onprc_ehr', 'getNavItems', config.containerPath),
                method : 'POST',
                scope: config.scope,
                failure: LDK.Utils.getErrorCallback({
                    callback: config.failure,
                    scope: config.scope
                }),
                success: LABKEY.Utils.getCallbackWrapper(LABKEY.Utils.getOnSuccess(config), config.scope)
            });
        },
        getpairingStore: function(){
            if (ONPRC_EHR._pairingStore)
                return ONPRC_EHR._pairingStore;

            var storeId = ['onprc_ehr', 'Pairingmenus', 'value', 'category'].join('||');

            ONPRC_EHR._pairingStore = Ext4.StoreMgr.get(storeId) || Ext4.create('LABKEY.ext4.data.Store', {
                type: 'labkey-store',
                schemaName: 'onprc_ehr',
                queryName: 'Pairingmenus',
                columns: 'value, category',
                filterArray: [LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)],
                sort: 'value',
                storeId: storeId,
                autoLoad: true,
                getRecordForCode: function(value){
                    var recIdx = this.findExact('value', value);
                    if (recIdx != -1){
                        return this.getAt(recIdx);
                    }
                }
            });

            return ONPRC_EHR._pairingStore;
        },

        getpairingObservationTypesStore: function() {
            if (ONPRC_EHR._pairingobservationTypesStore)
                return ONPRC_EHR._pairingobservationTypesStore;

            EHR._observationTypesStore = Ext4.create('LABKEY.ext4.data.Store', {
                type: 'labkey-store',
                schemaName: 'onprc_ehr',
                queryName: 'observation_types',
                columns: 'value,editorconfig',
                autoLoad: true
            });
        },

            preloadSession: function() {
            LABKEY.Ajax.request({
                url: LABKEY.ActionURL.buildURL('onprc_ehr', 'getSessionId'),
                method: 'POST',
                scope: this,
                failure: function() {
                    console.log('Failed to preload session ID');
                },
                success: LABKEY.Utils.getCallbackWrapper(function(args) {
                    this.sessionId = args.SessionId;
                }, this)
            })
        },

        getSsrsReportUrl: function(reportPath, params) {
            const baseUrl = LABKEY.getModuleProperty('ONPRC_EHR', 'SSRSServerURL');
            const ssrsFolder = LABKEY.getModuleProperty('ONPRC_EHR', 'SSRSReportFolder');
            return baseUrl + '/' + ssrsFolder + '/' + reportPath + '&' + LABKEY.ActionURL.queryString(params);
        },

        /**
         * Handles the SessionID and HostName parameters.
         * @param extraParams any extra parameters to add
         * @param clearSession whether to add 'rs:ClearSession=true'
         * @param command whether to add 'rs:Command=render'
         */
        getSsrsParams: function(extraParams, clearSession, command) {
            if (!this.sessionId) {
                const message = 'Failed to preload session ID for SSRS callback';
                Ext4.Msg.alert('Error', message);
                // Bail out since we can't redirect to SSRS as desired
                throw message;
            }
            else {
                const result = {
                    SessionId: this.sessionId,
                    HostName: location.hostname
                }

                if (clearSession) {
                    result['rs:ClearSession'] = true;
                }
                if (command) {
                    result['rs:Command'] = 'render';
                }

                if (extraParams) {
                    Ext4.apply(result, extraParams);
                }

                return result;
            }
        }
    }
}