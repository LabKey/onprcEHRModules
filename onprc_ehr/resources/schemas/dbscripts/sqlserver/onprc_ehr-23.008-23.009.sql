CREATE TABLE onprc_ehr.Environmental_Reference_Data (
        rowId int identity(1,1),
        label varchar(250) DEFAULT NULL,
        value varchar(500) ,
        columnName varchar(255)  NOT NULL,
        sort_order integer  null,
        endDate  datetime  DEFAULT NULL,

        CONSTRAINT pk_referenceenv PRIMARY KEY (value)
)


    GO