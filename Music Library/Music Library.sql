Create Database Music_Library;

use Music_Library;
--------

create table Album(album_id int, title varchar(100), artist_id int);

ALTER TABLE Album
ALTER COLUMN album_id INT NOT NULL;

--------

Create Table Artist(artist_id int, name varchar(100));

ALTER TABLE Artist
ALTER COLUMN artist_id INT NOT NULL;

ALTER TABLE Artist
ADD CONSTRAINT PK_Artist PRIMARY KEY (artist_id);

ALTER TABLE Album
ADD CONSTRAINT FK_Album_Artist
FOREIGN KEY (artist_id) REFERENCES Artist(artist_id);

----------

Create Table Customer(customer_id int Not Null Primary key, first_name varchar(50), last_name varchar(50), company varchar(100), 
address varchar(100), city varchar(50), state varchar(20), country varchar(20), postal_code varchar(20), phone varchar(20), 
fax varchar(20),email varchar(50), support_rep_id int);


-----------

Create Table Employee(employee_id int Not Null Primary key, first_name varchar(50), last_name varchar(50), title varchar(50),
reports_to int, levels varchar(10), birthdate datetime, hire_date datetime, address varchar(100), city varchar(50), state varchar(20),
country varchar(20), postal_code varchar(20), phone varchar(20), fax varchar(20),email varchar(50));


-----------
Create Table Genere(genere_id int not null Primary Key,name varchar(20)); 


-----------
Create table Playlist(playlist_id int not null Primary Key,name varchar(20));


-----------
Create table Track(track_id int not null Primary Key,name varchar(1000), album_id int, media_type_id int, genere_id int,
composer varchar(1000), milliseconds varchar(20), bytes varchar(50), unit_price decimal(10,2));
select * from Track


------------
Create table Invoice(invoice_id int not null Primary Key,customer_id int, Foreign Key(customer_id) references Customer(customer_id),
invoice_date datetime, billing_address varchar(100), billing_city varchar(100), billing_state varchar(100),
billing_country varchar(100),billing_postal_code varchar(100),total decimal(10,2));
select * from Invoice;


-------------
Create Table Media_type(media_type_id int not null Primary Key, name varchar(50)); 
select * from Media_type;


-------------
Create Table Invoice_line(invoice_line_id int Primary Key, invoice_id int, track_id int, unit_price decimal(10,2), quantity int);
select * from Invoice_line;

ALTER TABLE Invoice_line
ADD CONSTRAINT FK_invoice_line_invoice
FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id);

ALTER TABLE Invoice_line
ADD CONSTRAINT FK_invoice_line_track
FOREIGN KEY (track_id) REFERENCES Track(track_id);


-------------

Create Table Playlist_Track(playlist_id int, track_id int);
select * from Playlist_Track;

ALTER TABLE Playlist_Track
ADD CONSTRAINT FK_Playlist_track
FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
FOREIGN KEY (track_id) REFERENCES Track(track_id);

------------
SELECT invoice_id
FROM Invoice_line
WHERE invoice_id NOT IN (SELECT invoice_id FROM Invoice);
