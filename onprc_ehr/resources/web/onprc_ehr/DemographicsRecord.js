/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.ns('onprc_ehr.DemographicsRecord');

EHR.DemographicsRecord = function(data){
    LDK.Assert.assertNotEmpty('onprc_ehr.DemographicsRecord created without data', data);
    data = data || {};

    return {
        getId: function(){
            return data.Id;
        },

        getProperty: function(prop){
            return data[prop];
        },


        getAgeInDays: function(){
            return data['Id/age/ageInDays'];
        },

        getAgeInYearsAndDays: function(){
            return data['Id/age/yearAndDays'];
        },

        getActiveAnimalGroups: function(){
            return data['activeAnimalGroups'];
        },

        getActiveAssignments: function(){
            return data['activeAssignments'];
        },

        getActiveCases: function(){
            return data['activeCases'];
        },

        getActiveFlags: function(){
            return data['activeFlags'];
        },

        getActiveHousing: function(){
            return data['activeHousing'];
        },

        //Added 8-23-2016 R.Blasa
        getAssignedVet: function(){
            return data['assignedVet'];
        },

        //Added 12--2016 R.Blasa
        getPregnancyInfo: function(){
            return data['gestationdays'];
        },


        //Added 2-21-2017 R.Blasa
        getCagemateInfant: function(){
            return data['cagemateinfant'];
        },

        //Added 3-10-2017 R.Blasa
        getFosterChild: function(){
            return data['fosterchild'];
        },

        //Added 12-20-2018 R.Blasa
        getLastKnownlocation: function(){
            return data['lastlocation'];
        },

        //Created: 10-4-2019  R.Blasa
        getActiveDrugs: function(){
            return data['activeDrugs'];
        },

        //Created: 1-15-2021  R.Blasa
        getBCSScoreWeights: function(){
            return data['BCSWeights'];
        },

        getCurrentLocation: function(){
            if (data['activeHousing'] && data['activeHousing'].length){
                var ret = data['activeHousing'][0].room;
                if (data['activeHousing'][0].cage){
                    ret += '-' + data['activeHousing'][0].cage;
                }

                return ret;
            }
        },

        getCurrentRoom: function(){
            if (data['activeHousing'] && data['activeHousing'].length){
                return data['activeHousing'][0].room;
            }
        },

        getCurrentCage: function(){
            if (data['activeHousing'] && data['activeHousing'].length){
                return data['activeHousing'][0].cage;
            }
        },

        getActiveProblems: function(){
            return data['activeProblems'];
        },

        getBirth: function(){
            if (data['birth'])
                return LDK.ConvertUtils.parseDate(data['birth']);
        },

        getBirthInfo: function(){
            return data['birthInfo'];
        },

        getDeathInfo: function(){
            return data['deathInfo'];
        },

        getCagemates: function(){
            return data['cagemates'];
        },

        getCalculatedStatus: function(){
            return data['calculated_status'];
        },

        getDam: function(){
            return data['dam'];
        },

        getDaysSinceWeight: function(){
            return data['daysSinceWeight'];
        },

        getDeath: function(){
            if (data['death'])
                return LDK.ConvertUtils.parseDate(data['death']);
        },

        getGenderCode: function(){
            return data['gender'];
        },

        getGender: function(){
            return data['gender/meaning'];
        },

        getGeographicOrigin: function(){
            return data['geneticAncestry'] ? data['geneticAncestry']  + ' (Verified)' : data['geographic_origin'];
        },

        getMostRecentWeight: function(){
            return data['mostRecentWeight'];
        },

        getActiveTreatments: function(){
            return data['activeTreatments'];
        },

        getMostRecentWeightDate: function(){
            if (data['mostRecentWeightDate'])
                return LDK.ConvertUtils.parseDate(data['mostRecentWeightDate']);
        },

        getParents: function(){
            return data['parents'];
        },

        getSire: function(){
            return data['sire'];
        },

        getSpecies: function(){
            return data['species'];
        },

        getTBRecord: function(){
            return data['tb'];
        },

        getLastTBDate: function(){
            if (data['tb'] && data['tb'].length){
                var date = data['tb'][0]['MostRecentTBDate'];
                if (date)
                    return LDK.ConvertUtils.parseDate(date);
            }
        },

        getMonthsUntilTBDue: function(){
            if (data['tb'] && data['tb'].length){
                return data['tb'][0].MonthsUntilDue;
            }
        },

        getMonthsSinceLastTB: function(){
            if (data['tb'] && data['tb'].length){
                return data['tb'][0].MonthsSinceLastTB;
            }
        },

        getRecentWeights: function(){
            return data['weights'];
        },

        getSourceRecord: function(){
            return data.source;
        }
    }
}
