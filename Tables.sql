--osnovne tablice
CREATE TABLE Festivals(
	FestivalId SERIAL PRIMARY KEY,
	FestivalName VARCHAR(50) NOT NULL,
	City VARCHAR(30) NOT NULL,
	Capacity INT CHECK(Capacity >= 0),
	StartDate TIMESTAMP,
	EndDate TIMESTAMP CHECK(EndDate>=StartDate),
	Status VARCHAR(30) CHECK (Status IN ('planned', 'active', 'completed')),
	Camp BOOLEAN DEFAULT False
);

CREATE TABLE Performers(
	PerformerId SERIAL PRIMARY KEY,
	PerformerName VARCHAR(50) NOT NULL,
	Country VARCHAR(50) NOT NULL,
	MusicalGenre VARCHAR(50) NOT NULL,
	NumberOfMembers INT CHECK(NumberOfMembers>0),
	IsActive BOOLEAN DEFAULT True
);

CREATE TABLE Stages(
	StageId SERIAL PRIMARY KEY,
	StageName VARCHAR(50) NOT NULL,
	Location VARCHAR(50) NOT NULL,
	Capacity INT CHECK(Capacity>=0),
	HasRoof BOOLEAN DEFAULT False
);

CREATE TABLE Performances(
	PerformanceId SERIAL PRIMARY KEY,
	StartTime TIME NOT NULL,
	EndTime TIME NOT NULL,
	NumberOfVisitors INT CHECK(NumberOfVisitors >= 0)
);

CREATE TABLE Tickets(
	TicketId SERIAL PRIMARY KEY,
	Type VARCHAR(20) NOT NULL CHECK(Type in ('OneDay','Festival','VIP', 'Camp') ),
	Price FLOAT NOT NULL,
	Description TEXT
);

CREATE TABLE Visitors(
	VisitorId SERIAL PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	Surname VARCHAR(50) NOT NULL,
	BirthDate DATE NOT NULL CHECK (BirthDate < CURRENT_DATE),
	City VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	Country VARCHAR(50) NOT NULL
);

CREATE TABLE Purchase(
	PurchaseId SERIAL PRIMARY KEY,
	PurchaseMade TIMESTAMP NOT NULL,
	Price FLOAT NOT NULL
);

CREATE TABLE Workshop(
	WorkShopId SERIAL PRIMARY KEY,
	Name VARCHAR(50) NOT NULL,
	Difficulty VARCHAR(30) CHECK(Difficulty IN ('beginner', 'intermediate', 'advanced')),
	Capacity INT CHECK(Capacity>=0),
	Duration INT CHECK(Duration>=0),
	NeededPriorKnowledge BOOLEAN DEFAULT False
);

CREATE TABLE Mentor(
	MentorId SERIAL PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	Surname VARCHAR(50) NOT NULL,
	BirthDate DATE NOT NULL CHECK (BirthDate < CURRENT_DATE),
	AreaOfExpertise VARCHAR(50) NOT NULL,
	YearsOfExperience INT CHECK(YearsOfExperience>0)
);


CREATE TABLE Staff(
	StaffId SERIAL PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	Surname VARCHAR(50) NOT NULL,
	BirthDate DATE NOT NULL CHECK (BirthDate < CURRENT_DATE),
	Role VARCHAR(50) CHECK(Role IN ('organizer', 'technician', 'security guard', 'volunteer')),
    Contact VARCHAR(20) NOT NULL,
	HasSafetyTrainging BOOLEAN DEFAULT False
);

CREATE TABLE MembershipCards(
	MCardId SERIAL PRIMARY KEY,
	Activation DATE NOT NULL,
	ActiveStatus BOOLEAN DEFAULT True
);

-- postavljanje FK

ALTER TABLE Stages
	ADD COLUMN
	FestivalId INT REFERENCES Festivals(FestivalId);

ALTER TABLE Tickets
	ADD COLUMN
	FestivalId INT REFERENCES Festivals(FestivalId);

ALTER TABLE Workshop
	ADD COLUMN
	FestivalId INT REFERENCES Festivals(FestivalId);

ALTER TABLE Staff
	ADD COLUMN
	FestivalId INT REFERENCES Festivals(FestivalId);

ALTER TABLE Performances
	ADD COLUMN FestivalId INT,
	ADD COLUMN StageId INT,
	ADD COLUMN PerformerId INT,
	ADD CONSTRAINT FKPerformanceFestival
	FOREIGN KEY (FestivalId) REFERENCES Festivals(FestivalId),
	ADD CONSTRAINT FKPerformanceStage
	FOREIGN KEY (StageId) REFERENCES Stages(StageId),
	ADD CONSTRAINT FKPerformancePerformer
	FOREIGN KEY (PerformerId) REFERENCES Performers(PerformerId);

ALTER TABLE Purchase
	ADD COLUMN VisitorId INT,
	ADD COLUMN FestivalId INT,
	ADD CONSTRAINT FKPurchaseVisitor 
	FOREIGN KEY (VisitorId) REFERENCES Visitors(VisitorId),
	ADD CONSTRAINT FKPurchaseFestival 
	FOREIGN KEY (FestivalId) REFERENCES Festivals(FestivalId);

ALTER TABLE Workshop
	ADD COLUMN
	MentorId INT REFERENCES Mentor(MentorId);

-- M:N 

CREATE TABLE WorkshopVisitor(
	WorkshopId INT REFERENCES Workshop(WorkshopId),
	VisitorId INT REFERENCES Visitors(VisitorId),
	RegistrationStatus VARCHAR(30) CHECK (RegistrationStatus IN ('registered', 'cancelled', 'attended')),
	RegistrationTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY(WorkshopId, VisitorId)
);

CREATE TABLE PurchaseTickets(
	PurchaseId INT REFERENCES Purchase(PurchaseId),
	TicketId INT REFERENCES Tickets(TicketId),
	Quantity INT CHECK(Quantity>0),
	PRIMARY KEY(PurchaseId, TicketId)
);

-- dodatni uvjeti
CREATE OR REPLACE FUNCTION free_stage_for_performance()
	RETURNS TRIGGER
AS
$$
	BEGIN
	IF EXISTS(
		SELECT 1 FROM Performances performance
		WHERE (performance.StageId = NEW.StageId
		AND NEW.StartTime < performance.EndTime
		AND NEW.EndTime > performance.StartTime
		AND performance.PerformanceId <> New.PerformanceId
		)
	) THEN RAISE EXCEPTION 'The performance cannot be on an already occupied stage.';
	END IF;
RETURN NEW;
	END;
$$
language plpgsql;


CREATE TRIGGER Performance_Stage
	BEFORE INSERT OR UPDATE ON Performances
	FOR EACH ROW
	EXECUTE FUNCTION free_stage_for_performance();


CREATE OR REPLACE FUNCTION valid_mentor()
	RETURNS TRIGGER
AS
$$
	BEGIN
	IF EXTRACT(YEAR FROM AGE(NEW.BirthDate)) < 18 THEN
		RAISE EXCEPTION 'Mentor needs to be at least 18 years old.';
	ELSIF NEW.YearsOfExperience < 2 THEN
		RAISE EXCEPTION 'Mentors needs to have at least 2 years of experience.';
	ELSIF NEW.YearsOfExperience  > EXTRACT(YEAR FROM AGE(NEW.BirthDate)) THEN
		NEW.YearsOfExperience := EXTRACT(YEAR FROM AGE(NEW.BirthDate)) - 18 +2;
	END IF;
	RETURN NEW;
	END;
$$
language plpgsql;

CREATE TRIGGER Mentor_Validation
	BEFORE INSERT OR UPDATE ON Mentor
	FOR EACH ROW
	EXECUTE FUNCTION valid_mentor();

CREATE OR REPLACE FUNCTION valid_secure_guard()
	RETURNS TRIGGER
AS
$$
	BEGIN
	IF(NEW.Role = 'security guard' 
		AND EXTRACT(YEAR FROM AGE(NEW.BirthDate)) < 21)THEN
		RAISE EXCEPTION 'Security guard needs to be at least 21 years old.';
	END IF;
	RETURN NEW;
	END;
$$
language plpgsql;

CREATE TRIGGER Security_Guard_Validation
	BEFORE INSERT OR UPDATE ON Staff
	FOR EACH ROW
	EXECUTE FUNCTION valid_secure_guard();


ALTER TABLE MembershipCards
	ADD COLUMN 
	VisitorId INT UNIQUE REFERENCES Visitors(VisitorId);

CREATE OR REPLACE FUNCTION Is_Membership_Possible()
	RETURNS TRIGGER
AS
$$
	DECLARE festivalCount INT; SpentMoney FLOAT;
	BEGIN
	SELECT COUNT(DISTINCT FestivalId)
	INTO festivalCount
	FROM Purchase
	WHERE VisitorId = NEW.VisitorId;
	IF(festivalCount < 3) THEN
		RAISE EXCEPTION 'To get membership, visit at least 3 festivals.';
	END IF;

	SELECT SUM(Price)
	INTO SpentMoney
	FROM Purchase
	WHERE VisitorId = NEW.VisitorId;
	IF(SpentMoney < 600) THEN
		RAISE EXCEPTION 'To get membership, spend at least 600 euros.';
	END IF;
	RETURN NEW;
	END;
$$
language plpgsql;

CREATE TRIGGER Membership_Possibility
	BEFORE INSERT ON MembershipCards
	FOR EACH ROW
	EXECUTE FUNCTION Is_Membership_Possible();

--zaboravljena provjera
ALTER TABLE Performances
	ADD CONSTRAINT ValidPerformanceTime CHECK(EndTime>StartTime);




