/* Tables */

CREATE TABLE Centre(
	idCentre INT PRIMARY KEY,
	adresse VARCHAR(128) NOT NULL,
	nom VARCHAR(32) NOT NULL,
	horaires VARCHAR(128) NOT NULL,
	SIRET VARCHAR(14) NOT NULL,
	actif BOOL NOT NULL DEFAULT True
);

CREATE TABLE Client(
	idClient VARCHAR(16) PRIMARY KEY,
	prenom VARCHAR(32) NOT NULL,
	nom VARCHAR(32) NOT NULL,
	genre CHAR NOT NULL,
	telephone VARCHAR(10) NOT NULL,
	mail VARCHAR(64) NOT NULL
);


CREATE TABLE Reservation(
	idClient VARCHAR(16) PRIMARY KEY,
	idCentre INT PRIMARY KEY,
	dateResa DATE PRIMARY KEY,
	duree INT NOT NULL,
	commentaire VARCHAR(128),
	CONSTRAINT fk_client_reservation FOREIGN KEY idClient REFERENCES (Client)idClient,
	CONSTRAINT fk_centre_reservation FOREIGN KEY idCentre REFERENCES (Centre)idCentre,
);

/* Vues */

CREATE VIEW v_CommentairesCentre AS 
	SELECT dateResa, Commentaire FROM Reservation r JOIN Centre c ON r.idCentre = c.idCentre;	
		
CREATE VIEW v_CentresActifs AS
	SELECT idCentre, adresse, nom, horaires FROM Centre WHERE actif = True;

/* Roles et Droits */

CREATE ROLE Patron NOT IDENTIFIED; /* SELECT, INSERT, UPDATE Centre. */
GRANT SELECT, INSERT, UPDATE ON Centre TO Patron;

CREATE ROLE Secretaire NOT IDENTIFIED; /* ALL Client, ALL Reservation, SELECT Centre. */
GRANT ALL PRIVILEGES ON Client TO Secretaire;
GRANT ALL PRIVILEGES ON Reservation TO Secretaire;
GRANT SELECT ON Centre TO Secretaire;

CREATE ROLE Prospect NOT IDENTIFIED; /* SELECT SELF, UPDATE SELF Client, SELECT(idCentre, adresse, nom, horaire) WHERE actif=1 Centre, SELECT SELF Reservation. */
GRANT SELECT, UPDATE ON Client TO Prospect; /* SELF géré par la politique de sécurité */
GRANT SELECT ON Reservation TO Prospect; /* SELF géré par la politique de sécurité */
GRANT SELECT ON v_CentresActifs TO Prospect;

CREATE ROLE Technicien NOT IDENTIFIED; /* SELECT(datResa, Commentaire) Reservation JOIN Centre ON idCentre=idCentre*/
GRANT SELECT ON v_CommentairesCentre TO Technicien;

/* Contexte */

CREATE CONTEXT client_ctx USING client_ctx_pkg;
CREATE PACKAGE client_ctx_pkg IS
	PROCEDURE set_client;
CREATE PROCEDURE set_client IS
	typeRole VARCHAR(16);
BEGIN
	idClient := SYS_CONTEXT('USERENV', 'SESSION_USER');
	SELECT GRANTED_ROLE INTO typeRole FROM USER_ROLE_PRIVS WHERE GRANTEE LIKE 'admin25_%' ; /* Alvin 2, Elyne 23, Samuel 25 */
	DBMS_SESSION.SET_CONTEXT('client_ctx', 'idClient', typeRole);
END

/* Politiques */

/* SELF Client Coordonnees */
/* SELF Client Reservations */



	
	
