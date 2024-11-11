
SELECT
'[Update order]' AS updatelink,
'[Print view]' AS printviewlink,
p.rowid,
p.requestdate,
p.projectname,
p.protocol,
p.investigator,
p.requestorid,
p.requestor,
p.vendor,
pd.species,
pd.gender,
pd.strain,
pd.weight,
pd.gestation,
pd.room,
pd.animalsordered,
pd.expectedarrivaldate,
p.confirmationnum,
p.housingconfirmed,
p.orderdate,
pd.sla_DOB,
pd.vendorLocation,
pd.housingInstructions,
pd.receiveddate,
pd.receivedby,
pd.datecancelled,
pd.cancelledby

FROM PublicPurchase p, PublicPurchaseDetails pd
WHERE p.objectid = pd.purchaseid

