Ext4.ns('GenotypeAssays');

GenotypeAssays.buttons = new function(){
    return {
        sbtReviewHandler: function(dataRegionName){
            var dataRegion = LABKEY.DataRegions[dataRegionName];
            var checked = dataRegion.getChecked();
            if (!checked || !checked.length){
                alert('No records selected');
                return;
            }

            window.location = LABKEY.ActionURL.buildURL('genotypeassays', 'sbtReview', null, {analysisIds: checked.join(';')});
        },

        haplotypeHandler: function(dataRegionName){
            var dataRegion = LABKEY.DataRegions[dataRegionName];
            var checked = dataRegion.getChecked();
            if (!checked || !checked.length){
                alert('No records selected');
                return;
            }

            var newForm = Ext4.DomHelper.append(document.getElementsByTagName('body')[0],
                    '<form method="POST" action="' + LABKEY.ActionURL.buildURL("genotypeassays", "bulkHaplotype", null) + '">' +
                    '<input type="hidden" name="analysisIds" value="' + Ext4.htmlEncode(checked.join(';')) + '" />' +
                    '</form>');
            newForm.submit();
        }
    }
};
