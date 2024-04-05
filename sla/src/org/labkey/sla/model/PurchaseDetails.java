package org.labkey.sla.model;

import org.json.JSONObject;
import org.labkey.api.util.GUID;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class PurchaseDetails
{
    private Integer _rowid;
    private String _purchaseid;
    private String _objectid;
    private GUID _containerid;

    private String _species;
    private String _gender;
    private String _strain;
    private String _age;
    private String _gestation;
    private String _weight;
    private String _weight_units;
    private String _room;
    private Date _requestedarrivaldate;
    private Integer _animalsordered;
    private String _housinginstructions;

    private Integer _animalsreceived;
    private Date _expectedarrivaldate;
    private Date _receiveddate;
    private String _receivedby;
    private Date _datecancelled;
    private String _cancelledby;

    public PurchaseDetails()
    {}

    public PurchaseDetails(JSONObject props)
    {
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");

        if (props.has("rowid"))
            _rowid = props.getInt("rowid");
        if (props.has("purchaseid"))
            _purchaseid = props.getString("purchaseid");
        if (props.has("objectid"))
            _objectid = props.getString("objectid");
        if (props.has("species"))
            _species = props.getString("species");
        if (props.has("age")&& !props.isNull("age"))
            _age = props.getString("age");
        if (props.has("weight") && !props.isNull("weight"))
            _weight = props.getString("weight");
        if (props.has("weight_units") && !props.isNull("weight_units"))
            _weight_units = props.getString("weight_units");
        if (props.has("gestation") && !props.isNull("gestation"))
            _gestation = props.getString("gestation");
        if (props.has("gender"))
            _gender = props.getString("gender");
        if (props.has("strain"))
            _strain = props.getString("strain");
        if (props.has("animalsordered"))
            _animalsordered = props.getInt("animalsordered");
        if (props.has("housinginstructions") && !props.isNull("housinginstructions"))
            _housinginstructions = props.getString("housinginstructions");
        if (props.has("room"))
            _room = props.getString("room");

        try
        {
            if (props.has("requestedarrivaldate"))
                _requestedarrivaldate = df.parse(props.get("requestedarrivaldate").toString());
            if (props.has("expectedarrivaldate"))
                _expectedarrivaldate = df.parse(props.get("expectedarrivaldate").toString());
        }
        catch (ParseException e)
        {
            // TODO report error to the user
        }
    }

    public Integer getRowid()
    {
        return _rowid;
    }

    public void setRowid(Integer rowid)
    {
        _rowid = rowid;
    }

    public String getPurchaseid()
    {
        return _purchaseid;
    }

    public void setPurchaseid(String purchaseid)
    {
        _purchaseid = purchaseid;
    }

    public String getSpecies()
    {
        return _species;
    }

    public void setSpecies(String species)
    {
        _species = species;
    }

    public String getAge()
    {
        return _age;
    }

    public void setAge(String age)
    {
        _age = age;
    }

    public String getWeight()
    {
        return _weight;
    }

    public void setWeight(String weight)
    {
        _weight = weight;
    }

    public String getWeight_units()
    {
        return _weight_units;
    }

    public void setWeight_units(String weight_units)
    {
        _weight_units = weight_units;
    }

    public String getGestation()
    {
        return _gestation;
    }

    public void setGestation(String gestation)
    {
        _gestation = gestation;
    }

    public String getGender()
    {
        return _gender;
    }

    public void setGender(String gender)
    {
        _gender = gender;
    }

    public String getStrain()
    {
        return _strain;
    }

    public void setStrain(String strain)
    {
        _strain = strain;
    }

    public Integer getAnimalsordered()
    {
        return _animalsordered;
    }

    public void setAnimalsordered(Integer animalsordered)
    {
        _animalsordered = animalsordered;
    }

    public Integer getAnimalsreceived()
    {
        return _animalsreceived;
    }

    public void setAnimalsreceived(Integer animalsreceived)
    {
        _animalsreceived = animalsreceived;
    }

    public String getHousinginstructions()
    {
        return _housinginstructions;
    }

    public void setHousinginstructions(String housinginstructions)
    {
        _housinginstructions = housinginstructions;
    }

    public Date getRequestedarrivaldate()
    {
        return _requestedarrivaldate;
    }

    public void setRequestedarrivaldate(Date requestedarrivaldate)
    {
        _requestedarrivaldate = requestedarrivaldate;
    }

    public Date getExpectedarrivaldate()
    {
        return _expectedarrivaldate;
    }

    public void setExpectedarrivaldate(Date expectedarrivaldate)
    {
        _expectedarrivaldate = expectedarrivaldate;
    }

    public Date getReceiveddate()
    {
        return _receiveddate;
    }

    public void setReceiveddate(Date receiveddate)
    {
        _receiveddate = receiveddate;
    }

    public String getReceivedby()
    {
        return _receivedby;
    }

    public void setReceivedby(String receivedby)
    {
        _receivedby = receivedby;
    }

    public Date getDatecancelled()
    {
        return _datecancelled;
    }

    public void setDatecancelled(Date datecancelled)
    {
        _datecancelled = datecancelled;
    }

    public String getCancelledby()
    {
        return _cancelledby;
    }

    public void setCancelledby(String cancelledby)
    {
        _cancelledby = cancelledby;
    }

    public String getRoom()
    {
        return _room;
    }

    public void setRoom(String room)
    {
        _room = room;
    }

    public String getObjectid()
    {
        return _objectid;
    }

    public void setObjectid(String objectid)
    {
        _objectid = objectid;
    }

    public GUID getContainerid()
    {
        return _containerid;
    }

    public void setContainerid(GUID containerid)
    {
        _containerid = containerid;
    }
}
