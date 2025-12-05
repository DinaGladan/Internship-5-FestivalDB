-- Ispis svih radionica koje imaju razinu "napredna" i
-- održavaju se na festivalima u 2025. godini. 
SELECT * FROM Workshop
	WHERE Difficulty = 'advanced' 
	AND FestivalId IN
	( SELECT FestivalId 
		FROM Festivals
			WHERE EXTRACT (YEAR FROM start_date) = 2025
	);

-- Ispis svih nastupa (izvođač, festival, pozornica, vrijeme početka) 
-- za koje je očekivani broj posjetitelja veći od 10 000. 
SELECT * FROM Performances
	WHERE NumberOfVisitors > 10000

-- Ispis svih festivala koji se održavaju tijekom 2025. godine. 
SELECT * FROM Festivals
	WHERE EXTRACT (YEAR FROM start_date) = 2025 OR EXTRACT(YEAR FROM EndDate) = 2025

--Ispis svih radionica koje imaju razinu „napredna”.
SELECT * FROM Workshop
	WHERE Difficulty = 'advanced'

-- Ispis svih radionica koje traju više od 4 sata. 
SELECT * FROM Workshop --duration mi je u minutama
	WHERE Duration > 240

-- Ispis svih radionica koje zahtijevaju prethodno znanje.
SELECT * FROM Workshop
	WHERE NeededPriorKnowledge = True

-- Ispis svih mentora koji imaju više od 10 godina iskustva. 
SELECT * FROM Mentor
	WHERE YearsOfExperience > 10

-- Ispis svih mentora rođenih prije 1985. godine. 
SELECT * FROM Mentor
	WHERE EXTRACT( YEAR FROM BirthDate) < 1985

-- Ispis svih posjetitelja koji žive u Splitu.
SELECT * FROM Visitors
	WHERE City = 'Split'

-- Ispis svih posjetitelja čiji email završava s „@gmail.com”
SELECT * FROM Visitors
	WHERE Email like '%@gmail.com'

-- Ispis svih posjetitelja mlađih od 25 godina. 
SELECT * FROM Visitors
	WHERE EXTRACT (YEAR FROM AGE(BirthDate)) <25

-- Ispis svih ulaznica koje su skuplje od 120 €. 
SELECT * FROM Tickets
	WHERE Price > 120

-- Ispis svih ulaznica tipa „VIP”
SELECT * FROM Tickets
	WHERE Type = 'VIP'

-- Ispis svih festivalskih ulaznica koje vrijede za cijeli festival.
SELECT * FROM Tickets
	WHERE Type = 'Festival'

-- Ispis svih zaposlenika (osoblja) koji imaju potrebnu sigurnosnu obuku. 
SELECT * FROM Staff
	WHERE HasSafetyTrainging = True




