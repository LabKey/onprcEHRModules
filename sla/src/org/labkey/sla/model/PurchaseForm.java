package org.labkey.sla.model;

import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.action.NewCustomApiForm;
import org.labkey.api.util.GUID;
import org.labkey.api.util.JsonUtil;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class PurchaseForm implements NewCustomApiForm
{
    private Integer _rowid;
    private String _objectid;
    private GUID _containerid;

    private Integer _project;
    private String _account;
    private String _requestorid;
    private String _vendorid;
    private String _hazardslist;
    private Integer _dobrequired;

    // fields not provided by non-admin order submission
    private String _confirmationnum;
    private Date _orderdate;
    private String _orderby;
    private Integer _housingconfirmed;

    List<PurchaseDetails> _purchaseDetails = new ArrayList<>();

    public void setRowid(Integer rowid)
    {
        _rowid = rowid;
    }

    public Integer getRowid()
    {
        return _rowid;
    }

    public void setObjectid(String objectid)
    {
        _objectid = objectid;
    }

    public String getObjectid()
    {
        return _objectid;
    }

    public void setProject(Integer project)
    {
        _project = project;
    }

    public Integer getProject()
    {
        return _project;
    }

    public void setAccount(String account)
    {
        _account = account;
    }

    public String getAccount()
    {
        return _account;
    }

    public void setRequestorid(String requestorid)
    {
        _requestorid = requestorid;
    }

    public String getRequestorid()
    {
        return _requestorid;
    }

    public void setVendorid(String vendorid)
    {
        _vendorid = vendorid;
    }

    public String getVendorid()
    {
        return _vendorid;
    }

    public void setHazardslist(String hazardslist)
    {
        _hazardslist = hazardslist;
    }

    public String getHazardslist()
    {
        return _hazardslist;
    }

    public void setDobrequired(Integer dobrequired)
    {
        _dobrequired = dobrequired;
    }

    public Integer getDobrequired()
    {
        return _dobrequired;
    }

    public String getConfirmationnum()
    {
        return _confirmationnum;
    }

    public void setConfirmationnum(String confirmationnum)
    {
        _confirmationnum = confirmationnum;
    }

    public Date getOrderdate()
    {
        return _orderdate;
    }

    public void setOrderdate(Date orderdate)
    {
        _orderdate = orderdate;
    }

    public String getOrderby()
    {
        return _orderby;
    }

    public void setOrderby(String orderby)
    {
        _orderby = orderby;
    }

    public Integer getHousingconfirmed()
    {
        return _housingconfirmed;
    }

    public void setHousingconfirmed(Integer housingconfirmed)
    {
        _housingconfirmed = housingconfirmed;
    }

    public List<PurchaseDetails> getPurchaseDetails()
    {
        return _purchaseDetails;
    }

    public void setPurchaseDetails(List<PurchaseDetails> purchaseDetails)
    {
        _purchaseDetails = purchaseDetails;
    }

    public void addPurchaseDetail(PurchaseDetails purchaseDetail)
    {
        _purchaseDetails.add(purchaseDetail);
    }

    public GUID getContainerid()
    {
        return _containerid;
    }

    public void setContainerid(GUID containerid)
    {
        _containerid = containerid;
    }

    @Override
    public void bindJson(JSONObject json)
    {
        // set the purchase level properties
        if (json.has("rowid"))
            _rowid = json.getInt("rowId");
        if (json.has("objectid"))
            _objectid = json.getString("objectid");
        if (json.has("project"))
            _project = Integer.parseInt(json.getString("project"));
        if (json.has("account"))
            _account = json.getString("account");
        if (json.has("requestorid"))
            _requestorid = json.getString("requestorid");
        if (json.has("vendorid"))
            _vendorid = json.getString("vendorid");
        if (json.has("hazardslist") && !json.isNull("hazardslist"))
            _hazardslist = json.getString("hazardslist");
        if (json.has("dobrequired"))
            _dobrequired = json.getInt("dobrequired");

        // parse the array of purchase details records
        if (json.has("details"))
        {
            JSONArray details = json.getJSONArray("details");
            for (JSONObject detail : JsonUtil.toJSONObjectList(details))
            {
                addPurchaseDetail(new PurchaseDetails(detail));
            }
        }
    }
}
