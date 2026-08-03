-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2 
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Calculates the maximum total layoffs for each company, sorted from highest to lowest
SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;
-- Amazon has the highest total number of layoffs

-- Analyzes the specific timeframe in which a company's layoffs took place
SELECT MIN(`date`) , MAX(`date`)
FROM layoffs_staging2;

-- Maximum total layoffs grouped by industry sector
SELECT industry , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;
-- Identifies that the consumer industry experienced the highest layoffs, closely followed by the retail sector

-- Maximum total layoffs grouped and ordered by country
SELECT country , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;
-- The United States records the highest total layoffs, far exceeding the second-place country

-- Maximum total layoffs grouped by year
SELECT YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC;
-- Layoffs peaked aggressively in early 2023, while 2021 maintained the lowest overall totals

-- Maximum total layoffs grouped and ordered by stage
SELECT stage , SUM(total_laid_off)
FROM layoffs_staging2
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY SUM(total_laid_off) DESC;
-- Post-IPO companies register the highest total number of layoffs

-- Total number of layoffs grouped and ordered by calendar month
SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

-- Calculates the continuous rolling sum of layoffs month-by-month over the entire timeline
WITH ROLLING_TOTAL AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH` , total_off , SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM ROLLING_TOTAL;

-- Identifies the top five hardest-hit corporations for each calendar year based on maximum layoff volume
WITH Company_Year(company , years , total_laid_off) AS
(
SELECT company , YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
), Company_Year_Rank AS
(
SELECT * , DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC)AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;