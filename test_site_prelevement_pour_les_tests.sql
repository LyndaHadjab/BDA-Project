/* fonction pour insérer un site*/
CREATE OR REPLACE FUNCTION insert_site_prelevement_pour_les_tests(
        _id VARCHAR,_id_ej VARCHAR,_finess VARCHAR,
        _rs VARCHAR,_adresse VARCHAR,_cpl_loc VARCHAR,
        _do_prel VARCHAR,_do_antigenic VARCHAR,_longitude FLOAT,
        _latitude FLOAT,_mod_prel VARCHAR, _public VARCHAR,
        _horaire VARCHAR,_horaire_prio VARCHAR,_check_rdv 	VARCHAR,
        _tel_rdv VARCHAR,_web_rdv VARCHAR,_date_modif DATE) RETURNS void as 
$$
BEGIN
    PERFORM * FROM site_prelevement_pour_les_tests WHERE id = _id ;

    IF FOUND THEN 
        raise  'Le site avec le meme ID = % existe déjà', _id;
    END IF;

    INSERT INTO site_prelevement_pour_les_tests VALUES (_id,_id_ej,_finess,_rs,_adresse,_cpl_loc,_do_prel,_do_antigenic,_longitude,_latitude,
                _mod_prel,_public,_horaire,_horaire_prio,_check_rdv,_tel_rdv,_web_rdv,_date_modif
    );
            
END;
$$ LANGUAGE PLPGSQL;

select insert_site_prelevement_pour_les_tests (
              'HlI2rCJ014Dk4X3ZNEW' , '010001725' , '010001733', 
              'LBM CROIX', '51 AV AMEDEE' ,'oal',
              'OUI', 'NON' ,5.24 ,
              46.20 ,'Sur place' ,'Tout public' ,
              'oki', 'bom','Sur rendez-vous uniquement',
              '0474452636' ,'no','2020-10-29');

PREPARE select_new_insertion_site (text) as 
    SELECT * FROM site_prelevement_pour_les_tests WHERE id = $1;
EXECUTE select_new_insertion_site('HlI2rCJ014Dk4X3ZNEW');

/* fonction pour modifier un id d'un site */

CREATE OR REPLACE FUNCTION site_prelevement_pour_les_tests_edit_gid(_ID VARCHAR, new_gid VARCHAR) RETURNS void as 
$$
BEGIN
    PERFORM * FROM site_prelevement_pour_les_tests WHERE ID = _ID ;
    IF FOUND THEN 
        PERFORM * FROM site_prelevement_pour_les_tests WHERE ID = new_gid ;
        IF (FOUND) 
            THEN RAISE 'un site avec le meme id existe déjà';
        ELSE update site_prelevement_pour_les_tests set ID = new_gid where ID = _ID;
        END IF;
    ELSE RAISE 'le site avec le id = % n''exite pas',_ID;
    END IF; 
END;
$$ LANGUAGE PLPGSQL;

/*si on essaye de modifier un site par un id déjà existant */
select site_prelevement_pour_les_tests_edit_gid (
              'HlI2rCJ014Dk4X3ZNEW' , 'HlI2rCJ014Dk4X3Z');

/* sinon */
select site_prelevement_pour_les_tests_edit_gid (
              'HlI2rCJ014Dk4X3ZNEW' , 'HlI2rCJ014Dk4X3ZEdit');
EXECUTE select_new_insertion_site('HlI2rCJ014Dk4X3ZEdit');

/* fonction pour supprimer un site en donnat son id*/

CREATE OR REPLACE FUNCTION site_prelevement_pour_les_tests_delete_gid(_ID VARCHAR) RETURNS void as 
$$
BEGIN
    PERFORM * FROM site_prelevement_pour_les_tests WHERE ID = _ID ;
    IF FOUND THEN 
        delete from site_prelevement_pour_les_tests  where ID = _ID;
    ELSE RAISE 'le site avec le id = % n''exite pas',_ID;
    END IF; 
END;
$$ LANGUAGE PLPGSQL;

select site_prelevement_pour_les_tests_delete_gid (
              'HlI2rCJ014Dk4X3ZEdit');

SELECT * FROM site_prelevement_pour_les_tests WHERE id = 'HlI2rCJ014Dk4X3ZEdit';
