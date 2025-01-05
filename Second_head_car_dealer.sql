-- SQL Project: Second Hand Car Dealer --
-- Read Cars data

SELECT * FROM cars.car_dekho;

-- Total Cars: To get a count of total records

SELECT COUNT(name) FROM cars.car_dekho;

-- The manager asked the employee How many cars will be available in 2023?

SELECT COUNT(*) FROM cars.car_dekho
WHERE year = 2023; 

-- The manager asked the employee How many cars is available in 2020,2021,2022

SELECT COUNT(*) FROM cars.car_dekho
WHERE year in (2022,2021,2020)
GROUP BY year;

-- Clint asked me to print the total of all cars by year. I don't see all the details.

SELECT year, COUNT(*) FROM cars.car_dekho
GROUP BY year;

-- Clint asked to car dealer agent How many diesel cars will there be in 2020?

SELECT COUNT(*) 
FROM cars.car_dekho
WHERE year = 2020 
AND fuel = "Diesel";

-- Clint requested a car dealer agent How many petrol cars will there be in 2020?

SELECT COUNT(*) 
FROM cars.car_dekho
WHERE year = 2020 
AND fuel = "Petrol";

-- The manager told the employee to give a print All the fuel cars (petrol, diesel, and CNG) come by all year.

SELECT fuel, COUNT(*) 
FROM cars.car_dekho
WHERE fuel in ('petrol','diesel','CNG')
GROUP BY fuel;

-- Manager said there were more than 100 cars in a given year, which year had more than 100 cars?

SELECT year, COUNT(*) 
FROM cars.car_dekho
GROUP BY year
HAVING count(*) > 100;

WITH my_cte
AS ( SELECT year, COUNT(*) AS year_count
	 FROM cars.car_dekho
     GROUP BY year)
SELECT year, 
CASE
	WHEN year_count > 100 THEN 'yes'
    ELSE 'no'
END AS more_than_100_cars
FROM my_cte;

-- The manager said to the employee All cars count details between 2015 and 2023; we need a complete list.

SELECT COUNT(*)
FROM cars.car_dekho
WHERE year BETWEEN 2015 AND 2023;

-- The manager said to the employee All cars details between 2015 to 2023 we need complete list

SELECT *
FROM cars.car_dekho
WHERE year BETWEEN 2015 AND 2023;
