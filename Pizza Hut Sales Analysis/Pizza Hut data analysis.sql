Create Database PizzaHut;

use PizzaHut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id varchar(50) not null,
quantity int not null,
primary key(order_details_id)
);

CREATE TABLE pizzas (
    pizza_id varchar(50) NOT NULL,
    price DECIMAL(5,2) NOT NULL,
    size TEXT NOT NULL,
    pizza_type_id varchar(50) NOT NULL,
    PRIMARY KEY(pizza_id)
);

CREATE TABLE pizza_types (
    pizza_type_id varchar(50) NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    PRIMARY KEY(pizza_type_id)
);


-- 1.Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;


-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue_generated
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;


-- 3.Identify the highest-priced pizza.

SELECT top 1
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC;


-- 4.Identify the most common pizza size ordered.

SELECT 
    CAST(pizzas.size AS NVARCHAR(100)) AS size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY CAST(pizzas.size AS NVARCHAR(100))
ORDER BY order_count DESC;



-- 5.List the top 5 most ordered pizza types along with their quantities.

SELECT TOP 5
    CAST(pizza_types.name AS NVARCHAR(100)) AS name,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY CAST(pizza_types.name AS NVARCHAR(100))
ORDER BY quantity DESC;


-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    CAST(pizza_types.category AS NVARCHAR(100)) AS category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY CAST(pizza_types.category AS NVARCHAR(100)) 
ORDER BY quantity DESC;


-- 7.Determine the distribution of orders by hour of the day.

--SELECT 
--    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
--FROM
--    orders
--GROUP BY HOUR(order_time)
--ORDER BY order_count DESC;
SELECT 
    DATEPART(HOUR, order_time) AS hour,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY DATEPART(HOUR, order_time)
ORDER BY order_count DESC;


-- 8.Join relevant tables to find the category-wise distribution of pizzas.

--SELECT 
--    category, COUNT(name)
--FROM
--    pizza_types
--GROUP BY category;
WITH casted_pizza_types AS (
    SELECT 
        CAST(category AS NVARCHAR(100)) AS category
    FROM 
        pizza_types
)
SELECT 
    category,
    COUNT(*) AS pizza_count
FROM 
    casted_pizza_types
GROUP BY 
    category;




-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    


-- 10.Determine the top 3 most ordered pizza types based on revenue.

--SELECT top 3
--    pizza_types.name,
--    SUM(order_details.quantity * pizzas.price) AS revenue
--FROM
--    pizza_types
--        JOIN
--    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
--        JOIN
--    order_details ON order_details.pizza_id = pizzas.pizza_id
--GROUP BY pizza_types.name
--ORDER BY revenue DESC;
WITH casted_pizza_types AS (
    SELECT 
        CAST(pizza_types.name AS NVARCHAR(100)) AS name,
        order_details.quantity,
        pizzas.price
    FROM 
        pizza_types
    JOIN 
        pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN 
        order_details ON order_details.pizza_id = pizzas.pizza_id
)
SELECT TOP 3
    name,
    SUM(quantity * price) AS revenue
FROM 
    casted_pizza_types
GROUP BY 
    name
ORDER BY 
    revenue DESC;



-- 11.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    CAST(pizza_types.category AS NVARCHAR(100)) AS category,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100 , 2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY CAST(pizza_types.category AS NVARCHAR(100))
ORDER BY revenue DESC;



-- 12.Analyze the cumulative revenue generated over time.

select 
	order_date,
	sum(revenue) over(order by order_date) as cum_revenue
from 
	(select orders.order_date,
			sum(order_details.quantity * pizzas.price) as revenue
	from order_details 
	join pizzas on order_details.pizza_id = pizzas.pizza_id
	join orders on orders.order_id = order_details.order_id
	group by orders.order_date) as sales;



-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

--select 
--	name,revenue from
--	(select category,name,revenue,
--		rank() over (partition by category order by revenue desc) as rn
--		from
--			(select pizza_types.category, pizza_types.name,
--			sum((order_details.quantity) * pizzas.price) as revenue
--			from pizza_types join pizzas
--			on pizza_types.pizza_type_id = pizzas.pizza_type_id
--join order_details
--on order_details.pizza_id = pizzas.pizza_id
--group by pizza_types.category, pizza_types.name) as a) as b
--where rn <= 3;

SELECT 
    final.category,
    final.name,
    final.total_revenue
FROM (
    SELECT 
        inner_query.category,
        inner_query.name,
        inner_query.total_revenue,
        RANK() OVER (PARTITION BY inner_query.category ORDER BY inner_query.total_revenue DESC) AS rn
    FROM (
        SELECT 
            CAST(pt.category AS NVARCHAR(100)) AS category,
            CAST(pt.name AS NVARCHAR(100)) AS name,
            SUM(od.quantity * p.price) AS total_revenue
        FROM 
            pizza_types pt
        JOIN 
            pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN 
            order_details od ON od.pizza_id = p.pizza_id
        GROUP BY 
            CAST(pt.category AS NVARCHAR(100)),
            CAST(pt.name AS NVARCHAR(100))
    ) AS inner_query
) AS final
WHERE final.rn <= 3;



    