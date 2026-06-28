--1. Which category has the highest purchase amount? By season?
SELECT 
category, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
GROUP BY category
ORDER BY SUM(purchase_amount_usd) desc
--1.1. each categorie’ revenue by each season
SELECT 
season, 
category, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
WHERE category = 'Clothing' -- 'Footwear', 'Accessories', 'Outerwear'
GROUP BY season, category
ORDER BY SUM(purchase_amount_usd) desc

--2. Does discount using behaviour boost our sales?
--2.1. %purchase_amount_using_discount vs no_using
With total as 
(
SELECT SUM(purchase_amount_usd) as total
FROM shopping_event
)
SELECT 
ROUND((SUM(purchase_amount_usd)/(SELECT total FROM total))*100,2) as "%purchase_amount_using_discount",
100-ROUND((SUM(purchase_amount_usd)/(SELECT total FROM total))*100,2) as "%purchase_amount_using_discount"
FROM shopping_event
WHERE discount_applied = 'Yes'
--2.2. %total customer are using discounts.
With total as 
(
SELECT COUNT(*) as total
FROM shopping_event
)
SELECT 
ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) as "%using_discount"
FROM shopping_event
WHERE discount_applied = 'Yes'
--2.3. Using & Not using discount by category
--2.3.1. Using discount by category
With total as 
(
SELECT COUNT(*) as total
FROM shopping_event
)
SELECT 
category,
ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) as "%using_discount"
FROM shopping_event
WHERE discount_applied = 'Yes'
GROUP BY category
ORDER BY ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) desc
--2.3.2. Not using discount by category
With total as 
(
SELECT COUNT(*) as total
FROM shopping_event
)
SELECT 
category,
ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) as "%using_discount"
FROM shopping_event
WHERE discount_applied = 'No'
GROUP BY category
ORDER BY ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) desc
--2.4. Using & Not using discount by season
--2.4.1. Using discount by season
With total as 
(
SELECT COUNT(*) as total
FROM shopping_event
)
SELECT 
season,
ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) as "%using_discount"
FROM shopping_event
WHERE discount_applied = 'Yes'
GROUP BY season
ORDER BY ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) desc
--2.4.2. Not using discount by season
With total as 
(
SELECT COUNT(*) as total
FROM shopping_event
)
SELECT 
season,
ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) as "%using_discount"
FROM shopping_event
WHERE discount_applied = 'No'
GROUP BY season
ORDER BY ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) desc

--3. Top 3 highest revenue of purchased Items by each Category.
With list as 
(
SELECT 
category, 
item_purchased, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
GROUP BY category, item_purchased
),
Rank_ as (
SELECT
category,
item_purchased,
ROW_NUMBER()OVER(
PARTITION BY category
ORDER BY revenue desc
) as rank_
FROM list
)

SELECT 
category,
item_purchased
FROM Rank_
WHERE rank_< 4

--4. Top 3 highest/ lowest revenue of Size & Color of purchased item by each category.  
--4.1. Top 3 highest
With list as 
(
SELECT 
category,
size,
color,
item_purchased, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
GROUP BY category, item_purchased, size, color
),
Rank_ as (
SELECT
category,
item_purchased,
size,
color,
ROW_NUMBER()OVER(
PARTITION BY category
ORDER BY revenue desc
) as rank_
FROM list
)

SELECT 
category,
size,
color,
item_purchased
FROM Rank_
WHERE rank_< 4
--4.2. Top 3 lowest
With list as 
(
SELECT 
category,
size,
color,
item_purchased, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
GROUP BY category, item_purchased, size, color
),
Rank_ as (
SELECT
category,
item_purchased,
size,
color,
ROW_NUMBER()OVER(
PARTITION BY category
ORDER BY revenue asc
) as rank_
FROM list
)

SELECT 
category,
size,
color,
item_purchased
FROM Rank_
WHERE rank_< 4

--5. Average Purchase Amount by Season — Which season generates the highest revenue? 
SELECT season, ROUND(AVG(purchase_amount_usd),1) as avg_purchase_amount
FROM shopping_event
GROUP BY season
ORDER BY AVG(purchase_amount_usd) desc

--6. Which season has the highest number of new customers?
SELECT season, segment, COUNT(*) as NO_customers
FROM shopping_event
WHERE segment = 'New Customers'
GROUP BY season, segment
ORDER BY COUNT(*) desc

--7. Which segment generates higher overall revenue?
SELECT 
segment, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
GROUP BY segment
ORDER BY SUM(purchase_amount_usd) desc

--8. How effective are customers who buy based on frequency?
SELECT 
frequency_of_purchases, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
GROUP BY frequency_of_purchases
ORDER BY SUM(purchase_amount_usd) desc

--9. Do customers with subscriptions (yes) have higher purchase amounts and 
--frequencies than non-subscribers?
--9.1. Member's total purchase amount
With total as 
(
SELECT SUM(purchase_amount_usd) as total
FROM shopping_event
)
SELECT 
ROUND((SUM(purchase_amount_usd)*1.0/(SELECT total FROM total))*100,2) as "Member_%_Purchase_amount"
FROM shopping_event
WHERE subscription_status = 'Yes'
ORDER BY ROUND((SUM(purchase_amount_usd)*1.0/(SELECT total FROM total))*100,2) desc
--9.2. % customer are our member 
With total as 
(
SELECT COUNT(*) as total
FROM shopping_event
)
SELECT 
ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) as "%Member"
FROM shopping_event
WHERE subscription_status = 'Yes'
ORDER BY ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) desc

--10. Customer group Frequency = Annually or Every 3 months — what do they buy, 
--and how old are they? 
SELECT 
age_group, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
WHERE frequency_of_purchases IN ('Every 3 Months','Annually')
GROUP BY age_group
ORDER BY SUM(purchase_amount_usd) desc
--10.1. Young adult's revenue by each category?
SELECT 
category, 
SUM(purchase_amount_usd) as revenue
FROM shopping_event
WHERE frequency_of_purchases IN ('Every 3 Months','Annually')
AND age_group = 'Young adult'
GROUP BY category
ORDER BY SUM(purchase_amount_usd) desc

--11. High Previous Purchases (multiple previous purchases) but low Review Rate (1-2) / 
--Low Frequency → Customers are about to leave, even if they were once loyal. How 
--many people are like that?
WITH total as 
(
SELECT COUNT(*) as total
FROM shopping_event
)
SELECT 
segment, 
ROUND((COUNT(*)*1.0/(SELECT total FROM total))*100,2) as "%NO_Customers"
FROM shopping_event
GROUP BY segment
ORDER BY COUNT(*) desc

--12. Which category has the worst review rate?
WITH total as
(
SELECT 
category, 
COUNT(*) as total
FROM shopping_event
GROUP BY category
),
list as (
SELECT 
category,
COUNT(*) as total
FROM shopping_event
WHERE review_rating < 3
GROUP BY category
)

SELECT 
a.category, ROUND(((b.total*1.0)/a.total)*100,1) AS "%bad_reviews"
FROM total a JOIN list b
ON a.category = b.category
ORDER BY a.category desc

--13. Customer review rating = 1-2 — Which shipping method did they use? (Delivery 
--issues?)
WITH total as
(
SELECT 
shipping_type, 
COUNT(*) as total
FROM shopping_event
GROUP BY shipping_type
),
list as (
SELECT 
shipping_type,
COUNT(*) as total
FROM shopping_event
WHERE review_rating < 3
GROUP BY shipping_type
)

SELECT 
a.shipping_type, ROUND(((b.total*1.0)/a.total)*100,1) AS "%bad_reviews"
FROM total a JOIN list b
ON a.shipping_type = b.shipping_type
ORDER BY ROUND(((b.total*1.0)/a.total)*100,1) desc

--14. Where are low review rates most common?
WITH total as
(
SELECT 
location, 
COUNT(*) as total
FROM shopping_event
GROUP BY location
),
list as (
SELECT 
location,
COUNT(*) as total
FROM shopping_event
WHERE review_rating < 3
GROUP BY location
)

SELECT 
a.location, ROUND(((b.total*1.0)/a.total)*100,1) AS "%bad_reviews"
FROM total a JOIN list b
ON a.location = b.location
ORDER BY ROUND(((b.total*1.0)/a.total)*100,1) desc
limit 10
--14.1. Which shipping type has bad_reviews each location
WITH total as
(
SELECT 
location,
shipping_type,
COUNT(*) as total
FROM shopping_event
GROUP BY location, shipping_type
),
list as (
SELECT 
location,
shipping_type,
COUNT(*) as total
FROM shopping_event
WHERE review_rating < 3
GROUP BY location, shipping_type
),
li as (
SELECT 
a.location, 
a.shipping_type,
ROUND(((b.total*1.0)/a.total)*100,1) AS "%bad_reviews",
ROW_NUMBER()OVER(
PARTITION BY a.location
ORDER BY ROUND(((b.total*1.0)/a.total)*100,1) desc
) as rank_
FROM total a JOIN list b
ON a.location = b.location
AND a.shipping_type = b.shipping_type
WHERE a.location IN ('Oklahoma', 'West Virginia', 'Connecticut', 'Georgia', 'South Dakota', 'New Hamsphire', 'Wyoming', 'Arizona', 'Arkansas', 'Michigan')
ORDER BY location, ROUND(((b.total*1.0)/a.total)*100,1) desc
)

SELECT *
FROM li
WHERE rank_ < 3

--15. Which age group spends the most?
SELECT age_group, SUM(purchase_amount_usd) as revenue
FROM shopping_event
GROUP BY age_group
ORDER BY SUM(purchase_amount_usd) desc
--15.1. Young_adult portfolio
WITH total as 
(
SELECT COUNT(*) AS total
FROM shopping_event
WHERE age_group = 'Young adult'
)

SELECT 
segment, 
ROUND((COUNT(*)*1.0/(SELECT * from total))*100,1) as "%NO_customers"
FROM shopping_event
WHERE age_group = 'Young adult'
GROUP BY segment
ORDER BY ROUND((COUNT(*)*1.0/(SELECT * from total))*100,1) desc

--15.2. Which customers pay more than avg after they already applied vouchers.
SELECT customer_id, segment, age_group
FROM shopping_event
WHERE purchase_amount_usd >= (
								SELECT AVG(purchase_amount_usd)
								FROM shopping_event
										)
ORDER BY purchase_amount_usd desc								

--15.2.1. How about Segment & age_group distribution from these customers?
SELECT segment, age_group, purchase_amount_usd
FROM shopping_event
WHERE purchase_amount_usd >= (
								SELECT AVG(purchase_amount_usd)
								FROM shopping_event
										)
ORDER BY purchase_amount_usd

--16. Which payment method is most popular according to age group? 
SELECT payment_method, COUNT(*) AS frequency
FROM shopping_event
GROUP BY payment_method
ORDER BY COUNT(*) desc
--16.1. Frequency of using payment method by age_group
WITH total as
(
SELECT 
age_group,
payment_method,
COUNT(*) as total
FROM shopping_event
GROUP BY age_group, payment_method
),
list as (
SELECT 
age_group,
payment_method,
total,
ROW_NUMBER()OVER(
PARTITION BY age_group
ORDER BY total desc
) as rank_
FROM total
ORDER BY age_group, payment_method, total desc
)

SELECT *
FROM list
WHERE rank_ < 4
ORDER BY age_group, rank_ asc

--17. Top 3 bad reviews of payment method by each age_group
WITH total as
(
SELECT 
age_group,
payment_method,
COUNT(*) as total
FROM shopping_event
GROUP BY age_group, payment_method
),
list as (
SELECT 
age_group,
payment_method,
COUNT(*) as total
FROM shopping_event
WHERE review_rating < 3
GROUP BY age_group, payment_method
),
li as (
SELECT 
a.age_group,
a.payment_method,
ROUND(((b.total*1.0)/a.total)*100,1) AS "%bad_reviews",
ROW_NUMBER()OVER(
PARTITION BY a.age_group
ORDER BY ROUND(((b.total*1.0)/a.total)*100,1) desc
) as rank_
FROM total a JOIN list b
ON a.age_group = b.age_group
AND a.payment_method = b.payment_method
ORDER BY a.age_group, a.payment_method, ROUND(((b.total*1.0)/a.total)*100,1) desc
)

SELECT *
FROM li
WHERE rank_ < 4



