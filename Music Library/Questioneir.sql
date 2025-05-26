
USE Music_Library;


/* Q1. Who is the senior most employee based on job title? */
select top 1 *
from employee
order by levels;

/* Q2. Which countries have the most Invoices? */ 
select count(*) count, billing_country 
from invoice
group by billing_country 
order by count desc;

/* Q3. What are top 3 values of total invoice? */
select top 3 total
from invoice
order by total desc;

/* Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that 
as the highest sum of invoice totals. Return both the city name & sum of all invoice totals. */
select sum(total) invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc;

/* Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money. */
select  top 1 customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id, first_name, last_name
order by total desc;

/* Q6. Write query to return the email, first name, last name, & genere of all Rock Music listeners. Return your list ordered alphabetically by email starting with A */
select distinct  email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
select track_id 
from track
join genere on track.genere_id = genere.genere_id
where genere.name like 'Rock'
)
order by email;

/* Q7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select top 10 artist.artist_id, artist.name, count(artist.artist_id) number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genere on genere.genere_id = track.genere_id
where genere.name like 'Rock'
group by artist.artist_id, artist.name
order by number_of_songs desc;

/* Q8. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first. */
--select name, milliseconds
--from track
--where milliseconds > (
--select avg(milliseconds) avg_track
--from track)
--order by milliseconds desc; 

SELECT name, milliseconds
FROM track
WHERE CAST(milliseconds AS INT) > (
    SELECT AVG(CAST(milliseconds AS FLOAT)) 
    FROM track
)
ORDER BY milliseconds DESC;


/* Q9. Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */
 
WITH best_selling_artist AS (
	SELECT top 1 artist.artist_id, artist.name as aname, 
    SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id, artist.name
	ORDER BY total_sales DESC
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.aname, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP 
BY c.customer_id, c.first_name, c.last_name, bsa.aname
ORDER BY 5 DESC;

/* Q10. We want to find out the most popular music genere for each country. We determine the 
most popular genere as the genere with the highest amount of purchases. Write a query 
that returns each country along with the top genere. For countries where the maximum 
number of purchases is shared return all generes */
WITH popular_genre AS 
(
    SELECT 
        COUNT(il.quantity) AS purchases, 
        c.country, 
        g.name AS genre_name, 
        g.genere_id, 
        ROW_NUMBER() OVER (
            PARTITION BY c.country 
            ORDER BY COUNT(il.quantity) DESC
        ) AS RowNo 
    FROM invoice_line il
    JOIN invoice i ON i.invoice_id = il.invoice_id
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genere g ON g.genere_id = t.genere_id
    GROUP BY c.country, g.name, g.genere_id
)
SELECT * 
FROM popular_genre 
WHERE RowNo = 1;


/* Q11. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Method 1 */
--WITH Customter_with_country AS (
--		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
--	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
--		FROM invoice
--		JOIN customer ON customer.customer_id = invoice.customer_id
--		GROUP BY 1,2,3,4
--		ORDER BY 4 ASC,5 DESC)
--SELECT * FROM Customter_with_country WHERE RowNo <= 1;

WITH Customer_with_country AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spending,
        ROW_NUMBER() OVER (
            PARTITION BY i.billing_country 
            ORDER BY SUM(i.total) DESC
        ) AS RowNo 
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT * 
FROM Customer_with_country 
WHERE RowNo = 1
ORDER BY billing_country ASC, total_spending DESC;


/* Method 2 */
WITH customer_with_country AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spending
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
country_max_spending AS (
    SELECT 
        billing_country,
        MAX(total_spending) AS max_spending
    FROM customer_with_country
    GROUP BY billing_country
)
SELECT 
    cc.billing_country, 
    cc.total_spending, 
    cc.first_name, 
    cc.last_name, 
    cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
    ON cc.billing_country = ms.billing_country
   AND cc.total_spending = ms.max_spending
ORDER BY cc.billing_country;
