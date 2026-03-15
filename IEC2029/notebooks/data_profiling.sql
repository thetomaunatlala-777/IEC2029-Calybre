--- Check for missing data across all datasets


SELECT *
FROM bronze.voting_stations
WHERE vd_number IS NULL 
OR municipality_code IS NULL
OR province_id IS NULL
OR geometry IS NULL
OR api_response IS NULL
OR municipality_id IS NULL;
--There are no missing values in the voting_stations dataset



SELECT *
FROM bronze."2004_npe"
WHERE "ELECTORAL EVENT" IS NULL
OR "PROVINCE" IS NULL
OR "MUNICIPALITY" IS NULL
OR 'VOTING\nDistrict' IS NULL
OR "PARTY NAME" IS NULL
OR 'REGISTERED\nVOTERS' IS NULL
OR '% VOTER\nTURNOUT' IS NULL
OR 'VALID\nVOTES' IS NULL
OR 'SPOILT\nVOTES' IS NULL
OR 'TOTAL VOTES\nCAST' IS NULL;
--There are some rows that having missing values under the "Municipality
--column. We may have to fill these in using the "Voting Distric" values



SELECT * 
FROM bronze."2009_npe"
WHERE "ELECTORAL EVENT" IS NULL
OR "PROVINCE" IS NULL
OR "MUNICIPALITY" IS NULL
OR 'VOTING\nDistrict' IS NULL
OR "PARTY NAME" IS NULL
OR 'REGISTERED\nVOTERS' IS NULL
OR '% VOTER\nTURNOUT' IS NULL
OR 'VALID\nVOTES' IS NULL
OR 'SPOILT\nVOTES' IS NULL
OR 'TOTAL VOTES\nCAST' IS NULL
OR 'SECTION 24A\nVOTES' IS NULL
OR 'SPECIAL\nVOTES' IS NULL;
--There are no missing values in the 2009_npe dataset