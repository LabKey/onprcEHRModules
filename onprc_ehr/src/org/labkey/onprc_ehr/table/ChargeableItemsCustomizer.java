package org.labkey.onprc_ehr.table;

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.TableCustomizer;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.query.DetailsURL;

/**
 * User: bimber
 * Date: 10/11/13
 * Time: 3:51 PM
 */
public class ChargeableItemsCustomizer implements TableCustomizer
{
    public ChargeableItemsCustomizer()
    {

    }

    public void customize(TableInfo table)
    {
        if (table instanceof AbstractTableInfo)
        {
            if (table.getName().equalsIgnoreCase("chargeableItems"))
            {
                ((AbstractTableInfo) table).setDetailsURL(DetailsURL.fromString("/onprc_ehr/chargeItemDetails.view?chargeId=${rowid}"));
            }
        }

    }
}
