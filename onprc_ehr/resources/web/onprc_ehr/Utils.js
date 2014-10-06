/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.ns('ONPRC.Utils');

ONPRC.Utils = new function(){


    return {
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
        }
    }
}