SELECT market FROM gdb0041.dim_customer
where customer= "Atliq Exclusive" and region= "APAC"

-- What is the percentage of unique product increase in 2021 vs 2020? The final output contains these fields
-- unique_products_2020
-- unique_products_2021
-- percentage_chg

with cte1 as (
	select count(distinct p.product) as X from dim_product p
	join fact_sales_monthly s
	on p.product_code=s.product_code
	where fiscal_year = 2020
    ),
cte2 as (    
    select count(distinct p.product) as Y from dim_product p
	join fact_sales_monthly s
	on p.product_code=s.product_code
	where fiscal_year = 2021
    )
    
select 
	cte1.X as unique_products_2020, 
	cte2.Y as unique_products_2021, 
    round((cte2.Y-cte1.X) *100/cte1.X,2) as percentage_chg
from cte1 
join cte2 

-- provide a report with all the unique product counts for each segment and sort them in descending order of product counts. the final output contains e fields
-- segment and product_count


select segment, count(product_code) as product_count
from dim_product
group by segment
order by product_count desc

-- followup: which segment had the most increase in unique products in 2021 vs 2020? the final output contains these fields,
-- segment
-- product_count_2020
-- product_count_2021
-- difference

with cte1 as (
	select p.segment as X, count(distinct(p.product_code)) as A
	from dim_product p
	join fact_sales_monthly s
	on p.product_code=s.product_code
    where s.fiscal_year = 2021
	group by p.segment
    ),
cte2 as (
	select p.segment as Y, count(distinct(p.product_code)) as B
	from dim_product p
	join fact_sales_monthly s
	on p.product_code=s.product_code
	where s.fiscal_year = 2021
	group by p.segment
    )
select 
	cte1.X as segment,
	cte1.A as product_count_2020,
    cte2.B as product_count_2021, 
    cte2.B-cte1.A as Difference
from cte1
join cte2

-- Get the product that have the highest and lowest manufacturing costs. The final output should contain these fields,
-- Product_code -- Product -- Manufacturing_cost

SELECT * FROM gdb0041.dim_product;
SELECT * FROM gdb0041.fact_manufacturing_cost

with cte1 as (
	select 
		p.product_code as Product_code,p.product as Product,
		m.manufacturing_cost as Manufacturing_cost,
		dense_rank() over(order by m.manufacturing_cost desc) as X,
		dense_rank() over(order by m.manufacturing_cost asc) as Y
	from dim_product p
	join fact_manufacturing_cost m
	on p.product_code=m.product_code
    )
select 
	 Product_code,
     Product,
	 Manufacturing_cost
from cte1
where x=1 or Y=1
order by  Manufacturing_cost desc

-- Generate a report which contain the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian Market. the final output contains these fields,
-- Customer_code, -- Customer --Average_discount_percentage


select 
	c.customer_code, 
	c.customer,
    round(avg(pr.pre_invoice_discount_pct),2) as Average_discount_percentage
from dim_customer c
join fact_pre_invoice_deductions pr
on c.customer_code=pr.customer_code
where pr.fiscal_year = 2021
and c.market = "India"
group by c.customer_code,
		 c.customer
order by Average_discount_percentage desc
limit 5;

-- Get the complete report of the gross sales amount for the customer "Atliq Exclusive" for each month. The analysis helps to get an idea of low and high 
-- performing months and take strategic decisions. The final report contains these columns,
-- Month, -- Year, -- Gross_sales_amount
SELECT * FROM fact_gross_price
SELECT * FROM fact_sales_monthly
SELECT * FROM dim_customer;

select 
	monthname(s.date) as month,
    s.fiscal_year as Year,
    round(sum(g.gross_price * s.sold_quantity)/1000000,2) as  Gross_sales_amount_mlns   
from fact_gross_price g
join fact_sales_monthly s
on g.product_code= s.product_code
join dim_customer c
on c.customer_code= s.customer_code
where c.customer="Atliq Exclusive"
group by monthname(s.date), s.fiscal_year

















