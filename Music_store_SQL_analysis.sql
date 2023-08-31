									--QUESTION SET 1: EASY--
-- Q1. Who is the most senior employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;
-- Q2. Which countries have the most invoices?
SELECT COUNT(*) AS C,billing_country FROM invoice
GROUP BY billing_country 
ORDER BY C DESC;
--Q3. What are top three values of total invoice?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;
--Q4. Which city has the best customers(highest sum of invoice)?
SELECT billing_city,SUM(total) FROM invoice
GROUP BY billing_city, billing_state, billing_country
ORDER BY SUM(total) DESC
LIMIT 1;
--Q4. who is the best customer based on his spending on the app?
SELECT customer.customer_id,customer.first_name,customer.last_name,SUM(invoice.total) AS total 
FROM customer
JOIN invoice
ON customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1;

									--QUESTION SET 2: MODERATE--
--Q1: Write query to return the email, first name, last name & Genre of all Rock Music listeners. return the list ordered by
--mail alphabetically
SELECT DISTINCT email,first_name||' ' || last_name AS name
FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN (
	SELECT track_id FROM track
	JOIN genre ON track.genre_id=genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;
--Q2: Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands
SELECT artist.artist_id,artist.name,COUNT(*) AS number_of_songs FROM artist
JOIN album ON artist.artist_id=album.artist_id
JOIN track ON track.album_id=album.album_id
WHERE track.genre_id IN (SELECT genre.genre_id 
						 FROM genre
						WHERE genre.name LIKE 'Rock'
						)
GROUP BY artist.artist_id
ORDER BY COUNT(*) DESC
LIMIT 10;
-- Q3: Return all the track names and length that have a song length longer than the average song length. 
--Order by the song length with the longest songs listed first
SELECT name,milliseconds AS length FROM track
WHERE milliseconds>(SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

									----QUESTION SET 3: HARD----
--Q1: Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent
SELECT DISTINCT(customer.first_name||' '||customer.last_name) AS name,artist.name,invoice.total FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
JOIN track ON track.track_id=invoice_line.track_id
JOIN album ON album.album_id=track.album_id
JOIN artist ON artist.artist_id=album.artist_id
ORDER BY invoice.total DESC;
--Q2: We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the most total spent. Write a query 
--that returns each country along with the top Genre.
SELECT billing_country,genre.name,ROUND(SUM(total)) FROM genre
JOIN track ON track.genre_id=genre.genre_id
JOIN invoice_line ON invoice_line.track_id=track.track_id
JOIN invoice ON invoice.invoice_id=invoice_line.invoice_id
GROUP BY invoice.billing_country,genre.genre_id
ORDER BY genre.name;
--Q3: Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all 
--customers who spent this amount
WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;
