PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Tableau : Country
CREATE TABLE IF NOT EXISTS Country (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          UNIQUE
                          NOT NULL,
    name          STRING,
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Director_film
CREATE TABLE IF NOT EXISTS Director_film (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          UNIQUE
                          NOT NULL,
    director_id   INTEGER REFERENCES Person (id),
    film_id       INTEGER REFERENCES Film (id),
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Film
CREATE TABLE IF NOT EXISTS Film (
    id            INTEGER UNIQUE
                          NOT NULL
                          PRIMARY KEY AUTOINCREMENT,
    name          STRING  NOT NULL,
    year          DATE,
    genre_id      INTEGER REFERENCES Genre (id),
    country_id    INTEGER REFERENCES Country (id),
    is_animation  BOOLEAN,
    is_serie      BOOLEAN,
    is_monochrome BOOLEAN,
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Film_Filmtag
CREATE TABLE IF NOT EXISTS Film_Filmtag (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          UNIQUE
                          NOT NULL,
    film_id       INTEGER REFERENCES Film (id),
    filmtag_id    INTEGER REFERENCES Filmtag (id),
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Filmtag
CREATE TABLE IF NOT EXISTS Filmtag (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          NOT NULL
                          UNIQUE,
    name          STRING  UNIQUE,
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Genre
CREATE TABLE IF NOT EXISTS Genre (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          NOT NULL
                          UNIQUE,
    name          STRING  UNIQUE,
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Mark
CREATE TABLE IF NOT EXISTS Mark (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          NOT NULL
                          UNIQUE,
    name          STRING,
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Person
CREATE TABLE IF NOT EXISTS Person (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          NOT NULL
                          UNIQUE,
    name          STRING,
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Settings
CREATE TABLE IF NOT EXISTS Settings (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          NOT NULL
                          UNIQUE,
    name          TEXT    UNIQUE,
    code          INTEGER,
    textcode      TEXT,
    description   TEXT,
    date_added    DATE    NOT NULL
                          DEFAULT (CURRENT_TIMESTAMP),
    date_modified DATE
);


-- Tableau : Translation
CREATE TABLE IF NOT EXISTS Translation (
    id          INTEGER NOT NULL
                        PRIMARY KEY AUTOINCREMENT
                        UNIQUE,
    name        TEXT    NOT NULL,
    code        INTEGER,
    id_parent   INTEGER REFERENCES Translation (id),
    id_ref      INTEGER,
    id_property NUMERIC,
    description TEXT,
    date_added  DATE    NOT NULL
                        DEFAULT (CURRENT_TIMESTAMP)
);


-- Tableau : Watched
CREATE TABLE IF NOT EXISTS Watched (
    id            INTEGER PRIMARY KEY AUTOINCREMENT
                          UNIQUE
                          NOT NULL,
    film_id       INTEGER REFERENCES Film (id),
    date          DATE,
    mark_id       INTEGER REFERENCES Mark (id),
    why           STRING,
    pub_why       STRING,
    how           STRING,
    pub_how       STRING,
    in_cinema     BOOLEAN,
    date_added    DATE    DEFAULT (CURRENT_TIMESTAMP)
                          NOT NULL,
    date_modified DATE
);


-- Déclencheur :  Watched_after_update
CREATE TRIGGER IF NOT EXISTS Watched_after_update AFTER UPDATE ON Watched BEGIN UPDATE Watched SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : Country_after_update
CREATE TRIGGER IF NOT EXISTS Country_after_update AFTER UPDATE ON Country BEGIN UPDATE Country SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : Director_Film_after_update
CREATE TRIGGER IF NOT EXISTS Director_Film_after_update AFTER UPDATE ON Director_film BEGIN UPDATE Director_Film SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : Film_after_update
CREATE TRIGGER IF NOT EXISTS Film_after_update AFTER UPDATE ON Film BEGIN UPDATE Film SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : Film_Filmtag_after_update
CREATE TRIGGER IF NOT EXISTS Film_Filmtag_after_update AFTER UPDATE ON Film_Filmtag BEGIN UPDATE Film_Filmtag SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : Filmtag_after_update
CREATE TRIGGER IF NOT EXISTS Filmtag_after_update AFTER UPDATE ON Filmtag BEGIN UPDATE 
Filmtag SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : Genre_after_update
CREATE TRIGGER IF NOT EXISTS Genre_after_update AFTER UPDATE ON Genre BEGIN UPDATE Genre SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : kk
CREATE TRIGGER IF NOT EXISTS kk AFTER INSERT ON Translation WHEN NEW.code IS NULL BEGIN UPDATE Translation SET code = COALESCE((SELECT MAX(code) FROM Translation WHERE CASE WHEN NEW.id_parent IS NULL THEN id_parent IS NULL ELSE id_parent = NEW.id_parent END), 0) + 1 WHERE id = NEW.id; END;

-- Déclencheur : Mark_after_update
CREATE TRIGGER IF NOT EXISTS Mark_after_update AFTER UPDATE ON Mark BEGIN UPDATE Mark SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : Person_after_update
CREATE TRIGGER IF NOT EXISTS Person_after_update AFTER UPDATE ON Person BEGIN UPDATE Person SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Déclencheur : Person_already_exists_check
CREATE TRIGGER IF NOT EXISTS Person_already_exists_check BEFORE INSERT ON Person BEGIN SELECT CASE WHEN (EXISTS(SELECT 1 FROM Person WHERE name = NEW.name)) THEN RAISE (ABORT, 'Director already exists.') END; END;

-- Déclencheur : Settings_after_update
CREATE TRIGGER IF NOT EXISTS Settings_after_update AFTER UPDATE ON Settings BEGIN UPDATE Settings SET date_modified = CURRENT_TIMESTAMP WHERE id = NEW.id AND date_modified IS OLD.date_modified; END;

-- Vue : _View_Films
CREATE VIEW IF NOT EXISTS _View_Films AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1)
    ,film_code AS (SELECT *  FROM View_get_translation_id_Film LIMIT 1)
    ,genre_code AS (SELECT *  FROM View_get_translation_id_Genre LIMIT 1)
    ,country_code AS (SELECT *  FROM View_get_translation_id_Country LIMIT 1)
    ,director_code AS (SELECT *  FROM View_get_translation_id_Person LIMIT 1) 
SELECT 
  F.id id
 ,coalesce(T.name,F.name) AS Film     -- Name in current language, else by default
 ,GROUP_CONCAT((SELECT T.name
                FROM Translation T 
                WHERE T.id_parent IN director_code
                  AND T.id_ref    IN curr_lang_code
                  AND T.id_property = P.id)) AS [Directors]
 ,(SELECT T.name
   FROM Translation T 
   WHERE T.id_parent IN country_code
     AND T.id_ref    IN curr_lang_code
     AND T.id_property = C.id) AS Country
 ,F.country_id   
 ,F.year AS Year
 ,CASE
    WHEN F.is_animation = 1 THEN "Y"
    ELSE NULL
  END AS Animation
 ,CASE
    WHEN F.is_serie = 1 THEN "Y"
    ELSE NULL
  END AS Serie
 ,CASE
    WHEN F.is_monochrome = 1 THEN "Y"
    ELSE NULL
  END AS Monochrome
 ,coalesce(                  -- Genre in current language, else by default
   (SELECT T.name
    FROM Translation T 
    WHERE T.id_parent IN genre_code
      AND T.id_ref    IN curr_lang_code
      AND T.id_property = G.id)
  ,G.name) AS Genre
FROM Film F
LEFT JOIN Translation T ON T.id_property = F.id
  AND T.id_ref    IN curr_lang_code 
  AND T.id_parent IN film_code
LEFT JOIN Director_film DF on F.id = DF.film_id
LEFT JOIN Person P ON P.id = DF.director_id
LEFT JOIN Genre G ON F.genre_id = G.id
LEFT JOIN Country C ON F.country_id = C.id
GROUP BY F.id;

-- Vue : _View_films_most_reviewed
CREATE VIEW IF NOT EXISTS _View_films_most_reviewed AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1)
    ,mark_code AS (SELECT *  FROM View_get_translation_id_Mark LIMIT 1)
    
SELECT      
       W.Reviews AS [Reviewed]
      ,VF.Film
      ,VF.Directors
      ,Avg_rating
      ,(SELECT T.name
        FROM Translation T 
        WHERE T.id_parent IN mark_code
          AND T.id_ref    IN curr_lang_code
          AND T.id_property = M.id) AS Mark
          
FROM _View_Films VF
JOIN (SELECT film_id
            ,mark_id
            ,avg(mark_id) as [Avg_rating]
            ,max(Reviews) Reviews
      FROM 
        (SELECT film_id
               ,mark_id
               ,ROW_NUMBER() OVER (PARTITION BY film_id ORDER BY date)AS Reviews
         FROM Watched
         WHERE Watched.date IS NOT NULL)
       GROUP BY film_id) AS W ON VF.id = W.film_id
LEFT JOIN Mark M ON W.mark_id = M.id
WHERE W.Reviews  > 1 
ORDER BY 1 DESC;

-- Vue : _View_Films_not_in_SEEN_table
CREATE VIEW IF NOT EXISTS _View_Films_not_in_SEEN_table AS SELECT ROW_NUMBER() OVER (ORDER BY W.date)
      ,F.id
      ,F.Film
      ,F.Directors
      ,F.Year
      ,F.Country AS [страна]  
      ,F.Animation
      ,F.Serie
      ,W.Why
FROM _View_Films F 
LEFT JOIN Watched W ON F.id = W.film_id
WHERE W.film_id IS NULL
ORDER BY 1;

-- Vue : _View_Films_to_see
CREATE VIEW IF NOT EXISTS _View_Films_to_see AS SELECT ROW_NUMBER() OVER (ORDER BY W.date)
      ,F.id
      ,F.Film
      ,F.Directors
      ,W.Why
      ,F.Year
      ,F.Country AS [страна]  
      ,F.Animation
      ,F.Serie
FROM
    _View_Films F LEFT JOIN Watched W ON F.id = W.film_id
WHERE W.date IS NULL
ORDER BY 1;


-- Vue : _View_get_film_captions_with_current_lang_or_default
CREATE VIEW IF NOT EXISTS _View_get_film_captions_with_current_lang_or_default AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1),
  film_code AS (SELECT *  FROM View_get_translation_id_Film LIMIT 1)
SELECT coalesce(T.name,F.name) 
FROM Film F
 LEFT JOIN Translation T ON T.id_property = F.id
   AND T.id_ref    IN curr_lang_code 
   AND T.id_parent IN film_code
 ORDER BY 1;

-- Vue : _View_get_mark_captions_with_current_lang
CREATE VIEW IF NOT EXISTS _View_get_mark_captions_with_current_lang AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1),
    mark_code AS (SELECT *  FROM View_get_translation_id_Mark LIMIT 1)
SELECT M.id
      ,T.name
FROM Mark M
LEFT JOIN Translation T ON T.id_property = M.id
WHERE 
    T.id_parent IN mark_code 
    AND T.id_ref IN curr_lang_code;

-- Vue : _View_Tagged films
CREATE VIEW IF NOT EXISTS "_View_Tagged films" AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1)
    ,tag_code AS (SELECT *  FROM View_get_translation_id_Tag LIMIT 1)
SELECT VF.id
      ,(SELECT "V" 
        FROM Watched  
        WHERE  film_id = VF.id) as "Watched"
      ,VF.Film
      ,VF.Directors
      ,VF.Country
      ,GROUP_CONCAT( (SELECT T.name
                      FROM Translation T 
                      WHERE T.id_parent IN tag_code
                        AND T.id_ref    IN curr_lang_code
                        AND T.id_property = FT.id)) AS Tags
FROM Film_Filmtag FF
LEFT JOIN _View_Films VF ON FF.film_id = VF.id
LEFT JOIN Filmtag FT ON FF.filmtag_id = FT.id
GROUP BY FF.film_id
ORDER BY 2;

-- Vue : _View_Top_Counties_with_coolest_films
CREATE VIEW IF NOT EXISTS _View_Top_Counties_with_coolest_films AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1)
    ,country_code AS (SELECT * FROM View_get_translation_id_Country LIMIT 1)
SELECT 
  (SELECT T.name
   FROM Translation T 
   WHERE T.id_parent IN country_code 
     AND T.id_ref    IN curr_lang_code  
     AND T.id_property = C.id) AS [Country]
  ,count(F.id) [Quantity]
FROM 
  Film F
JOIN Watched W ON W.film_id = F.id
JOIN Country C ON F.country_id = C.id
WHERE W.mark_id > 8     
GROUP BY 1
HAVING Quantity > 1
ORDER BY 2 DESC;

-- Vue : _View_Top_French_films
CREATE VIEW IF NOT EXISTS _View_Top_French_films AS SELECT VF.id
      ,VF.Film
      ,VF.Directors
      ,VF.Year
      ,VF.Animation
      ,VF.Serie
      ,CASE
         WHEN W.Reviews > 1 THEN  W.Reviews  
       END AS [Revied]
      ,W.Avg_rating    
FROM _View_Films VF
JOIN (SELECT film_id
            ,date
            ,avg(mark_id) as [Avg_rating]
            ,count(film_id) AS Reviews
      FROM Watched
      WHERE date IS NOT NULL
        AND mark_id IS NOT NULL
         GROUP BY film_id
) AS W ON VF.id = W.film_id   
 WHERE  VF.country_id = 2
 ORDER BY 8 DESC;

-- Vue : _View_Top_Russian_films
CREATE VIEW IF NOT EXISTS _View_Top_Russian_films AS SELECT VF.id
      ,VF.Film
      ,VF.Directors
      ,VF.Year
      ,VF.Animation
      ,VF.Serie
      ,CASE
         WHEN W.Reviews > 1 THEN  W.Reviews  
       END AS [Revied]
      ,W.Avg_rating    
FROM _View_Films VF
JOIN (SELECT film_id
            ,date
            ,avg(mark_id) as [Avg_rating]
            ,count(film_id) AS Reviews
      FROM Watched
      WHERE date IS NOT NULL
        AND mark_id IS NOT NULL
         GROUP BY film_id
) AS W ON VF.id = W.film_id   
 WHERE  VF.country_id = 1
 ORDER BY 8 DESC;

-- Vue : _View_Top_Soviet_films
CREATE VIEW IF NOT EXISTS _View_Top_Soviet_films AS SELECT VF.id
      ,VF.Film
      ,VF.Directors
      ,VF.Year
      ,VF.Animation
      ,VF.Serie
      ,CASE
         WHEN W.Reviews > 1 THEN  W.Reviews  
       END AS [Revied]
      ,W.Avg_rating    
FROM _View_Films VF
JOIN (SELECT film_id
            ,date
            ,avg(mark_id) as [Avg_rating]
            ,count(film_id) AS Reviews
      FROM Watched
      WHERE date IS NOT NULL
        AND mark_id IS NOT NULL
         GROUP BY film_id
) AS W ON VF.id = W.film_id   
 WHERE  VF.country_id = 3
 ORDER BY 8 DESC;

-- Vue : _View_Top_USA_films
CREATE VIEW IF NOT EXISTS _View_Top_USA_films AS SELECT VF.id
      ,VF.Film
      ,VF.Directors
      ,VF.Year
      ,VF.Animation
      ,VF.Serie
      ,CASE
         WHEN W.Reviews > 1 THEN  W.Reviews  
       END AS [Revied]
      ,W.Avg_rating    
FROM _View_Films VF
JOIN (SELECT film_id
            ,date
            ,avg(mark_id) as [Avg_rating]
            ,count(film_id) AS Reviews
      FROM Watched
      WHERE date IS NOT NULL
        AND mark_id IS NOT NULL
         GROUP BY film_id
) AS W ON VF.id = W.film_id   
 WHERE  VF.country_id = 4
 ORDER BY 8 DESC;

-- Vue : _View_Watched
CREATE VIEW IF NOT EXISTS _View_Watched AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1)
    ,mark_code AS (SELECT *  FROM View_get_translation_id_Mark LIMIT 1)
    
SELECT VF.id
      ,strftime('%Y', W.date) Date
      ,VF.Film
      ,VF.Directors
      ,VF.Year
      ,VF.Country
      ,VF.Animation
      ,VF.Serie
      ,W.why
      ,W.how
      ,W.Reviews AS [Review №]
      ,(SELECT T.name
        FROM Translation T 
        WHERE T.id_parent IN mark_code
          AND T.id_ref    IN curr_lang_code
          AND T.id_property = M.id) AS Mark
FROM _View_Films VF
JOIN (SELECT film_id
            ,date
            ,mark_id
            ,why
            ,how
            ,in_cinema
            ,ROW_NUMBER() OVER (PARTITION BY film_id ORDER BY date) AS Reviews
      FROM Watched
      WHERE Watched.date IS NOT NULL) AS W ON VF.id = W.film_id
 LEFT JOIN Mark M ON W.mark_id = M.id
 ORDER BY 2 DESC;

-- Vue : _View_Watched_by_country_no_repeats
CREATE VIEW IF NOT EXISTS _View_Watched_by_country_no_repeats AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1)
    ,country_code AS (SELECT * FROM View_get_translation_id_Country LIMIT 1)
    
SELECT
  (SELECT T.name
   FROM Translation T 
   WHERE T.id_parent IN country_code
     AND T.id_ref    IN curr_lang_code
     AND T.id_property = C.id) AS [Country]
  ,Count(C.name) AS [Films watched] 
FROM  
  (SELECT DISTINCT W.film_id
   FROM Watched W   
   WHERE W.date IS NOT NULL) TW
   JOIN Film F ON F.id = TW.film_id
   JOIN Country C ON F.country_id = C.id 
GROUP BY C.id
ORDER BY 2 DESC;

-- Vue : _View_Watched_current_year
CREATE VIEW IF NOT EXISTS _View_Watched_current_year AS WITH curr_lang_code AS (SELECT * FROM View_get_current_language_code LIMIT 1)
    ,mark_code AS (SELECT *  FROM View_get_translation_id_Mark LIMIT 1)
SELECT VF.id
      ,VF.Film
      ,VF.Directors
      ,VF.Year
      ,VF.Country
      ,VF.Animation
      ,VF.Serie
      ,W.why Why
      ,W.how How
      ,CASE
         WHEN  in_cinema = 1 THEN "V" 
       END AS [In cinema]
      ,(SELECT T.name
        FROM Translation T 
        WHERE T.id_parent IN mark_code
          AND T.id_ref    IN curr_lang_code
          AND T.id_property = M.id) AS Mark
FROM _View_Films VF
JOIN (SELECT film_id
            ,mark_id
            ,why
            ,how
            ,in_cinema
      FROM Watched
      WHERE strftime('%Y',  Watched.date) =  strftime('%Y', CURRENT_TIMESTAMP)    
) AS W ON VF.id = W.film_id
 LEFT JOIN Mark M ON W.mark_id = M.id
 ORDER BY 2 DESC;

-- Vue : View_get_current_language_code
CREATE VIEW IF NOT EXISTS View_get_current_language_code AS SELECT code FROM Settings
WHERE name = 'current_language';

-- Vue : View_get_translation_id_Country
CREATE VIEW IF NOT EXISTS View_get_translation_id_Country AS SELECT id FROM Translation T WHERE T.id_parent is NULL AND T.name = 'country';

-- Vue : View_get_translation_id_Film
CREATE VIEW IF NOT EXISTS View_get_translation_id_Film AS SELECT id  FROM Translation T WHERE T.id_parent is NULL AND T.name = 'film';

-- Vue : View_get_translation_id_Genre
CREATE VIEW IF NOT EXISTS View_get_translation_id_Genre AS SELECT id  FROM Translation T WHERE T.id_parent is NULL AND T.name = 'genre';

-- Vue : View_get_translation_id_Mark
CREATE VIEW IF NOT EXISTS View_get_translation_id_Mark AS SELECT id FROM Translation T WHERE T.id_parent is NULL AND T.name = 'mark';

-- Vue : View_get_translation_id_Person
CREATE VIEW IF NOT EXISTS View_get_translation_id_Person AS SELECT id  FROM Translation T WHERE T.id_parent is NULL AND T.name = 'person';

-- Vue : View_get_translation_id_Tag
CREATE VIEW IF NOT EXISTS View_get_translation_id_Tag AS SELECT id  FROM Translation T WHERE T.id_parent is NULL AND T.name = 'tag';

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
