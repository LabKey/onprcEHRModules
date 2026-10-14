
--Updated 2/28/2015 by G Jones
--This is the code for providing the data needed for creation of the CITES Report
--The code evaluates various data points and produces either the data or a text statement to see support ---documentation

SELECT distinct
d.id,d.gender,d.species,d.geographic_origin,

--This section retrieves infomration pertaining to the animal being reviewed.
--We first determine if the animal was acquired or was born at onprc

Case When a.acquisitionType is Null
    Then ('Animal ID: ' || d.id ||' Born at ONPRC ' || ' '|| 'on : ' ||  Cast(d.birth as Varchar(12))|| ' Birth location: ' ||
        Case
            When b.room = 'No Location' Then 'See Supporting Documentation'
            Else b.room
        End ||
        '   Rearing Type:  Captive Reared')
    Else 'See Supporting Documentation  '

    End
    As BirthInfo,

--This section retieves any data pertaining to the Dam, if no data is available the support text is ---- --displayed
CASE
	WHEN (p.dam is Not Null)
        THEN ('DAM ID:  ' ||p.Dam ||
		CASE
			WHEN ((Select d3.id from demographics d3 join demographicsParents p2 on d3.id = p2.id where p2.id = p.Dam) is Not Null)
			THEN('  Born at ONPRC' ||  ' on ' || (Select Cast(d5.birth as varchar(12)) from demographics d5 where d5.id = p.dam))
			ELSE (' See Supporting Documentation')
		END)
	ELSE
		('See Supporting Documentation')
	END
    As DamInfo,
--This section retieves any data pertaining to the Sire, if no data is available the support text is ---- --displayed
CASE
	WHEN (p.sire is Not Null)
        THEN ('Sire ID:  ' ||p.Sire ||
		CASE
			WHEN ((Select d3.id from demographics d3 join demographicsParents p2 on d3.id = p2.id where p2.id = p.sire) is Not Null)
			THEN ('  Born at ONPRC' ||  ' on ' || (Select Cast(d4.birth as varchar(12)) from demographics d4 where d4.id = p.sire) )
			ELSE (' See Supporting Documentation')
		END)
	ELSE
		('See Supporting Documentation')
	END
    As SireInfo,

  Case When  a.acquisitionType.value is not Null
    Then  ('Acquired Animal' || ' from ' || a.source.meaning || ' on ' ||Cast (a.date as Varchar(12)) || ' Birthdate: ' ||Cast(d.birth as Varchar(12)) || ' Rearing Type  ' || a.rearingType.value  || '  OriginalID ' || a.originalID )
End  as AcquisitionInfo,

Case when a.acquisitionType is not Null
	Then ('Orginal ID: ' || a.originalID)
	End  as PreivousID




--Determines Birth location, not know on acquired animals


FROM demographics d left outer join arrival a on a.id = d.id
    left join study.birth b on b.id = d.id
	left join study.demographicsParents p on d.id = p.id
