package org.labkey.onprc_ehr.table;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;

/**
 * //Created: 9-8-2016 R.Blasa
 */
public class ObservationDisplayColumnFactory implements DisplayColumnFactory
{
    @Override
    public DisplayColumn createRenderer(ColumnInfo colInfo)
    {
        return new ObservationDisplayColumn(colInfo);
    }
}
