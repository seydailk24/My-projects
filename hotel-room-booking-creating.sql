

-------hotel room ve booking adinda tablelar olusturdum 


CREATE TABLE "hotel" (
	"hotel_no"	INTEGER NOT NULL,
	"name"	TEXT NOT NULL,
	"address"	TEXT NOT NULL
);



CREATE TABLE "room" (
	"room_no"	INTEGER NOT NULL,
	"hotel_no"	INTEGER NOT NULL,
	"price"	REAL NOT NULL
);

CREATE TABLE "booking" (
	"hotel_no"	INTEGER NOT NULL,
	"guest_no"	INTEGER NOT NULL,
	"room_no"	INTEGER NOT NULL,
	FOREIGN KEY("room_no") REFERENCES "room"("room_no"),
	FOREIGN KEY("hotel_no") REFERENCES "hotel"("hotel_no")
);


------room , hotel ve booking table larina value atadim-----sadece birer satir----

INSERT INTO hotel(hotel_no, name , address)
VALUES ( 111,  ' Grosvenor hotel', 'Londan');

INSERT INTO room(room_no, hotel_no, price)
VALUES (1, 111 , 72.00);

INSERT INTO booking(hotel_no, guest_no,room_no)
VALUES (111, 'John Smith', 1);


----room masasindaki fiyat listesini 1.05 ile carparak fiyat degisikligi yaptim----

UPDATE room 
SET price = price * 1.05;
