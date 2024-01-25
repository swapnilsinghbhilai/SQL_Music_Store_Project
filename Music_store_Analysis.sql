Select * From album;
Select * From artist;
Select * From customer;
Select * From employee;
Select * From genre;
Select * From invoice;
Select * From invoice_line;
Select * From media_type;
Select * From playlist;
Select * From playlist_track;
Select * From track;

/* Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

Select employee_id , first_name , last_name , title , levels
From employee
Order By levels DESC
Limit 1


/* Q2: Which countries have the most Invoices? */

Select billing_country , Count(billing_country) As no_of_invoice
From invoice
Group By billing_country
Order By Count(billing_country) DESC
Limit 1;

/* Q3: What are top 3 values of total invoice? */

Select * 
From invoice
Order By total DESC
Limit 3;


/* Q4: Which city has the best customers? We would like to throw a 
promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

Select billing_city , Sum(total) As invoice_total 
From invoice
Group by billing_city
Order by Sum(total) DESC
Limit 1;

/* Q5: Who is the best customer? The customer who has spent the most 
money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

Select c.customer_id , c.first_name , c.last_name , c.country , Sum(i.total) As total_invoice
From customer As c
Join invoice As i
On c.customer_id = i.customer_id
Group by c.customer_id 
Order by Sum(i.total) DESC
Limit 1;

/* Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

Select c.first_name , c.last_name , c.email 
From customer As c
Join invoice As i1
On c.customer_id = i1.customer_id
Join invoice_line As i2
On i1.invoice_id = i2.invoice_id
Join track As t
On i2.track_id = t.track_id
Join genre As g
On t.genre_id = g.genre_id
Where g.name = 'Rock'
Group By c.first_name , c.last_name , c.email
Order By c.email ASC

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

Select a1.artist_id As artist_id, a1.name As artist_name , Count(g.name) As Total_track_count
From artist As a1
Join album As a2
On a1.artist_id = a2.artist_id
Join track As t
On a2.album_id = t.album_id
Join genre As g
On t.genre_id = g.genre_id
Where g.name = 'Rock'
Group By a1.artist_id , a1.name
Order By Count(g.name) DESC
Limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

Select t.name As track_name , t.milliseconds As track_milliseconds 
From track As t
Where t.milliseconds > (Select Avg(milliseconds) As Average_Length From track)
Order By t.milliseconds DESC;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */

SELECT CONCAT(c.first_name, c.last_name) AS customer_name, a2.name AS artist_name, 
SUM(i2.unit_price * i2.quantity) AS total_spent
FROM customer AS c
JOIN invoice AS i1 ON c.customer_id = i1.customer_id
JOIN invoice_line AS i2 ON i1.invoice_id = i2.invoice_id
JOIN track AS t ON i2.track_id = t.track_id
JOIN album AS a1 ON t.album_id = a1.album_id
JOIN artist AS a2 ON a1.artist_id = a2.artist_id
WHERE a2.name = 
( 
		SELECT artist.name 
		FROM artist
        JOIN album ON artist.artist_id = album.artist_id
        JOIN track ON album.album_id = track.album_id
        JOIN invoice_line ON track.track_id = invoice_line.track_id
        GROUP BY artist.artist_id, artist.name
        ORDER BY SUM(invoice_line.unit_price * invoice_line.quantity) DESC
        LIMIT 1
)
GROUP BY customer_name, artist_name
ORDER BY total_spent DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

Select subquery_2.* From
(	
	Select subquery_1.* , 
	Rank() Over (PARTITION BY subquery_1.country ORDER BY subquery_1.purchase_per_genre DESC) As rank
	From 
		(
			Select Count(*) As purchase_per_genre , c.country , g.name , g.genre_id
			From customer As c
			Join invoice As i1 On c.customer_id = i1.customer_id
			Join invoice_line As i2 On i1.invoice_id = i2.invoice_id
			Join track As t On i2.track_id = t.track_id
			Join genre As g On t.genre_id = g.genre_id
			Group By c.country , g.name , g.genre_id
			Order By c.country ASC , Count(*) DESC
		) 	As subquery_1 
)   As subquery_2

Where subquery_2.rank = 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

Select subquery_2.* 
From
(
	Select subquery_1.billing_country , subquery_1.total_spending , subquery_1.first_name , 
	subquery_1.last_name , subquery_1.customer_id,
	Rank() Over (Partition By subquery_1.billing_country Order By subquery_1.total_spending DESC)
	From
	(
		Select c.customer_id , c.first_name , c.last_name , i.billing_country , Sum(i.total) As total_spending
		From customer As c
		Join invoice As i
		On c.customer_id = i.customer_id
		Group By c.customer_id , c.first_name , c.last_name , i.billing_country
	)	As subquery_1
Group By subquery_1.billing_country , subquery_1.total_spending ,subquery_1.first_name , 
subquery_1.last_name , subquery_1.customer_id
)   As subquery_2
Where subquery_2.rank = 1
Order By subquery_2.billing_country ASC , subquery_2.total_spending DESC