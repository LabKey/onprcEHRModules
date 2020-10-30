/*
 * Copyright (c) 2013-2017 LabKey Corporation
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
 * 8/5/2016 updated based on new BCS Score calculations
 ***updated to use the newer calculations and identify the method of calculation
 */

SELECT
 bs.id
           ,bs.gender
           ,bs.species
           ,bs.yoa as YearofBirth
           ,bs.mostrecentweightdate
           ,bs.weight as MostRecentWeight
           ,bs.calcmethod as CalculationMethod
           ,bs.BCS as MostRecentBCS
           ,bs.BCSage
           ,bs.previousdraws
           ,bs.ABV as TotalAvailableBlood



FROM demographicsBloodSummary bs
