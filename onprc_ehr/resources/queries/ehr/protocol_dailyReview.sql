ONPRC PRIMe [Gary Dev 22.3] -Refreshed: 08-09-2022 ONPRC PRIMe [Gary Dev 22.3] -Refreshed: 08-09-2022
Gary Jones
ONPRC
Sections
Help
Quick EHR Search
OverviewAnimal SearchAnimal HistoryFrequently Used ReportsETL
Query Schema Browseronprc_ehr Schema
Edit protocol_dailYReview  EHR
Save & Finish
Save
Execute Query
Edit Properties
Edit Metadata
Help
,
44
    end as Reviewusda_level,
45
​
46
l.external_id,
47
l.project_type,
48
Case
49
when l.project_type =  lg.project_type then 'no change'
50
    when l.project_type is Null then 'no Value'
51
    else 'Review Needed'
52
    end as Reviewproject_type,
53
​
54
l.ibc_approval_required,
55
Case
56
when l.ibc_approval_required =  lg.ibc_approval_required then 'no change'
57
    when l.ibc_approval_required is Null then 'no Value'
58
    else 'Review Needed'
59
    end as Reviewibc_approval_required,
60
l.ibc_approval_num,
61
Case
62
when l.ibc_approval_num =  lg.ibc_approval_num then 'no change'
63
    when l.ibc_approval_num is Null then 'no Value'
64
    else 'Review Needed'
65
    end as Reviewibc_approval_num,
66
​
67
l.investigatorId,
68
Case
69
when l.investigatorId =  lg.investigatorId then 'no change'
70
    when l.investigatorId is Null then 'no Value'
71
    else 'Review Needed'
72
    end as ReviewinvestigatorId,
73
​
74
​
75
​
76
l.last_modification,
77
Case
78
when l.last_modification =  lg.last_modification then 'no change'
79
    when l.last_modification is Null then 'no Value'
80
    else 'Review Needed'
81
    end as Reviewlast_modification,
82
​
83
​
84
l.first_approval,
85
Case
86
when l.first_approval =  lg.first_approval then 'no change'
87
    when l.first_approval is Null then 'no Value'
88
    else 'Review Needed'
89
    end as Reviewfirst_approval,
90
l.lastAnnualReview, 
91
Case
92
when l.lastAnnualReview =  lg.lastAnnualReview then 'no change'
93
    when l.lastAnnualReview is Null then 'no Value'
94
    else 'Review Needed'
95
    end as ReviewlastAnnualReview
96
​
97
​
98
FROM ehr.protocol l, protocol_logs lg
99
where l.protocol =  lg.protocol
Powered by LabKey
Ctrl+Enter