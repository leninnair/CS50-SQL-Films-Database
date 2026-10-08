-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Welcome to films database, my CS50 SQL Project.

---------------------------------------------
--              MAIN TABLES                --
---------------------------------------------

-- The films table, with its title, year, budget, revenue and verdict (whether it's hit, flop, blockbuster, average, etc.)
CREATE TABLE IF NOT EXISTS "films" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "title" TEXT NOT NULL,
    "year" INTEGER NOT NULL,
    "budget" INTEGER,
    "revenue" INTEGER,
    "verdict" TEXT CHECK ("verdict" IN ('Blockbuster', 'Super hit', 'Hit', 'Average', 'Flop', 'Disaster'))
);

--These are the people who act in, direct movies. Gives their location, birth year and last drawn salary also (if available).
CREATE TABLE IF NOT EXISTS "people" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "birth_year" INTEGER NOT NULL,
    "location" TEXT,
    "salary" INTEGER -- Recommended to be the last drawn salary.
);

-- Streaming platforms, TV channels, or theaters, wherever a film is available.
CREATE TABLE IF NOT EXISTS "platforms" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "url" TEXT,   -- Can be null in case of a theater or TV channel
    "type" TEXT NOT NULL CHECK ("type" IN ('Theater', 'Streaming', 'TV', 'Rental'))
);

-- Movies can be in several genres. Each genre is defined in this table.
CREATE TABLE IF NOT EXISTS "genres" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT   -- Can be null; but recommended to give a brief description of the genre.
);

-- Movies can have reviews and ratings.
CREATE TABLE IF NOT EXISTS "reviews" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "film_id" INTEGER NOT NULL, -- The id of the film associated with the review.
    "rating" REAL NOT NULL CHECK ("rating" >= 0 AND "rating" <= 5),
    "review" TEXT,   -- Can be null in case no review is associated with the rating.
    FOREIGN KEY("film_id") REFERENCES "films"("id")
);


-------------------------------------------------
--              JUNCTION TABLES                --
-------------------------------------------------

-- Junction table 1: Actors in films
CREATE TABLE IF NOT EXISTS "acted" (
    "film_id" INTEGER NOT NULL,
    "actor_id" INTEGER NOT NULL,
    PRIMARY KEY("film_id", "actor_id"), -- Ensures that there is no duplication of the same movie with the same actor.
    FOREIGN KEY ("film_id") REFERENCES "films"("id"),
    FOREIGN KEY ("actor_id") REFERENCES "people"("id")
);

-- Junction table 2: Directors of films
CREATE TABLE IF NOT EXISTS "directed" (
    "film_id" INTEGER NOT NULL,
    "director_id" INTEGER NOT NULL,
    PRIMARY KEY("film_id", "director_id"), -- Ensures that there is no duplication of the same movie with the same director.
    FOREIGN KEY ("film_id") REFERENCES "films"("id"),
    FOREIGN KEY ("director_id") REFERENCES "people"("id")
);

-- Junction table 3: Films and their availability
CREATE TABLE IF NOT EXISTS "availability" (
    "film_id" INTEGER NOT NULL,
    "platform_id" INTEGER NOT NULL,
    "views" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY("film_id", "platform_id"), -- Ensures that there is no duplication of the same movie and the same platform.
    FOREIGN KEY ("film_id") REFERENCES "films"("id"),
    FOREIGN KEY ("platform_id") REFERENCES "platforms"("id")
);

-- Junction table 4: Films and their genres
CREATE TABLE IF NOT EXISTS "film_genres" (
    "film_id" INTEGER NOT NULL,
    "genre_id" INTEGER NOT NULL,
    PRIMARY KEY("film_id", "genre_id"), -- Ensures that there is no duplication of the same movie and the same genre.
    FOREIGN KEY ("film_id") REFERENCES "films"("id"),
    FOREIGN KEY ("genre_id") REFERENCES "genres"("id")
);

-----------------------------------------
--            INDEXES                  --
-----------------------------------------
CREATE INDEX "movie_titles_idx" ON "films"("title"); -- Easy lookup of movie titles
CREATE INDEX "names_idx" ON "people"("first_name", "last_name"); -- Easy lookup of actors/directors.
CREATE INDEX "acted_idx" ON "acted"("actor_id"); -- Easy cross-referencing of actors who acted in specific movies.
CREATE INDEX "directed_idx" ON "directed"("director_id"); -- Fast cross-referencing of directors who directed movies.


-----------------------------------------
--              VIEWS                  --
-----------------------------------------

-- Get full details of a movie, such as its release year, director, genre, success detail, etc.
CREATE VIEW "film_details" AS
    SELECT "f"."title" "Title", REPLACE(GROUP_CONCAT(DISTINCT "d"."first_name" || ' ' || "d"."last_name"), ',', ', ') "Director", "year" "Release Year",
            REPLACE(GROUP_CONCAT(DISTINCT "g"."name"), ',', ', ') "Genre", REPLACE(GROUP_CONCAT(DISTINCT "a"."first_name" || ' ' || "a"."last_name"), ',', ', ') "Actors", "f"."verdict" "Verdict"
    FROM "films" "f"
    LEFT JOIN "directed" ON "f"."id" = "directed"."film_id"
    LEFT JOIN "acted" ON "f"."id" = "acted"."film_id"
    LEFT JOIN "people" "d" ON "d"."id" = "directed"."director_id"
    LEFT JOIN "people" "a" ON "a"."id" = "acted"."actor_id"
    LEFT JOIN "film_genres" ON "f"."id" = "film_genres"."film_id"
    LEFT JOIN "genres" "g" ON "film_genres"."genre_id" = "g"."id"
    GROUP BY "f"."id";

-- Get the details of all streaming platforms or theaters where a film is available to watch.
CREATE VIEW "film_availability" AS
    SELECT  "title" "Title", GROUP_CONCAT("name", ', ') "Available in" FROM "films"
    JOIN "availability" ON "availability"."film_id" = "films"."id"
    JOIN "platforms" ON "availability"."platform_id" = "platforms"."id"
    GROUP BY "films"."id";

-- Get the highest rating for each movie.
CREATE VIEW "highest_rating" AS
    SELECT "title" "Title", "rating" "Highest rating", "review" "Review" FROM "films"
    JOIN "reviews" ON "reviews"."film_id" = "films"."id"
    WHERE "rating" = (SELECT MAX("rating") FROM "reviews" WHERE "film_id" = "films"."id")
    GROUP BY "films"."id";
