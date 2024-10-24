/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg subjectId
 * @cfg hideHeader
 * @cfg showLocationDuration
 * @cfg showExtendedInformation
 * @cfg hrefTarget
 * @cfg redacted
 */
//Created: 6-13-2016  R.Blasa
Ext4.define('onprc_ehr.panel.SnapshotPanel', {
    extend: 'EHR.panel.SnapshotPanel',
    alias: 'widget.onprc_ehr-snapshotpanel',

    showLocationDuration: true,
    showActionsButton: true,
    defaultLabelWidth: 150,
    border: false,
    doSuspendLayouts: true,  //note: this can make loading much quicker, but will cause problems when many snapshot panels load concurrently on the same page

    initComponent: function(){
        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: this.getItems()
        });

        this.callParent();

        let anmId;

        if (this.subjectId){
            anmId = this.subjectId;
            this.isLoading = true;
            this.setLoading(true);
            this.loadData();
        }

        this.on('afterrender', function() {

            var displayField = this.down('#flags');
            if (displayField && displayField.getEl()) {

                var anchors = [displayField.getEl('onprcFlagsLink'), displayField.getEl('onprcBehaviorFlagsLink')];

                for (let i = 0; i < anchors.length; i++) {
                    let anchor = anchors[i];
                    if (anchor) {
                        Ext4.get(anchor).on('click', function(e) {
                            e.preventDefault();
                            if (anmId) {
                                EHR.Utils.showFlagPopup(anmId, this);
                            }
                        });
                    }
                }
            }
        }, this);
    },

    getBaseItems: function(){
        return [{
            xtype: 'container',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                xtype: 'container',
                html: '<b>Summary:</b><hr>'
            },{
                bodyStyle: 'padding: 5px;',
                layout: 'column',
                defaults: {
                    border: false
                },
                items: [{
                    xtype: 'container',
                    columnWidth: 0.25,
                    defaults: {
                        labelWidth: this.defaultLabelWidth,
                        style: 'margin-right: 20px;'
                    },
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: 'Location',
                        //width: 420,
                        name: 'location'
                    },{
                        xtype: 'displayfield',
                        hidden: this.redacted,
                        name: 'assignments',
                        fieldLabel: 'Projects'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Groups',
                        hidden: this.redacted,
                        name: 'groups'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Open Problems',
                        name: 'openProblems'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Active Cases',
                        name: 'activeCases'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Behavior Alert' ,
                        name: 'behaviorflag'
                    }]
                },{
                    xtype: 'container',
                    columnWidth: 0.25,
                    defaults: {
                        labelWidth: this.defaultLabelWidth,
                        style: 'margin-right: 20px;'
                    },
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: 'Status',
                        name: 'calculated_status'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Sex',
                        name: 'gender'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Species',
                        name: 'species'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Age',
                        name: 'age'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Source',
                        name: 'source'
                    }]
                },{
                    xtype: 'container',
                    columnWidth: 0.35,
                    defaults: {
                        labelWidth: this.defaultLabelWidth,
                        style: 'margin-right: 20px;'
                    },
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: 'Flags',
                        name: 'flags',
                        itemId: 'flags'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Last TB Date',
                        name: 'lastTB'
                    },{
                        xtype: 'displayfield',  //Added: 1-15-2021  R.blasa
                        fieldLabel: 'BCS',
                        name: 'bcsScore'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Weights',
                        name: 'weights'
                    },{
                        xtype: 'displayfield',        //Added: 8-24-2016  R.blasa
                        fieldLabel: 'Assigned Vet',
                        name: 'assignedVets'
                    },{
                        xtype: 'displayfield',        //Added: 1-24-2016  R.Blasa
                        fieldLabel: 'Estimated Pregnancy Delivery Date',
                        name: 'pregnancyInfo'
                    }]
                }]
            }]
        }];
    },

    getItems: function(){
        var items = this.getBaseItems();

        if (this.showExtendedInformation){
            items[0].items = items[0].items.concat(this.getExtendedItems());

        }

        items[0].items = items[0].items.concat([{
            name: 'treatments',
            xtype: 'ehr-snapshotchildpanel',
            headerLabel: 'Current Medications / Prescribed Diets',
            emptyText: 'There are no active medications'
        }]);


        //Sdded: 10-28-2019  R.Blasa
        items[0].items = items[0].items.concat([{
            name: 'sdrug',
            xtype: 'ehr-snapshotchildpanel',
            headerLabel: 'Sustained Release Medication',
            emptyText: 'There are no active medications'
        }]);

        if (this.showActionsButton){
            items.push({
                xtype: 'onprc_ehr-clinicalactionsbutton',        //Modified: 6-13-2016 R.Blasa
                border: true
            });
        }

        return items;
    },

    loadData: function(){
        EHR.DemographicsCache.getDemographics([this.subjectId], this.onLoad, this);
    },

    onLoad: function(ids, resultMap){
        if (this.disableAnimalLoad){
            return;
        }

        if (this.isDestroyed){
            return;
        }

        var toSet = {};

        var id = ids[0];
        var results = resultMap[id];
        if (!results){
            if (id){
                toSet['animalId'] = id;
                toSet['calculated_status'] = '<span style="background-color:yellow">Unknown</span>';
            }

            return;
        }

        this.appendDemographicsResults(toSet, results, id);
        this.appendWeightResults(toSet, results.getRecentWeights());

        this.appendRoommateResults(toSet, results.getCagemates(), id);

        this.appendProblemList(toSet, results.getActiveProblems());
        this.appendAssignments(toSet, results.getActiveAssignments());

        if (!this.redacted){
            this.appendAssignmentsAndGroups(toSet, results);
            this.appendGroups(toSet, results.getActiveAnimalGroups());
        }

        this.appendSourceResults(toSet, results.getSourceRecord());
        this.appendTreatmentRecords(toSet, results.getActiveTreatments());
        this.appendCases(toSet, results.getActiveCases());
        this.appendCaseSummary(toSet, results.getActiveCases());

        this.appendFlags(toSet, results.getActiveFlags());
        this.appendTBResults(toSet, results.getTBRecord());

        this.appendAssignedVets(toSet, results.getAssignedVet());    //Added 8-23-2016 R.Blasa

        this.appendPregnancyInfo(toSet, results.getPregnancyInfo());    //Added 1-24-2017 R.Blasa

        //Added: 2-21-2017  R.Blasa
        this.appendCagemateInfantResults(toSet, results.getCagemateInfant());


            //Added: 3-10-2017  R.Blasa
        this.appendFosterChildtResults(toSet, results.getFosterChild());


        //Added: 12-20-2018  R.Blasa
        this.appendLastKnownLocationResults(toSet, results.getLastKnownlocation());

        //Added: 10-4-2019  R.Bl;asa
          this.appendDrugRecords(toSet, results.getActiveDrugs());

        //Added: 1-15-2021  R.Bl;asa
        this.appendBCSScore(toSet, results.getBCSScoreWeights());

        if (this.showExtendedInformation){
            this.appendBirthResults(toSet, results.getBirthInfo(), results.getBirth());
            this.appendDeathResults(toSet, results.getDeathInfo());
            this.appendParentageResults(toSet, results.getParents());
        }

        this.getForm().setValues(toSet);
        this.afterLoad();
    },

    //Modified: 1-25-2017  R.Blasa
    //note: this should not get called if redacted
    appendGroups: function(toSet, results){
        toSet['groups'] = null;

        if (this.redacted)
            return;

        var values = [];
        if (results){
            Ext4.each(results, function(row){
                values.push(row['groupId/name']);
            }, this);
        }


        //Modified: 2-14-2017  R.Blasa  Make animal group name as hyperlink
        var url =  values.length ? '<a href="' + LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'ehr', 'query.queryName': 'animal_groups',
                  'query.name~in': values.length ? values.join(';') : 'None' }) + '" target="_blank">' + values.map(v=>LABKEY.Utils.encodeHtml(v)).join('<br>') + '</a>' : 'None';


        toSet['groups'] = url;
    },


    appendCases: function(toSet, results){
        var values = [];
        if (results){
            Ext4.each(results, function(row){
                var text = row.category;
                if (text){
                    //NOTE: this may have been cached in the past, so verify whether this is really still active
                    var date = LDK.ConvertUtils.parseDate(row.date);
                    var enddate = row.enddate ? LDK.ConvertUtils.parseDate(row.enddate) : null;
                    if (date && (!enddate || enddate.getTime() > (new Date()).getTime())){
                        var reviewdate = row.reviewdate ? LDK.ConvertUtils.parseDate(row.reviewdate) : null;
                        if (!reviewdate || Ext4.Date.clearTime(reviewdate).getTime() <= Ext4.Date.clearTime(new Date()).getTime()){
                            text = text + ' (' + Ext4.Date.format(date, 'Y-m-d') + ')';

                            values.push(text);
                        }
                        else if (reviewdate && Ext4.Date.clearTime(reviewdate).getTime() > Ext4.Date.clearTime(new Date()).getTime()){
                            text = text + ' - None (Reopens: '  + Ext4.Date.format(reviewdate, 'Y-m-d') + ')';
                            values.push(text);
                        }
                    }
                }
            }, this);
        }

        toSet['activeCases'] = values.length ? values.join(',<br>') : 'None';
    },

    //Modiified 8-24-2016 R.Blasa
    appendAssignedVets: function(toSet, results){
        if (results)
        {
            toSet['assignedVets']   = results[0].assignedVet;
        }
        else
        {
            toSet['assignedVets']  = 'None';
        }
    },


    //Added 1-24-2017 R.Blasa
    appendPregnancyInfo: function(toSet, results){
        if (results)
        {
             var sDate = LDK.ConvertUtils.parseDate(results[0].ExpectedDelivery);
              toSet['pregnancyInfo']   = Ext4.Date.format(sDate, 'Y-m-d');
        }
        else
        {
            toSet['pregnancyInfo'] = 'None';
        }
    },

    //Added: 2-21-2017  R.Blasa  Display Infant cage mate under 1 yr
    appendCagemateInfantResults: function(toSet, results){

        if (results)
        {
            toSet['cagemateinfant'] = results[0].InfantCageMate;
        }
        else
        {
            toSet['cagemateinfant'] = 'None';
        }

    },

    //Added: 4-20-2017  R.Blasa  Display Infant cage mate under 1 yr
    appendFosterChildtResults: function(toSet, results){
        var values = [];
        if (results)
        {
            Ext4.each(results, function(row){
                var foster = row.FosterChild;

                values.push(foster);

            }, this);

        }

            toSet['fosterinfants'] = values.length ? values.join('<br>') : 'None';

    },

    //Added: 12-20-2018  R.Blasa  Last Known Locatoni
    appendLastKnownLocationResults: function(toSet, results){
        var values = [];
        if (results)
        {
            Ext4.each(results, function(row){
                var lastlocation = row.location;

                values.push(lastlocation);

            }, this);

        }

        toSet['lastlocation'] = values.length ? values.join('<br>') : 'None';

    },


    //Added: 1-15-2021  R.Blasa
    appendBCSScore: function(toSet, results){

            if (results){
                var score1 = LDK.ConvertUtils.parseDate(results[0].date);

                var score2 = Ext4.util.Format.number(results[0].weight,'##.000');

                var score3 = results[0].observation;

                var score4 = results[0].duration;

                var text =  '     ' + score3 + '  /     ' + score1.format('Y-m-d') + '     (' + score4 + '     days ago) at ' + score2 + ' kg' ;

                toSet['bcsScore'] = text;
            }
            else
            {
                toSet['bcsScore'] = 'None';
            }

        },

    //Added: 10-7-2019  R.Blasa
    appendDrugRecords: function(toSet, rows){
        var el = this.down('panel[name=sdrug]');
        if (!el)
            return;

        if (rows && rows.length){
            Ext4.each(rows, function(r){
                if (r.date){
                    var date = LDK.ConvertUtils.parseDate(r.date);
                    //Modified: 11-6-2019  R.Blasa   Compute elapse time in hours
                    var now = new Date();
                    r.ElapseHours = Ext4.util.Format.round(Ext4.Date.getElapsed(date, now) / (1000 * 60 *60), 0);

                }
                if (r.enddate){
                    var enddate = LDK.ConvertUtils.parseDate(r.enddate);


                }
            }, this);
        }

         el.appendTable({
            rows: rows
        }, this.getDrugColumns());
    },

    getDrugColumns: function(){
        return [{
            name: 'meaning',
            label: 'Medication'

        },{
            name: 'amountAndVolume',
            label: 'Amount',
            attrs: {
                style: 'white-space: normal !important;"'
            }
        },{
            name: 'route',
            label: 'Route'
        },{
            name: 'date',
            label: 'Start Date'
        },{
            name: 'ElapseHours',
            label: 'Hours Elapsed'

        },{
            name: 'enddate',
            label: 'End Date'

        },{
            name: 'remark',
            label: 'Remark'
        },{
            name: 'category',
            label: 'Category'
        }];
    },

    appendWeightResults: function(toSet, results){
        var text = [];
        if (results){
            var rows = [];
            var prevRow;
            Ext4.each(results, function(row){
                var newRow = {
                    weight: row.weight,
                    date: LDK.ConvertUtils.parseDate(row.date)
                };

                var prevDate = prevRow ? prevRow.date : new Date();
                if (prevDate){
                    //round to day for purpose of this comparison
                    var d1 = Ext4.Date.clearTime(prevDate, true);
                    var d2 = Ext4.Date.clearTime(newRow.date, true);
                    var interval = Ext4.Date.getElapsed(d1, d2);
                    interval = interval / (1000 * 60 * 60 * 24);
                    interval = Math.floor(interval);
                    newRow.interval = interval + (prevRow ? ' days between' : ' days ago');
                }

                rows.push(newRow);
                prevRow = newRow;
            }, this);
                //Modified: 8-29-2016 R.Blasa Include time within the date field
            Ext4.each(rows, function(r){
                text.push('<tr><td nowrap>' + Ext4.util.Format.number(r.weight,'##.000')  + ' kg' + '</td><td style="padding-left: 5px;" nowrap>' + Ext4.Date.format(r.date, 'Y-m-d H:i') + '</td><td style="padding-left: 5px;" nowrap>' + (Ext4.isDefined(r.interval) ? ' (' + r.interval + ')' : '') + "</td></tr>");
            }, this);
        }

        toSet['weights'] = text.length ? '<table>' + text.join('') + '</table>' : null;
    },

    //Modified: 6-13-2017  R.Blasa
    appendRoommateResults: function(toSet, results, id){
        var cagemates = 0;
        var animals = [];
        var pairingType;

        if (results && results.length){
            var row = results[0];
            if (row.animals){
                animals = row.animals.replace(/( )*,( )*/g, ',');
                animals = animals.split(',');
                animals.sort();
                animals = animals.filter(animal => animal !== id);

            }

            pairingType = row.category;
        }

        var values = [];
        if (results){
            Ext4.each(results, function(row){
                if (row.animals){
                    animals = row.animals.replace(/( )*,( )*/g, ',');
                    animals = animals.split(',')
                    animals.sort();
                    animals = animals.filter(animal => animal !== id);
                    values.push(animals);

                }

            }, this);
        }

        //Modified: 8-22-2017 R.Blasa    Provide link to Snapshot report
        var url1 = '<a href="' + LABKEY.ActionURL.buildURL('ehr', 'animalHistory', null, {}) + '#subjects:' + animals[0]   + '&inputType:singleSubject&showReport:1&activeReport:clinSnapshot' + '" target="_blank">' + animals[0]  +'</a>';
        var url2 = '<a href="' + LABKEY.ActionURL.buildURL('ehr', 'animalHistory', null, {}) + '#subjects:' + animals[1]   + '&inputType:singleSubject&showReport:1&activeReport:clinSnapshot' + '" target="_blank">' + animals[1]  +'</a>';
        var url3 = '<a href="' + LABKEY.ActionURL.buildURL('ehr', 'animalHistory', null, {}) + '#subjects:' + animals[2]   + '&inputType:singleSubject&showReport:1&activeReport:clinSnapshot' + '" target="_blank">' + animals[2]  +'</a>';
        toSet['cagemates'] = cagemates;

        toSet['pairingType'] = pairingType;

        if (animals.length > 3){
            toSet['cagemates'] = animals.length + ' animals';
        }
        else if (animals.length == 0){
            toSet['cagemates'] = 'None';
        }
        else if (animals.length == 1) {
            toSet['cagemates'] = url1;
        }
        else if (animals.length == 2) {
            toSet['cagemates'] = url1 + '<br>' + url2 ;
        }
        else if (animals.length == 3) {
            toSet['cagemates'] = url1 + '<br>' + url2 + '<br>' + url3;
        }
    },
    appendParentageResults: function(toSet, results){
        if (results){
            var parentMap = {};
            Ext4.each(results, function(row){
                var parent = row.parent;
                var relationship = row.relationship;

                if (parent && relationship){

                    var text =  parent + ' : ' + relationship;


                    if (!parentMap[text])
                        parentMap[text] = [];

                    var method = row.method;
                    if (method){
                        parentMap[text].push(method);

                    }
                }
            }, this);


            var values = [];
            //Modified: 2-15-2017  R.Blasa  Modified so that parentage information points to a snapshot report
            Ext4.Array.forEach(Ext4.Object.getKeys(parentMap).sort(), function(text){
                parentMap[text] = Ext4.unique(parentMap[text]);
                var method = parentMap[text].join(', ');

               values.push('<a href="' + LABKEY.ActionURL.buildURL('ehr', 'animalHistory', null, {}) + '#subjects:' + text   + '&inputType:singleSubject&showReport:1&activeReport:clinSnapshot' + '" target="_blank">' + text  + (method ? ' (' + method + ')' : '') +'</a>');

            }, this);

            if (values.length)
                toSet['parents'] = values.join('<br>');
        }
        else {
            toSet['parents'] = 'No data';
        }
    },

    //Modified: 12-20-2018  R.Blasa
    appendDemographicsResults: function(toSet, row, id){
        if (!row){
            console.log('Id not found');
            return;
        }

        var animalId = row.getId() || id;
        if (!Ext4.isEmpty(animalId)){
            toSet['animalId'] = id;
        }

        var status = row.getCalculatedStatus() || 'Unknown';
        toSet['calculated_status'] = '<span ' + (status != 'Alive' ? 'style="background-color:yellow"' : '') + '>' + status + '</span>';

        toSet['species'] = row.getSpecies();
        toSet['geographic_origin'] = row.getGeographicOrigin();
        toSet['gender'] = row.getGender();
        toSet['age'] = row.getAgeInYearsAndDays();

        var location;
        if (row.getActiveHousing() && row.getActiveHousing().length){
            var housingRow = row.getActiveHousing();
            location = '';
            if (!Ext4.isEmpty(row.getCurrentRoom()))
                location = row.getCurrentRoom();
            if (!Ext4.isEmpty(row.getCurrentCage()))
                location += ' / ' + row.getCurrentCage();

            if (location){
                if (this.showLocationDuration && housingRow.date){
                    var date = LDK.ConvertUtils.parseDate(housingRow.date);
                    if (date)
                        location += ' (' + date.format(LABKEY.extDefaultDateFormat) + ')';
                }
            }
        }

        toSet['location'] = location || 'No active housing';

    },

    //Modified: 5-10-2018  R.Blasa
    appendFlags: function(toSet, results){
        var values = [];
        var behavevalues  = [];
        var category;
        if (results){
            Ext4.each(results, function(row){
                category = row['flag/category'];
                var highlight = row['flag/category/doHighlight'];
                var omit = row['flag/category/omitFromOverview'];

                //skip
                if (omit === true)
                    return;

                if (category)
                    category = Ext4.String.trim(category);

                // var val = row['flag/value'];
                var  text ;
                var behavetext;

               if (category == 'Behavior Flag')
                 {
                     behavetext = category + ': ' + row['flag/value'];
                     if (behavetext)
                         behavevalues.push(behavetext);

                 }
                else
                {
                    text = category + ': ' + row['flag/value'];
                    if (text && highlight)
                        text = '<span style="background-color:yellow">' + text + '</span>';
                    if (text)
                        values.push(text);
                 }


            }, this);

            if (values.length) {
                values = Ext4.unique(values);
            }

            if (behavevalues.length) {
                behavevalues = Ext4.unique(behavevalues);
            }
        }

        toSet['flags'] = values.length ? '<a id="onprcFlagsLink">' + values.join('<br>') + '</div>' : null;

        behavevalues = ['test'];

        if (behavevalues.length) {
            toSet['behaviorflag'] = '<a id="onprcBehaviorFlagsLink">' + behavevalues.join('<br>') + '</div>';
        }
        else
        {
            toSet['behaviorflag'] = 'None'
        }
    },

    //Modified: 11-25-2016 R.Blasa
    getExtendedItems: function(){
        return [{
            xtype: 'container',
            name: 'additionalInformation',
            style: 'padding-bottom: 10px;',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                xtype: 'container',
                html: '<b>Additional Information</b><hr>'
            },{
                layout: 'column',
                defaults: {
                    labelWidth: this.defaultLabelWidth
                },
                items: [{
                    xtype: 'container',
                    columnWidth: 0.5,
                    border: false,
                    defaults: {
                        labelWidth: this.defaultLabelWidth,
                        border: false,
                        style: 'margin-right: 20px;'
                    },
                    items: [{
                        xtype: 'displayfield',
                        width: 350,
                        fieldLabel: 'Geographic Origin',
                        name: 'geographic_origin'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Birth',
                        name: 'birth'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Death',
                        name: 'death'
                    }]
                },{
                    xtype: 'container',
                    columnWidth: 0.5,
                    defaults: {
                        labelWidth: this.defaultLabelWidth
                    },
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: 'Parent Information',
                        name: 'parents'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Pairing Type',
                        name: 'pairingType'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Cagemates',
                        name: 'cagemates'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Cagemate Infant(Under 1yr)',
                        name: 'cagemateinfant'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Foster Infant',
                        name: 'fosterinfants'
                    }]
                }]
            }]
        }];
    },

    afterLoad: function(){
        if (this.isLoading){
            this.setLoading(false);
            this.isLoading = false;
        }
    }
});

/**
 * @cfg headerLabel
 * @cfg emptyText
 * @cfg renderCollapsed
 */
Ext4.define('EHR.panel.SnapshotChildPanel', {
    alias: 'widget.ehr-snapshotchildpanel',
    extend: 'Ext.panel.Panel',

    initComponent: function(){
        Ext4.apply(this, {
            border: false,
            defaults: {
                border: false
            },
            items: [{
                xtype: 'container',
                html: '<b>' + this.headerLabel + ':</b>',
                itemId: 'headerItem',
                overCls: 'ldk-clickable',
                listeners: {
                    afterrender: function(panel){
                        var owner = panel.up('ehr-snapshotchildpanel');
                        panel.getEl().on('click', owner.onClick, owner);
                    }
                }
            },{
                border: false,
                xtype: 'container',
                itemId: 'childPanel',
                style: 'padding-bottom: 10px;',
                hidden: this.renderCollapsed,
                defaults: {
                    border: false
                },
                items: [{
                    html: '<hr>'
                }]
            }]
        });

        this.callParent();
    },

    onClick: function(el, event){
        var target = this.down('#childPanel');
        target.setVisible(!target.isVisible());
    },

    appendTable: function(results, columns){
        var target = this.down('#childPanel');
        var total = results && results.rows ? results.rows.length : 0;

        target.removeAll();
        if (results && results.rows && results.rows.length){
            var toAdd = {
                itemId: 'resultTable',
                results: results,
                layout: {
                    type: 'table',
                    columns: columns.length,
                    tdAttrs: {
                        valign: 'top',
                        style: 'padding: 5px;'
                    }
                },
                border: false,
                defaults: {
                    border: false
                },
                items: []
            };

            //first the header
            var colKeys = [];
            var colMap = {};
            Ext4.each(columns, function(col){
                colMap[col.name] = col;

                var obj = {
                    html: '<i>' + col.label + '</i>'
                };

                if (colMap[col.name].maxWidth)
                    obj.maxWidth = colMap[col.name].maxWidth;

                toAdd.items.push(obj);
                colKeys.push(col.name);
            }, this);

            Ext4.Array.forEach(results.rows, function(row, rowIdx){
                Ext4.each(colKeys, function(name){
                    if (!Ext4.isEmpty(row[name])){
                        var value = row[name];
                        if (value && colMap[name].dateFormat){
                            value = LDK.ConvertUtils.parseDate(value);
                            value = Ext4.Date.format(value, colMap[name].dateFormat);
                        }

                        var obj = {
                            html: value + '',
                            resultRowIdx: rowIdx
                        };

                        if (colMap[name].maxWidth)
                            obj.maxWidth = colMap[name].maxWidth;

                        if (colMap[name].attrs){
                            Ext4.apply(obj, colMap[name].attrs);
                        }

                        toAdd.items.push(obj);
                    }
                    else {
                        toAdd.items.push({
                            html: ''
                        });
                    }
                }, this);
            }, this);

            target.add(toAdd);
        }
        else {
            if (this.emptyText){
                target.add({
                    html: this.emptyText
                });
            }
        }
    }
});
