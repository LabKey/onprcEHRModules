/*
 * Copyright (c) 2012-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('EHR.reports');

//this contains ONPRC-specific reports that should be loaded on the animal history page
//this file is registered with EHRService, and should auto-load whenever EHR's
//dependencies are requested, provided this module is enabled

EHR.reports.hematology = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    var miscConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyMisc',
        title: "Misc Tests" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: miscConfig
    });

    var resultsConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyRefRange',
        //viewName: 'Plus Ref Range',
        title: "Reference Ranges:",
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: resultsConfig
    });
};

EHR.reports.antibioticSensitivity = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'antibioticSensitivityPivoted',
        title: "Common Antibiotics" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    var miscConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'antibioticSensitivityMisc',
        title: "Misc Antibiotics" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: miscConfig
    });
};

EHR.reports.iStat = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'iStatPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    var miscConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'iStatMisc',
        title: "Misc Tests" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: miscConfig
    });

    var resultsConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'iStatRefRange',
        title: "Reference Ranges:",
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: resultsConfig
    });
}



EHR.reports.clinMedicationSchedule = function(panel, tab){
    EHR.reports.medicationSchedule(panel, tab, 'Clinical Medications');
};

EHR.reports.dietSchedule = function(panel, tab){
    EHR.reports.medicationSchedule(panel, tab, 'Diets');
};

EHR.reports.surgMedicationSchedule = function(panel, tab){
    EHR.reports.medicationSchedule(panel, tab, 'Surgical Medications');
};

EHR.reports.incompleteTreatments = function(panel, tab){
    EHR.reports.medicationSchedule(panel, tab, 'Incomplete Treatments');
};
EHR.reports.currentBlood = function(panel, tab){
    var  showActionsBtn = true;
    tab.add({
        html: 'This report summarizes the blood available for the animals below. The method field in the display shows which method was used for calculation.  BC represents calculation based on Body Condition Score and RF represent the use of the standard Fixed Ratio. For more detail on this calculation,  <a href="https://prime.ohsu.edu/_webdav/ONPRC/Admin/Compliance/Public/%40files/Research%20Support/RS-001-02%20NHP%20Blood%20Collection.pdf" target="_blank">Please see the PDF Here</a>.' +
        '<br><br>There are 2 fields relating to blood value. One is Allowable Blood which is the calcuated max allowable value for the animal and Available Blood which represents current available minus any approved pending requests.' +
        '<br><br>If there have been recent blood draws for the animal, a graph will show the available blood over time.  On the graph, dots indicate dates when either blood was drawn or a previous blood draw fell off.  The horizontal lines indicate the maximum allowable blood that can be drawn on that date.',
        border: false,
        style: 'padding-bottom: 20px;'
    });
    if (tab.filters.subjects){
        renderSubjects(tab.filters.subjects, tab);
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, renderSubjects, this);
    }

    function renderSubjects(subjects, tab){

        var toAdd = [];
//
        if (subjects.length < 2)
        {
            for (var i = 0; i < subjects.length; i++)
            {
                var str = subjects[i];
                var filterArray = panel.getFilterArray(tab);
                var title = panel.getTitleSuffix();
                toAdd.push({
                    xtype: 'onprc-bloodsummarypanel',
                    subjects: subjects
                }, {
                    xtype: 'ldk-querypanel',

                    style: 'margin-bottom:20px;',
                    queryConfig: {
                        title: 'Blood Draw Summary for:' + title,

                        schemaName: 'study',
                        queryName: 'currentBloodDraws',
                        parameters: {
                            //NOTE: this is currently hard-coded for perf.
                            DATE_INTERVAL: 21
                        },
                        //  viewName: 'NewBloodCalc',
                        filterArray: filterArray.removable.concat(filterArray.nonRemovable),
                        success: function(results){
                            // if(results.totalRows < 1)
                            //     tab.add({
                            //         html: 'Test of no records.',
                            //         border: false,
                            //          style: 'padding-bottom: 20px;'
                            //      });
                            //
                            //
                        }
                    }
                });
            }
        }
        else {
            toAdd.push({
                html: 'Because more than 10 subjects were selected, the condensed report is being shown.  Note that you can click the animal ID to open this same report in a different tab, showing that animal in more detail or click the link labeled \'Display History\'.',
                style: 'padding-bottom: 20px;',
                border: false
            });

            var filterArray = panel.getFilterArray(tab);
            var title = panel.getTitleSuffix();
            toAdd.push({
                xtype: 'ldk-querypanel',
                style: 'margin-bottom:20px;',
                queryConfig: {
                    title: 'Overview' + title,
                    schemaName: 'study',
                    queryName: 'demographicsBloodSummary',//'demographicsBloodSummary',
                 //   viewName: 'NewBloodCalc',
            filterArray: filterArray.removable.concat(filterArray.nonRemovable)
        }
        });
        }

        if (toAdd.length)
            tab.add(toAdd);
    }

};



EHR.reports.medicationSchedule = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var date = Ext4.Date.format(new Date(), LABKEY.extDefaultDateFormat);
    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'treatmentSchedule',
            viewName: viewName,
            title: viewName + ' ' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            parameters: {
                StartDate: date,
                NumDays: 1
            }
        })
    });
}

EHR.reports.bloodSchedule = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    filterArray.removable = filterArray.removable || [];
    filterArray.removable.push(LABKEY.Filter.create('date', new Date(), LABKEY.Filter.Types.DATE_EQUAL));

    filterArray.nonRemovable = filterArray.nonRemovable || [];
    filterArray.nonRemovable.push(LABKEY.Filter.create('qcstate/label', 'Request:', LABKEY.Filter.Types.STARTS_WITH));

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'blood',
            viewName: 'Requests',
            title: 'Daily Blood Schedule' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });
};

EHR.reports.pairHistory = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var date = Ext4.Date.format(Ext4.Date.add(new Date(), Ext4.Date.YEAR, -5), LABKEY.extDefaultDateFormat);
    tab.add({
        html: 'This report summarizes all animals paired in a cage in the past 5 years, along with any pairing comments entered during this time period.  Note: periods of group housing are not displayed on this report.',
        border: false,
        style: 'padding-bottom: 20px;'
    },{
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'pairHistory',
            title: 'Pair History' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            parameters: {
                StartDate: date
            }
        })
    });
};

EHR.reports.underConstruction = function(panel, tab){
    tab.add({
        html: 'This report is being developed and should be added soon',
        border: false
    });
};

EHR.reports.potentialParents = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        border: false,
        style: 'padding-bottom: 20px;',
        bodyStyle: 'padding: 5px;',
        html: 'This report calculates potential parents for the selected animal(s).  The potential parents are determined as follows:' +
            '<br><br>' +
            '<ul style="margin-left: 20px">' +
            '<li style="list-style-type: disc;">Potential dams are determined by finding any female housed in the animal\'s birth location at the time of birth, which were at least 2.5 years old at the time.  Note: this report considers housing in whole-day increments in order to avoid missing potential parents due to errors in the timestamp of transfers.</li>' +
            '<li style="list-style-type: disc;">Potential sires are determined by finding the locations where all potential dams were housed during the conception window (defined below) relative to the animal\'s birth.  The potential sires are any male animals housed in these locations during the conception window, which are at least 2.5 years old at the time.</li>' +
            '</ul>'
    });

    tab.add({
        xtype: 'panel',
        ownerTabbedPanel: panel,
        itemId: 'potentialParents',
        border: false,
        items: [{
            itemId: 'filterArea',
            style: 'padding-bottom: 10px;',
            bodyStyle: 'padding: 5px;',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                layout: 'hbox',
                defaults: {
                    border: false
                },
                items: [{
                html: 'Choose Conception Range (Days Prior To Birth):',
                style: 'padding-bottom: 10px;'
                },{
                    xtype: 'numberfield',
                    hideTrigger: true,
                    itemId: 'rangeMin',
                    style: 'margin-left: 10px;',
                    value: 155
                },{
                    html: 'through',
                    style: 'margin-left: 10px;'
                },{
                    xtype: 'numberfield',
                    itemId: 'rangeMax',
                    style: 'margin-left: 10px;',
                    hideTrigger: true,
                    value: 180
                }]
            },{
                xtype: 'checkbox',
                fieldLabel: 'Combine Dams/Sires Into Single Table',
                labelWidth: 275,
                itemId: 'singleTable'
            }],
            buttonAlign: 'left',
            buttons: [{
                text: 'Submit',
                handler: function(btn){
                    var panel = btn.up('#potentialParents');
                    var rangeMin = panel.down('#rangeMin').getValue();
                    var rangeMax = panel.down('#rangeMax').getValue();
                    var singleTable = panel.down('#singleTable').getValue();

                    if (Ext4.isEmpty(rangeMin) || Ext4.isEmpty(rangeMax)){
                        Ext4.Msg.alert('Error', 'Must provide a range');
                        return;
                    }

                    var target = panel.down('#target');
                    target.removeAll();

                    if (singleTable){
                        target.add({
                            xtype: 'ldk-querypanel',
                            style: 'margin-bottom:20px;',
                            queryConfig: panel.ownerTabbedPanel.getQWPConfig({
                                schemaName: 'study',
                                queryName: 'potentialParents',
                                title: "Potential Parents" + title,
                                filters: filterArray.nonRemovable,
                                removeableFilters: filterArray.removable,
                                parameters: {
                                    RangeMin: rangeMin,
                                    RangeMax: rangeMax
                                }
                            })
                        });
                    }
                    else
                    {
                        target.add({
                            xtype: 'ldk-querypanel',
                            style: 'margin-bottom:20px;',
                            queryConfig: panel.ownerTabbedPanel.getQWPConfig({
                                schemaName: 'study',
                                queryName: 'potentialDams',
                                title: "Potential Dams" + title,
                                filters: filterArray.nonRemovable,
                                removeableFilters: filterArray.removable
                            })
                        });

                        target.add({
                            xtype: 'ldk-querypanel',
                            style: 'margin-bottom:20px;',
                            queryConfig: panel.ownerTabbedPanel.getQWPConfig({
                                schemaName: 'study',
                                queryName: 'potentialSires',
                                title: "Potential Sires" + title,
                                filters: filterArray.nonRemovable,
                                removeableFilters: filterArray.removable,
                                parameters: {
                                    RangeMin: rangeMin,
                                    RangeMax: rangeMax
                                }
                            })
                        });
                    }
                }
            }]
        },{
            border: false,
            defaults: {
                border: false
            },
            itemId: 'target'
        }]
    })
};

EHR.reports.menseCycleLength = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        html: 'This report estimates cycle start dates for animals, along with the cycle length.  Please note, it infers Day 1 from the data and may not be accurate in all cases, such as animals with irregular cycle or near pregnancies.  Any mense observation at least 14 days after the previous mense observation is assumed to be the cycle start.  As a result, this calculation is only as good as the mens data collected in the system, which will be more complete for indoor versus outdoor animals.  It may be worth comparing these results with the Menses or Repro Summary tabs, which contain additional information.',
        border: false,
        style: 'padding-bottom: 20px;'
    },{
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'menseCycleLength',
            title: 'Estimated Cycle Starts' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });
};

EHR.reports.reproSummary = function(panel, tab){
    if (tab.filters.subjects){
        renderReproReport(tab.filters.subjects, tab);
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, renderReproReport, this);
    }

    function renderReproReport(subjects, tab){
        if (!subjects.length){
            Ext4.Msg.alert('No Animals', 'No animals were found');
            return;
        }

        if (subjects.length > 25){
            tab.add({
                html: 'This report can only be used on 25 or fewer animals at a time.',
                border: false,
                style: 'padding-bottom: 10px;'
            });

            return;
        }

        var filterArray = panel.getFilterArray(tab);
        var title = panel.getTitleSuffix();

        tab.add({
            xtype: 'panel',
            ownerTabbedPanel: panel,
            itemId: 'reproSummary',
            border: false,
            items: [{
                itemId: 'filterArea',
                style: 'padding-bottom: 10px;',
                border: false,
                defaults: {
                    border: false
                },
                items: [{
                    layout: 'hbox',
                    style: 'margin-left: 5px;',
                    defaults: {
                        border: false
                    },
                    items: [{
                        xtype: 'numberfield',
                        itemId: 'numMonths',
                        fieldLabel: '# Months To Show',
                        labelWidth: 130,
                        style: 'margin-left: 10px;',
                        hideTrigger: true,
                        value: 13
                    },{
                        xtype: 'button',
                        style: 'margin-left: 10px',
                        border: true,
                        text: 'Submit/Reload',
                        handler: function(btn){
                            var panel = btn.up('#reproSummary');
                            var numMonths = panel.down('#numMonths').getValue();
                            if (Ext4.isEmpty(numMonths)){
                                Ext4.Msg.alert('Error', 'Must provide the number of months');
                                return;
                            }

                            //set to 1 year in past
                            var startDate = new Date();
                            startDate.setDate(1);
                            startDate = Ext4.Date.add(startDate, Ext4.Date.MONTH, (-1 * numMonths) + 1);

                            var target = panel.down('#target');
                            target.removeAll();

                            var toAdd = [];

                            Ext4.Array.forEach(subjects, function(id){
                                toAdd.push({
                                    xtype: 'ldk-querypanel',
                                    style: 'margin-bottom:20px;',
                                    queryConfig: panel.ownerTabbedPanel.getQWPConfig({
                                        schemaName: 'study',
                                        queryName: 'reproSummaryByMonth',
                                        title: 'Repro Summary: ' + id,
                                        sort: 'year,monthNum',
                                        parameters: {
                                            Id: id,
                                            StartDate: Ext4.Date.format(startDate, 'Y/m/d'),
                                            NumMonths: numMonths
                                        },
                                        scope: this,
                                        success: onSuccess
                                    })
                                });
                            }, this);

                            var totalDr = toAdd.length;
                            function onSuccess(dr){
                                totalDr--;
                                if (totalDr == 0){
                                    tab.doLayout.defer(250, tab);
                                }
                            }

                            if (toAdd.length){
                                target.add(toAdd);
                            }
                        }
                    }]
                }]
            },{
                border: false,
                defaults: {
                    border: false
                },
                itemId: 'target'
            }]
        });

        tab.add({
            xtype: 'panel',
            bodyStyle: 'padding: 10px;',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                html: '<b>Key:</b>',
                style: 'padding-bottom: 5px;'
            },{
                html: 'C: C-Section'
            },{
                html: 'F: Fetus Not Recovered'
            },{
                html: 'M: Menses'
            },{
                html: 'N: No Delivery - Fetus Recovered'
            },{
                html: 'R: Resorbtion'
            },{
                html: 'T: Timed Mating'
            },{
                html: 'V: Vaginal'
            },{
                html: '*: Other Mating'
            }]
        });
    }
};


EHR.reports.delivery = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        html: 'This tab was essentially redundant with the Offspring tab (to the right).  The only difference is that the Offspring tab also includes genetic offspring (lacking the observed mother), and that report also included the outcome of the birth.  Please use the other report, and this tab will be removed after Oct 17th.',
        border: false,
        style: 'padding-bottom: 20px;'
    });
};

EHR.reports.measurementsPivoted = function(panel, tab, viewName){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsPivotedFetal',
            title: 'Fetal Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsPivotedPlacental',
            title: 'Placental Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsPivotedHeart',
            title: 'Heart Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsPivotedBody',
            title: 'Body Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'measurementsMisc',
            title: 'Misc Measurements' + title,
            titleField: 'Id',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable,
            sort: '-date'
        })
    });
};

//EHR.reports.onprcSnapshot = function(panel, tab){
//    EHR.reports.snapshot(panel, tab, true);
//};
//Modified: 4-12-2016 R.Blasa
EHR.reports.onprcSnapshot = function(panel, tab){
    var  showActionsBtn = true;
    if (tab.filters.subjects){
        renderSubjects(tab.filters.subjects, tab);
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, renderSubjects, this);
    }

    function renderSubjects(subjects, tab){
        var toAdd = [];
        if (!subjects.length){
            toAdd.push({
                html: 'No animals were found.',
                border: false
            });
        }
        else if (subjects.length < 10) {
            for (var i=0;i<subjects.length;i++)
            {
                var str = subjects[i];
                var idcolor = false;

                if  (str.substr(0,2)== 'gp' || str.substr(0,3)== 'rbr') {
                   idcolor = true;
                }
                toAdd.push({
                    xtype: 'ldk-webpartpanel',
                    //title: 'Overview: ' + subjects[i],   //Added 4-12-2016 Blasa
                   // title: 'Overview: ' + '<span style="background-color:#77BC71">' + subjects[i]+ '</span>',
                    //Added 4-12-2016 Blasa
                    title: idcolor?'Overview: ' +  '<span style="color:#8B0000">' + subjects[i]+ '</span>':'Overview: ' + subjects[i],

                    items: [{
                        xtype: 'onprc_ehr-snapshotpanel',        //Redifined: 6-13-2016 R.Blas
                        showExtendedInformation: true,
                        showActionsButton: !!showActionsBtn,
                        hrefTarget: '_blank',
                        border: false,
                        subjectId: subjects[i]
                    }]
                });

                toAdd.push({
                    border: false,
                    height: 20
                });

                toAdd.push(EHR.reports.renderWeightData(panel, tab, subjects[i]));
            }
        }
        else {
            toAdd.push({
                html: 'Because more than 10 subjects were selected, the condensed report is being shown.  Note that you can click the animal ID to open this same report in a different tab, showing that animal in more detail or click the link labeled \'Display History\'.',
                style: 'padding-bottom: 20px;',
                border: false
            });

            var filterArray = panel.getFilterArray(tab);
            var title = panel.getTitleSuffix();
            toAdd.push({
                xtype: 'ldk-querypanel',
                style: 'margin-bottom:20px;',
                queryConfig: {
                    title: 'Overview' + title,
                    schemaName: 'study',
                    queryName: 'demographics',
                    viewName: 'Snapshot',
                    filterArray: filterArray.removable.concat(filterArray.nonRemovable)
                }
            });
        }

        if (toAdd.length)
            tab.add(toAdd);
    }

};

EHR.reports.onprcFullClinicalHistory = function(panel, tab){
    EHR.reports.clinicalHistory(panel, tab, true, true);
};

//EHR.reports.onprcClinicalHistory = function(panel, tab){
//    EHR.reports.clinicalHistory(panel, tab, true);
//};

//Modified  4-12-2016 R.Blasa
EHR.reports.onprcClinicalHistory = function(panel, tab, showActionsBtn, includeAll)
{
    if (tab.filters.subjects)
    {
        renderSubjects(tab.filters.subjects, tab);
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, renderSubjects, this);
    }

    function renderSubjects(subjects, tab)
    {
        if (subjects.length > 10)
        {
            tab.add({
                html: 'Because more than 10 subjects were selected, the condensed report is being shown.  Note that you can click the animal ID to open this same report in a different tab, showing that animal in more detail or click the link labeled \'Display History\'.',
                style: 'padding-bottom: 20px;',
                border: false
            });

            var filterArray = panel.getFilterArray(tab);
            var title = panel.getTitleSuffix();
            tab.add({
                xtype: 'ldk-querypanel',
                style: 'margin-bottom:20px;' ,
                queryConfig: {
                    title: 'Overview' + title,
                    schemaName: 'study',
                    queryName: 'demographics',
                    viewName: 'Snapshot',
                    filterArray: filterArray.removable.concat(filterArray.nonRemovable)
                }
            });

            return;
        }

        if (!subjects.length)
        {
            tab.add({
                html: 'No animals were found.',
                border: false
            });

            return;
        }

        var minDate = includeAll ? null : Ext4.Date.add(new Date(), Ext4.Date.YEAR, -2);
        var toAdd = [];
        Ext4.each(subjects, function (s)
        {
            toAdd.push({
                html: '<span style="font-size: large;"><b>Animal: ' + s + '</b></span>',
                style: 'padding-bottom: 20px;',
                border: false
            });

            toAdd.push({
                xtype: 'onprc_ehr-smallformsnapshotpanel',     //Modified: 7-12-2016 R.Blasa
                showActionsButton: !!showActionsBtn,
                hrefTarget: '_blank',
                border: false,
                subjectId: s
            });

            toAdd.push({
                html: '<b>Chronological History:</b><hr>',
                style: 'padding-top: 5px;',
                border: false
            });

            toAdd.push({
                xtype: 'ehr-clinicalhistorypanel',
                border: true,
                subjectId: s,
                autoLoadRecords: true,
                minDate: minDate,
                //maxGridHeight: 1000,
                hrefTarget: '_blank',
                style: 'margin-bottom: 20px;'
            });
        }, this);

        if (toAdd.length)
        {
            tab.add(toAdd);
        }
    }
};

EHR.reports.behaviorCases = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    filterArray.nonRemovable = filterArray.nonRemovable || [];
    filterArray.nonRemovable.push(LABKEY.Filter.create('category', 'Behavior'));

    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-linkbutton',
        text: 'Click Here To View Cases On A Different Date',
        linkTarget: '_blank',
        linkCls: 'labkey-text-link',
        href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'casesOpenOnDate', 'query.viewName': 'Behavior Cases'}),
        style: 'margin-bottom: 20px;'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'cases',
            viewName: 'All Behavior Cases',
            title: 'Behavior Cases' + title,
            titleField: 'Id',
            sort: '-date',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });
};

EHR.reports.surgeryCasesClosedToday = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    filterArray.removable = filterArray.removable || [];
    filterArray.removable.push(LABKEY.Filter.create('category', 'Surgery'));
    filterArray.removable.push(LABKEY.Filter.create('enddate', new Date(), LABKEY.Filter.Types.DATE_GREATER_THAN_OR_EQUAL));

    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'cases',
            viewName: 'With Initial Housing',
            title: 'Cases Closed Today' + title,
            titleField: 'Id',
            sort: '-date',
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });
};