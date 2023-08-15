/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ---Create 5-2023-08-15 jonesga
 */
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
-- =============================================
-- Author:		Jonesga@phsu.edu
-- Create date: 2023/08/15
-- Description:Process to update billing date for ClinPath Run that are completed but have no billing date
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'UpdateClinPathBillingDate')
    DROP PROCEDURE UpdateClinPathBillingDate
GO
CREATE PROCEDURE onprc_billing.UpdateClinPathBillingDate

AS
BEGIN
    --Updates Lab Key Billing Date for ClinPath Runs


Update [studyDataset].[c6d199_clinpathruns]
set datefinalized =  date
where dateFinalized is null and date > '5/1/2023' and qcstate = 18



END
GO



