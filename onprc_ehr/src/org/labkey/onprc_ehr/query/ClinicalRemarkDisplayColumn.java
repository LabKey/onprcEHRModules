package org.labkey.onprc_ehr.query;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;

/**
 * User: bimber
 * Date: 10/28/13
 * Time: 11:35 AM
 */
public class ClinicalRemarkDisplayColumn extends DataColumn
{
    private String _targetColName;

    public ClinicalRemarkDisplayColumn(ColumnInfo col, String targetColName)
    {
        super(col);
        _targetColName = targetColName;
    }
}
