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








