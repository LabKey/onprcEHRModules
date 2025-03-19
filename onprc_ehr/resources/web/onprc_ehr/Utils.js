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

        getSsrsParams: function(extraParams, clearSession, command) {
            if (!this.sessionId) {
                const message = 'Failed to preload session ID for SSRS callback';
                Ext4.Msg.alert('Error', message);
                // Bail out since we can't redirect to SSRS as desired
                throw message;
            }
            else {
                const result = {
                    SessionID: this.sessionId,
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