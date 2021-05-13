CREATE OR REPLACE FUNCTION departement_trigger_edit_code() RETURNS TRIGGER AS
$$
BEGIN
	New.code_departement = LTRIM(New.code_departement, '0');
	PERFORM * FROM departement WHERE code_departement = NEW.code_departement 
		OR nom_departement = NEW.nom_departement;
	IF (FOUND) THEN RAISE 'le département avec le nom % et le code % existe déjà',NEW.nom_departement,NEW.code_departement;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER departement_audit
	BEFORE INSERT OR UPDATE OF code_departement
	ON departement
	FOR EACH ROW
	EXECUTE PROCEDURE departement_trigger_edit_code(); 

CREATE OR REPLACE FUNCTION test_trigger_edit_code() RETURNS TRIGGER AS
$$
BEGIN
	IF (NEW.pop < 0 OR NEW.t < 0)
		THEN RAISE 'Les valeurs de pop et t doivent etre > à zéro';
	END IF;

	New.id_departement = LTRIM(New.id_departement, '0');

	PERFORM * FROM departement WHERE code_departement = NEW.id_departement;
	IF (NOT FOUND) THEN RAISE 'Le départment est incorrect %',New.id_departement;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER test_audit
	BEFORE INSERT OR UPDATE OF id_departement
	ON test
	FOR EACH ROW
	EXECUTE PROCEDURE test_trigger_edit_code(); 

CREATE OR REPLACE FUNCTION adresse_import_csv() RETURNS TRIGGER AS 
$$
	DECLARE id_adr INTEGER;
	DECLARE id_structure_adresse INTEGER;
	DECLARE ligne INTEGER;
BEGIN 
	IF TG_OP = 'INSERT' THEN 
		INSERT INTO adresse (adr_num, adr_voie, com_cp, com_insee, com_nom)
		   VALUES (NEW.adr_num, NEW.adr_voie, NEW.com_cp, NEW.com_insee, NEW.com_nom) RETURNING adresse.id_adresse INTO id_adr;

		SELECT id_adresse INTO ligne FROM  adresse WHERE NEW.structure_voie = adr_voie AND NEW.structure_cp  = com_cp
		   AND NEW.structure_insee = com_insee AND NEW.structure_com = com_nom;

		/*raise notice 'Value found: % %', ligne,id_adr ;*/

		IF FOUND THEN  id_structure_adresse = ligne;
				 ELSE  INSERT INTO adresse (adr_num, adr_voie, com_cp, com_insee, com_nom)
		   				VALUES (NEW.structure_num, NEW.structure_voie, NEW.structure_cp, 
		   					NEW.structure_insee, NEW.structure_com) RETURNING adresse.id_adresse INTO id_structure_adresse;
	
		END IF;

		INSERT INTO lieu_de_vaccination VALUES (New.gid, New.nom,New.id_adr, id_adr, New.lat_coor1, New.long_coor1,
			New.structure_siren, New.structure_type, New.structure_rais, id_structure_adresse, New.lieu_accessibilite,
			New.rdv_lundi,New.rdv_mardi, New.rdv_mercredi, New.rdv_jeudi, New.rdv_vendredi, New.rdv_samedi, New.rdv_dimanche, New.rdv, New.date_fermeture,
			New.date_ouverture, New.rdv_tel, New.rdv_consultation_prevaccination);

	END IF;

	RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER adresse_audit 
	BEFORE INSERT OR UPDATE 
	ON adresse_trigger
	FOR EACH ROW EXECUTE PROCEDURE adresse_import_csv();

CREATE OR REPLACE FUNCTION stocks_doses_vaccin_import_csv() RETURNS TRIGGER AS 
$$
DECLARE ligne INTEGER;
DECLARE ligne_1 INTEGER;
DECLARE departement VARCHAR;

BEGIN
	/*insert type of vaccin to vaccin table*/
	SELECT id_vaccin INTO ligne FROM vaccin WHERE  type_de_vaccin = New.type_de_vaccin;
	IF (NOT FOUND) THEN INSERT INTO vaccin(type_de_vaccin) VALUES (NEW.type_de_vaccin) RETURNING vaccin.id_vaccin INTO ligne;
	END IF;

	/* Insert into stockage_vaccin */

	SELECT id_stockage_vaccin INTO ligne_1 FROM stockage_vaccin WHERE  date_stockage = New._date;
	IF (NOT FOUND) THEN INSERT INTO stockage_vaccin(date_stockage) VALUES (NEW._date) RETURNING stockage_vaccin.id_stockage_vaccin INTO ligne_1;
	END IF;

	/* INSERT INTO stockage_vaccin_Departement */

	/*raise notice 'Value found: % ', NEW.code_departement ;*/
	INSERT INTO stockage_vaccin_Departement VALUES (NEW.code_departement, ligne_1, ligne, New.nb_doses, NEW.nb_ucd);

	RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER stocks_doses_vaccin_audit
	BEFORE INSERT OR UPDATE
	ON stocks_doses_vaccin_trigger
	FOR EACH ROW
	EXECUTE PROCEDURE stocks_doses_vaccin_import_csv();

CREATE OR REPLACE FUNCTION vaccination_edit_id_departement() RETURNS TRIGGER AS
$$
DECLARE ligne VARCHAR;
DECLARE ligne_1 VARCHAR;
BEGIN
	New.dep = LTRIM(New.dep, '0');

	SELECT code_departement INTO ligne FROM departement  WHERE code_departement = New.dep; 
	SELECT type_de_vaccin INTO ligne_1 FROM vaccin  WHERE id_vaccin = New.vaccin; 
	
	IF (ligne != '' and ligne_1 != '') THEN  RETURN New;
	END IF;
	RETURN NULL;
	
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER vaccination_audit
	BEFORE INSERT OR UPDATE
	ON vaccination
	FOR EACH ROW
	EXECUTE PROCEDURE vaccination_edit_id_departement();

CREATE OR REPLACE FUNCTION donnees_hospitaliere_edit_id_departement() RETURNS TRIGGER AS
$$
BEGIN
	New.dep = LTRIM(New.dep, '0');

	PERFORM *  FROM departement  WHERE code_departement = New.dep; 
	IF (NOT FOUND) THEN RAISE 'Le département % n''existe pas ',New.dep;
	END IF;

	IF (NEW.sexe < 0 OR NEW.sexe >2) THEN RAISE 'le sexe doit etre entre 0 et 2';
	END IF;

	IF (NEW.rea < 0) THEN RAISE 'le rea doit etre entre supérieure à zéro';
	END IF;

	IF (NEW.rad < 0) THEN RAISE 'le rad doit etre entre supérieure à zéro';
	END IF;

	IF (NEW.dc < 0) THEN RAISE 'le dc doit etre entre supérieure à zéro';
	END IF;

	PERFORM * FROM donnees_hospitaliere
		WHERE dep = NEW.dep AND sexe = NEW.sexe AND jour = NEW.jour;
	IF (FOUND) THEN RAISE 'la donnée hospitaliere existe déjà ';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER donnees_hospitaliere_audit
	BEFORE INSERT OR UPDATE
	ON donnees_hospitaliere
	FOR EACH ROW 
	EXECUTE PROCEDURE donnees_hospitaliere_edit_id_departement();

CREATE OR REPLACE FUNCTION rendez_vous_par_departement_import_csv() RETURNS TRIGGER AS
$$
DECLARE ligne VARCHAR;
BEGIN
	New.dep = LTRIM(New.dep, '0');

	SELECT code_departement INTO ligne FROM departement  WHERE code_departement = New.dep; 

	IF (ligne != '') THEN INSERT INTO rendez_vous_par_departement VALUES (New.dep, New.rang_vaccinal, New.date_debut_semaine, New.nb);
	END IF;
	RETURN NULL;
	
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER rendez_vous_par_departement_audit
	BEFORE INSERT OR UPDATE
	ON rendez_vous_par_departement_trigger
	FOR EACH ROW 
	EXECUTE PROCEDURE rendez_vous_par_departement_import_csv();

CREATE OR REPLACE FUNCTION vaccin_trigger_audit() RETURNS TRIGGER AS
$$
BEGIN
	PERFORM * FROM vaccin WHERE type_de_vaccin = New.type_de_vaccin;
	IF (FOUND) THEN RAISE 'ce type de vaccin % existe déjà dans la table',New.type_de_vaccin;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER vaccin_trigger
	BEFORE INSERT OR UPDATE
	ON vaccin
	FOR EACH ROW 
	EXECUTE PROCEDURE vaccin_trigger_audit();

CREATE OR REPLACE FUNCTION  lieu_de_vaccination_audit() RETURNS TRIGGER AS 
$$
BEGIN
	PERFORM * FROM lieu_de_vaccination WHERE gid = NEW.gid;
	IF (FOUND) THEN RAISE 'le lieu avec le meme gid = % existe déjà',NEW.gid;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER lieu_de_vaccination_trigger
	BEFORE INSERT OR UPDATE 
	ON lieu_de_vaccination
	FOR EACH ROW 
	EXECUTE PROCEDURE lieu_de_vaccination_audit();

CREATE OR REPLACE FUNCTION  stockage_vaccin_audit() RETURNS TRIGGER AS 
$$
BEGIN
	PERFORM * FROM stockage_vaccin WHERE date_stockage = NEW.date_stockage;
	IF (FOUND) THEN RAISE 'le stockage avec la meme date % existe déjà',NEW.date_stockage;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER lieu_de_vaccination_trigger
	BEFORE INSERT OR UPDATE 
	ON stockage_vaccin
	FOR EACH ROW 
	EXECUTE PROCEDURE stockage_vaccin_audit();

CREATE OR REPLACE FUNCTION  rendez_vous_par_departement_trigger_function() RETURNS TRIGGER AS 
$$
BEGIN
	New.id_departement = LTRIM(New.id_departement, '0');
	PERFORM * FROM departement  WHERE code_departement = NEW.id_departement;

	IF (NOT FOUND) THEN RAISE 'le département % n''existe pas ',NEW.id_departement;
	END IF;

	IF (NEW.rang_vaccinal < 0) THEN RAISE 'le rang vaccinal : % doit etre supérieure à zéro ',NEW.rang_vaccinal;
	END IF;

	IF (NEW.nb < 0) THEN RAISE 'le nb : % doit etre supérieure à zéro ',NEW.nb;
	END IF;

	PERFORM * FROM rendez_vous_par_departement WHERE
		date_debut_semaine = New.date_debut_semaine AND id_departement = New.id_departement AND rang_vaccinal = NEW.rang_vaccinal;
	IF (FOUND) THEN RAISE 'le rendez existe déja , vous voulez pas par contre augmenter le nombre de rendez vous pour ce rendez vous';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER rendez_vous_par_departement_trigger_edit
	BEFORE INSERT OR UPDATE 
	ON rendez_vous_par_departement
	FOR EACH ROW 
	EXECUTE PROCEDURE rendez_vous_par_departement_trigger_function();