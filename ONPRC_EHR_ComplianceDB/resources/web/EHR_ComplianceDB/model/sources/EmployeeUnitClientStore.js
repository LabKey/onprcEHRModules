/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @param fieldConfigs
 */
Ext4.define('ONPRC_EHR.data.EmployeeUnitClientStore', {
    extend: 'EHR.data.DataEntryClientStore',

    getKeyField: function() {
        return "objectid";
    }
});

// Hack the server store too so that we can match the saved records with their row in the form's store
Ext4.override(EHR.data.DataEntryServerStore, {

    getProxyKeyField: function() {
        var result = this.proxy.reader.getIdProperty();
        if (result === 'rowid') {
            result = 'objectid';
        }
        return result;
    }

});
