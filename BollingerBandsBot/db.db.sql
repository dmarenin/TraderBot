BEGIN TRANSACTION;
CREATE TABLE "offers" (
	`dt`	INTEGER,
	`type`	TEXT,
	`price`	INTEGER,
	`price2`	INTEGER,
	`add_data`	TEXT,
	`order_num`	INTEGER,
	`send_res`	TEXT,
	`status`	TEXT
);
CREATE TABLE "logs" (
	`dt`	INTEGER,
	`event`	TEXT,
	`data`	TEXT
);
COMMIT;
