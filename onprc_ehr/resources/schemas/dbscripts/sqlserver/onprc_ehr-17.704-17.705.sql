CREATE TABLE onprc_ehr.Frequency_DayofWeek(
	 RowId                    INT IDENTITY(1,1)NOT NULL,
	 FreqKey                  SMALLINT  NULL,
	 value                    SMALLINT  NULL,
   Meaning                  varchar(400) NULL,
   calenderType             varchar(100) NULL,
   Sort_order               SMALLINT NULL,
   DisableDate              smalldatetime NULL

    CONSTRAINT pk_FreqWeek PRIMARY KEY (RowId)

);