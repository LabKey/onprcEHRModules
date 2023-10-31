EXEC DropifExists 'annualinflationrate','onprc_billing','table',Null
/*EXEC DropifExists 'vw_covid19dcmdaily','onprc_billing','view',Null
EXEC DropifExists 'vw_covid19dcmschedule','onprc_billing','view',Null
EXEC DropifExists 'vw_covid19research','onprc_billing','view',Null*/
DROP VIEW IF EXISTS extcheculer.vw_covid19dcmdaily ;
DROP VIEW IF EXISTS extcheculer.vw_covid19dcmschedule ;
DROP VIEW IF EXISTS extcheculer.vw_covid19research ;