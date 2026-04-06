🟢 Beginner Level (Basics)

-- Display all records from the dataset.

select * from medical_insurance;

-- Find the total number of patients.

select count(*) as total_patients from medical_insurance;

-- List distinct regions available in the dataset.

select distinct region from medical_insurance;

-- Find the average insurance charges.

select round(avg(annual_premium),2) as avg_ins_charges from medical_insurance;

-- Count how many smokers and non-smokers are there.

select smoker, count(*) as total_count from medical_insurance group by smoker;

select (select count(smoker) from medical_insurance
where smoker = 'Current') as smoker,
(select count(smoker) from medical_insurance
where smoker != 'Current') as non_smoker from medical_insurance
fetch first row only;

select
sum(case when smoker = 'Current' then 1 else 0 end) as smoker,
sum(case when smoker = 'Current' then 0 else 1 end) as non_smoker
from medical_insurance;

-- Find the minimum and maximum insurance charges.

select max(annual_premium) as max_ins_chrg, min(annual_premium) as min_ins_chrg from medical_insurance;

-- Show all patients who are smokers.

select * from medical_insurance
where smoker = 'Current';

-- Retrieve records where BMI is greater than 30.

select * from medical_insurance
where bmi > 30;

-- Find patients who have more than 2 children.

select * from medical_insurance
where dependents > 2;

-- Display patients from the south and west region.

select * from medical_insurance
where region = 'South'
or region = 'West';

select * from medical_insurance
where region in ('South', 'West');

🟡 Intermediate Level (Filtering & Aggregation)

-- Find the average charges for smokers vs non-smokers.

select smoker, round(avg(annual_premium),2) as avg_charges from medical_insurance
group by smoker;

-- Calculate average BMI by gender.

select sex as gender, round(avg(bmi),2) as avg_bmi from medical_insurance
group by sex;

-- Find the average insurance charges by region.

select region, round(avg(annual_premium),2) from medical_insurance
group by region;

-- Count number of patients in each region.

select region, count(*) as petients from medical_insurance
group by region;

-- Find the average charges for each age group.

select
case when age < 19 then 'Young'
when age between 19 and 39 then 'Adult'
when age between 39 and 60 then 'Mid_Age'
else 'Old'
end as age_group,
round(avg(annual_premium),2) as avg_charges
from medical_insurance
group by age_group
order by avg_charges;


-- Show regions where the average charges are greater than 15,000.

select region, round(avg(annual_premium),2) as avg_charges from medical_insurance
group by region
having avg(annual_premium) > 15000;

-- Find the number of smokers in each region.

select region, count(smoker) from medical_insurance
where smoker = 'Current'
group by region

-- Find the average charges for males and females separately.

select sex, round(avg(annual_premium),2) as avg_charges from medical_insurance
where sex != 'Other'
group by sex;

-- Identify patients whose charges are above the overall average charges.

select * from medical_insurance
where annual_premium > (select avg(annual_premium) from medical_insurance);

-- Find the total insurance charges per region.

select region, sum(annual_premium) as total_charges from medical_insurance
group by region;

🔵 Advanced Level (Subqueries & Window Functions)

-- Find patients who have charges higher than the average charges of smokers.

select * from medical_insurance
where annual_premium > (select avg(annual_premium) from medical_insurance where smoker = 'Current');

-- Find the highest insurance charge in each region.

select distinct region,
max(annual_premium) over(partition by region) 
from medical_insurance;

select region, max(annual_premium) as highest_charge
from medical_insurance
group by region;

-- Rank patients by insurance charges (highest to lowest).

select person_id, annual_premium,
rank() over(order by annual_premium desc) as rnk
from medical_insurance;

-- Find the top 3 highest charged patients in each region.

select region, annual_premium from
(select region, annual_premium,
rank() over(partition by region order by annual_premium desc) as rnk
from medical_insurance)
where rnk <= 3;

SELECT region, annual_premium
FROM (SELECT region, annual_premium,
ROW_NUMBER() OVER (PARTITION BY region ORDER BY annual_premium DESC) as patient_rank
FROM medical_insurance) 
WHERE patient_rank <= 3;

-- Calculate running total of insurance charges ordered by age.

select age, premium_charges,
sum(premium_charges) over(order by age)
from (
select distinct age, count(*),
sum(annual_premium) as premium_charges
from medical_insurance
group by age
order by age
);

SELECT age, annual_premium,
SUM(annual_premium)
OVER (ORDER BY age ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM medical_insurance
ORDER BY age;


-- Find patients whose BMI is above the regional average BMI.

with region_bmi as (select region, avg(bmi) as avg_reg_bmi from medical_insurance group by region)
select * from medical_insurance m
join region_bmi r
on m.region = r.region
where m.bmi > r.avg_reg_bmi;

-- Determine the percentage contribution of each region to total insurance charges.

select region, sum(annual_premium) as regional_contribution,
round(sum(annual_premium)*100 /sum(sum(annual_premium))over(),2) as percentage_contribution
from medical_insurance group by region;

-- Find the second highest insurance charge overall.

select max(annual_premium) as second_highest from medical_insurance
where annual_premium < (select max(annual_premium) from medical_insurance);

select annual_premium as second_highest from medical_insurance
order by annual_premium desc
offset 1 limit 1;

select annual_premium from medical_insurance
where annual_premium = (
select annual_premium from medical_insurance
group by annual_premium
order by annual_premium desc
offset 1
rows fetch first row only);

select annual_premium from (select distinct annual_premium,
row_number() over(order by annual_premium desc) as rn
from medical_insurance)
where rn = 2;

-- Identify regions where smokers’ average charges are higher than non-smokers’.

with avg_charges as (select region, smoker, avg(annual_premium) as avg_charge
from medical_insurance
group by region, smoker)
select s.region from avg_charges s
join avg_charges n
on s.region = n.region
where s.smoker = 'Current'
and n.smoker = 'Never'
and s.avg_charge > n.avg_charge;

-- Find patients with charges in the top 20% of all charges.

select * from medical_insurance
order by annual_premium desc
limit (select count(*)*.2 from medical_insurance);

🔴 Scenario-Based / Real-World Questions

-- Does smoking significantly increase insurance charges? (Compare averages)

select smoker, round(avg(annual_premium),2) from medical_insurance
where smoker in ('Current','Never')
group by smoker;

-- Which region is the most expensive for insurance on average?

select region, round(avg(annual_premium),2) from medical_insurance
group by region
order by avg(annual_premium) desc
limit 1;

-- Which age group tends to pay the highest insurance charges?

select case
when age < 18 then 'Minor'
when age between 18 and 40 then 'Adult'
when age between 41 and 60 then 'Mid_age'
else 'Old_age'
end as age_group,
round(avg(annual_premium),2) as avg_charges
from medical_insurance
group by age_group
order by avg(annual_premium) desc
limit 1

-- Are patients with children paying more on average than those without?

select case
when dependents > 1 then 'With_children'
else 'Without children'
end as dependent_type,
round(avg(annual_premium),2) as avg_charges
from medical_insurance
group by dependent_type;

-- Identify high-risk patients (Smoker + BMI > 30 + Charges above average).

select * from medical_insurance
where smoker = 'Current'
and bmi > 30
and annual_premium > (select avg(annual_premium) from medical_insurance);