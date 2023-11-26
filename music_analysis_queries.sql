--Q1.Who is the senior most employee based on job title
select * from employee
order by levels desc
limit 1;

--Q2 Which country have the most invoices
select billing_country, count(*) as number_of_orders from invoice
group by billing_country
order by number_of_orders desc
limit 1;

--Q3 What are top 3 values of total invoices
select total from invoice
order by total desc
limit 3;

--Q4 Which one city has the highest number of invoice totals. 
--Return both city name and sum of all invoice total.
select billing_city, sum(total) as sum_of_all_invoices
from invoice 
group by billing_city
order by sum_of_all_invoices desc
limit 1;

--Q5 Who is the best customer? Which customer has spent the most money?
select c.customer_id, c.first_name, c.last_name, sum(total) as money_spent from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by money_spent desc
limit 1;

--Q6 Return email, first name, last name, and genre of all rock music listeners.
--and order by email
select distinct c.email, c.first_name, c.last_name from customer c join invoice i
on c.customer_id = i.customer_id 
join invoice_line l on i.invoice_id = l.invoice_id 
where l.track_id in (select t.track_id from track t
				  join genre g on t.genre_id = t.genre_id
				  where g.name = 'Rock')
order by c.email 

--Q7 Who are the top 10 artists with most rock genre music
select a.artist_id, a.name, count(*) count_of_tracks from artist a join album b
on a.artist_id = b.artist_id 
join track t on b.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
group by a.artist_id order by count_of_tracks desc limit 10

--Q8 What are the names of tracks that has the length longer than average song length
--order by longest song length first
select name, milliseconds as length_of_songs from track
where milliseconds > (select avg(milliseconds) from track)
order by length_of_songs desc

--Q9 How much money was spent by each customer on artist?
WITH best_selling_artist AS (
	SELECT a.artist_id, a.name as artist_name, 
	SUM(l.unit_price*l.quantity) AS total_sales
	FROM invoice_line l
	JOIN track t ON t.track_id = l.track_id
	JOIN album b ON b.album_id = t.album_id
	JOIN artist a ON a.artist_id = b.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(l.unit_price*l.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line l ON l.invoice_id = i.invoice_id
JOIN track t ON t.track_id = l.track_id
JOIN album b ON b.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = b.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Q10 which is the most popular music genre according to each country
--(Most popular is determined by highest number of purchases)
with popular_genre as
(
	select count(*) as purchases, i.billing_country as country, G.name, g.genre_id,
	ROW_NUMBER() over(partition by i.billing_country order by count(l.quantity) desc) as row_no
	from invoice i join invoice_line l on i.invoice_id = l.invoice_id 
	join track t on l.track_id = t.track_id
	join genre g on t.genre_id = g.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where row_no <= 1;

--Q11 Who is the top customer that has spent most on music for each country

with customer_with_country as
(
	select c.customer_id, c.first_name, c.last_name, c.country, ROUND(CAST(sum(i.total) AS NUMERIC),2) as total_spent,
	row_number() over(partition by c.country order by sum(i.total) desc) as row_no
	from customer c join invoice i on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 4
)
select * from customer_with_country where row_no <= 1





















