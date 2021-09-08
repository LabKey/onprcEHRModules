/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @param fieldConfigs
 */
Ext4.define('ONPRC_EHR.data.EmployeeClientStore', {
    extend: 'EHR.data.DataEntryClientStore',

    getKeyField: function() {
        return "objectid";
    }
});