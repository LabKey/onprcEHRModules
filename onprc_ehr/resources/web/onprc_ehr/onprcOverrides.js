/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('ONPRC_EHR');

/** Override to never sort the IDs */
LDK.Utils.splitIds = function(subjects, unsorted) {
    subjects = Ext4.String.trim(subjects);
    subjects = subjects.replace(/[\s,;]+/g, ';');
    subjects = subjects.replace(/(^;|;$)/g, '');
    subjects = subjects.toLowerCase();

    if (subjects){
        subjects = subjects.split(';');
    }
    else {
        subjects = [];
    }

    return Ext4.unique(subjects);
};
