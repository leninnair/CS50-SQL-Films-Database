-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- Inserting movie 'Spiderman: Brand New Day
INSERT INTO "films" ("title", "year", "budget", "revenue", "verdict")
       VALUES ('Spider-Man: Brand New Day', 2026, 225000000, 2500000000, 'Blockbuster');

-- Inserting actors and director and availability for the above movie
INSERT INTO "people" ("first_name", "last_name", "birth_year", "location", "salary") -- Director of spider-man
       VALUES ('Destin', 'Daniel Cretton', 1978, 'USA', 10000000);

INSERT INTO "directed" ("film_id", "director_id") VALUES ( -- updating the directed table with the director of spider-man
        (SELECT "id" FROM "films" WHERE "title" = 'Spider-Man: Brand New Day'),
        (SELECT "id" FROM "people" WHERE "first_name" = 'Destin' AND "last_name" = 'Daniel Cretton')
        );

INSERT INTO "people" ("first_name", "last_name", "birth_year", "location", "salary") -- Actor in spider-man
       VALUES ('Tom', 'Holland', 1996, 'USA', 20000000);

INSERT INTO "acted" ("film_id", "actor_id") VALUES ( -- updating the acted table with Tom Holland as actor in Spider-Man
        (SELECT "id" FROM "films" WHERE "title" = 'Spider-Man: Brand New Day'),
        (SELECT "id" FROM "people" WHERE "first_name" = 'Tom' AND "last_name" = 'Holland')
        );

INSERT INTO "availability" ("film_id", "platform_id", "views") -- Making the film available in Netflix and setting view count.
       VALUES (
        (SELECT "id" FROM "films" WHERE "title" = 'Spider-Man: Brand New Day'),
        (SELECT "id" FROM "platforms" WHERE "name" = 'Netflix'),
        100000000
       );

-- Adding a review for Spider-man movie
INSERT INTO "reviews" ("film_id", "rating", "review")
       VALUES (
        (SELECT "id" FROM "films" WHERE "title" = 'Spider-Man: Brand New Day'),
        4.87,
        'Spider-man is the most engaging film of the year.'
       );

-- Finding the details of the movie Spider-man
SELECT * FROM "film_details" WHERE "title" LIKE '%spider-man%brand%new%day%';

-- Finding availability of Spider-Man using the view film_availability.
SELECT * FROM "film_availability" WHERE "title" LIKE '%spider-man%brand new day%';

-- Which is the highest rating for a movie, using the highest_rating view.
SELECT * FROM "highest_rating" WHERE "title" = 'Spider-Man: Brand New Day';
