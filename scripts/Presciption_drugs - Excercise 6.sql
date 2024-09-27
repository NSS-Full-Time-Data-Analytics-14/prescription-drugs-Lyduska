1.
 --    a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT DISTINCT npi, SUM (total_claim_count) AS total_claims
FROM prescription 
GROUP BY npi
ORDER BY total_claims desc
limit 1;
A:npi:1881634483
total claims: 99707

 -- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name  
	-- specialty_description, and the total number of claims.
SELECT DISTINCT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM (total_claim_count) AS total_claims
FROM prescription
	INNER JOIN prescriber USING (npi)
GROUP BY npi,nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_claims desc;

-- 2. a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, npi, SUM (total_claim_count) AS tcc
FROM prescriber
	INNER JOIN prescription USING (npi)
GROUP BY specialty_description, npi
ORDER BY tcc DESC
LIMIT 1;
A: Family Practice

-- b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM (total_claim_count) AS tcc
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name) WHERE opioid_drug_flag='Y'
GROUP BY specialty_description
ORDER BY tcc DESC
LIMIT 1;
A: Nurse Practitioner

    c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

    d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

3. -- a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, drug_name
FROM drug
	
SELECT drug_name, total_drug_cost
FROM prescription

SELECT  DISTINCT generic_name, ROUND(MAX(total_drug_cost),0) AS tdc
FROM drug
	INNER JOIN prescription USING(drug_name)
GROUP BY generic_name
ORDER BY tdc DESC
LIMIT 1;
A: PIRFENIDONE

 -- b. Which drug (generic_name) has the hightest total cost per day?
SELECT generic_name,
ROUND(MAX(prescription.total_drug_cost/total_day_supply),2)AS drug_cost_day
FROM drug
	INNER JOIN prescription USING(drug_name)
GROUP BY generic_name
ORDER BY drug_cost_day DESC
LIMIT 1;
A: Immun Glob , 7141.11 USD

 **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid'
	for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y',
	and says 'neither' for all other drugs. 
	**Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/
SELECT drug_name,
		CASE WHEN opioid_drug_flag= 'Y' THEN 'opiod'
				WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotics'
		ELSE 'neither'
		END AS drug_type
FROM drug;

-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
-- 	Hint: Format the total costs as MONEY for easier comparision.

SELECT SUM (total_drug_cost)::money,
		(CASE WHEN opioid_drug_flag= 'Y' THEN 'opiod'
			WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotics'
			ELSE 'neither' END)AS drug_type
FROM drug
INNER JOIN prescription USING (drug_name)
GROUP BY drug_type;
A: Neither $2,972,698,710.23

-- 5. a. How many CBSAs are in Tennessee?
	**Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT (fipscounty) AS state
FROM cbsa	
	INNER JOIN fips_county USING (fipscounty) WHERE state ILIKE ('%TN%')
GROUP BY state 
A:42

SELECT COUNT(DISTINCT cbsaname) AS CBSAs_Tennessee FROM cbsa
WHERE cbsaname ILIKE ('%TN%')
A:11;

    -- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT * 
FROM cbsa
SELECT *
FROM fips_county
SELECT *
FROM population

SELECT cbsaname, MAX (population) AS largest_population, MIN (population) AS lowest_population
FROM population
	INNER JOIN fips_county ON population.fipscounty=fips_county.fipscounty
	INNER JOIN cbsa ON population.fipscounty=cbsa.fipscounty
GROUP BY cbsaname
ORDER BY cbsaname, largest_population DESC, lowest_population ASC;


SELECT cbsaname, MAX (population) AS largest_population, MIN (population) AS lowest_population
FROM population
	INNER JOIN cbsa ON population.fipscounty=cbsa.fipscounty
	INNER JOIN fips_county ON population.fipscounty=fips_county.fipscounty
GROUP BY cbsaname
ORDER BY cbsaname, largest_population DESC, lowest_population ASC;

-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT *
FROM cbsa

SELECT *
FROM population

(SELECT cbsaname, SUM(population) total_population, 'Largest Population'
AS Population_type FROM cbsa
	INNER JOIN population using(fipscounty)
	INNER JOIN fips_county using(fipscounty)
GROUP BY cbsaname
order by 2 desc limit 1)
UNION
(SELECT cbsaname,SUM(population) total_population, 'Smallest Population'
AS Population_type FROM cbsa
INNER JOIN population USING(fipscounty)
INNER JOIN fips_county USING (fipscounty)
GROUP BY cbsaname
ORDER BY 2 limit 1);

6.
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count>=3000;


-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug.drug_name, prescription.total_claim_count,
CASE
WHEN drug.opioid_drug_flag = 'Y' THEN 'Opioid'
	ELSE 'Not Opioid'
	END AS opioid_flag
	FROM prescription
INNER JOIN drug ON drug.drug_name = prescription.drug_name
WHERE total_claim_count >= 3000;


SELECT drug.drug_name, prescription.total_claim_count,
	CASE
		WHEN drug.opioid_drug_flag = 'Y' THEN 'Opioid'
		ELSE 'Not Opioid'
	END AS opioid_flag
FROM prescription
INNER JOIN drug ON drug.drug_name = prescription.drug_name
WHERE total_claim_count >= 3000;


-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT * 
From prescriber;

SELECT drug_name, nppes_provider_last_org_name||' '||nppes_provider_first_name AS prescriber_name,total_claim_count,
  CASE
     WHEN opioid_drug_flag='Y' THEN 'Opiod'
		ELSE 'Not Opioid'
	END AS drug_is_opioid
FROM prescription
INNER JOIN drug USING(drug_name)
INNER JOIN prescriber USING(npi)
WHERE prescription.total_claim_count >=3000;


7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville
and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

    a. First, create a list of all npi/drug_name combinations for pain management specialists
	(specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'),
	where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it.
	You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations,
	whether or not the prescriber had any claims.
	You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT
	drug.drug_name,
	npi,
	SUM (total_claim_count) AS sum_total_claims, 
		prescriber.nppes_provider_first_name || ' ' || prescriber.nppes_provider_last_org_name AS provider
		FROM prescriber
			CROSS JOIN drug
			INNER JOIN prescription USING (npi)
				WHERE specialty_description = 'Pain Management'
				AND nppes_provider_city = 'NASHVILLE'
				AND opioid_drug_flag = 'Y'
					GROUP BY npi, drug.drug_name, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name
					ORDER BY sum_total_claims DESC;

--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0.
-- 	Hint - Google the COALESCE function.

-- SELECT drug.drug_name, npi,
-- 		COALESCE (SUM(total_claim_count,0)) AS total_claim_count
-- FROM prescriber
-- CROSS JOIN drug
-- INNER JOIN prescription USING(npi)
-- WHERE nppes_provider_city='NASHVILLE' 
-- 		and opioid_drug_flag='Y' and specialty_description='Pain Management'
-- 		GROUP BY npi,drug.drug_name
-- ORDER BY total_claim_count desc;


