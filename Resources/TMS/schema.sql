--
-- KMSKA Optimizations to the MySQL database
--
-- These optimisations are geared towards the KMSKA Catmandu Fix as part of the
-- Arthub platform. These queries will add a set of indices to the MySQL tables,
-- and a set of views to ease up querying the data.
--
-- You will need to import these SQL file before attempting to run the
-- Datahub::Factory::Arthub.
--

--
-- INDEXES

-- Procedure to drop indexes, but only if they already exist

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_DropIndex` $$
CREATE PROCEDURE `sp_DropIndex` (tblName VARCHAR(64), ndxName VARCHAR(64))
BEGIN

    DECLARE IndexColumnCount INT;
    DECLARE SQLStatement VARCHAR(256);

    SELECT COUNT(1) INTO IndexColumnCount
    FROM information_schema.statistics
    WHERE table_schema = database()
    AND table_name = tblName
    AND index_name = ndxName;

    IF IndexColumnCount > 0 THEN
        SET SQLStatement = CONCAT('ALTER TABLE `',tblName,'` DROP INDEX`',ndxName,'`');
        SET @SQLStmt = SQLStatement;
        PREPARE s FROM @SQLStmt;
        EXECUTE s;
        DEALLOCATE PREPARE s;
    END IF;

END $$

DROP FUNCTION IF EXISTS `uf_get_first_digits`$$

CREATE FUNCTION `uf_get_first_digits`(as_val VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN

    DECLARE retval VARCHAR(255);
    DECLARE i INT;
    DECLARE strlen INT;
    -- shortcut exit for special cases
    IF as_val IS NULL OR as_val = '' THEN
        RETURN as_val;
    END IF;
    -- initialize for loop
    SET retval = '';
    SET i = 1;
    SET strlen = CHAR_LENGTH(as_val);
    do_loop:
        LOOP
            IF i > strlen THEN
            LEAVE do_loop;
        END IF;
        IF SUBSTR(as_val,i,1) IN ('0','1','2','3','4','5','6','7','8','9') THEN
            SET retval = CONCAT(retval,SUBSTR(as_val,i,1));
        ELSE
            LEAVE do_loop;
        END IF;
        SET i = i + 1;
        END LOOP do_loop;

    RETURN retval;

END$$

DELIMITER ;

-- ObjTitles

ALTER TABLE `ObjTitles` CHANGE `ObjectID` `ObjectID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ObjTitles` CHANGE `LanguageID` `LanguageID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ObjTitles` CHANGE `TitleTypeID` `TitleTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ObjTitles` CHANGE `DisplayOrder` `DisplayOrder` INT NULL DEFAULT NULL;
ALTER TABLE `ObjTitles` CHANGE `Displayed` `Displayed` INT NULL DEFAULT NULL;
ALTER TABLE `ObjTitles` CHANGE `Active` `Active` INT NULL DEFAULT NULL;
CALL sp_DropIndex ('ObjTitles', 'ObjectID');
ALTER TABLE `ObjTitles` ADD INDEX `ObjectID` ( `ObjectID` );
CALL sp_DropIndex ('ObjTitles', 'LanguageID');
ALTER TABLE `ObjTitles` ADD INDEX `LanguageID` ( `LanguageID` );
CALL sp_DropIndex ('ObjTitles', 'TitleTypeID');
ALTER TABLE `ObjTitles` ADD INDEX `TitleTypeID` ( `TitleTypeID` );
CALL sp_DropIndex ('ObjTitles', 'DisplayOrder');
ALTER TABLE `ObjTitles` ADD INDEX `DisplayOrder` ( `DisplayOrder` );
CALL sp_DropIndex ('ObjTitles', 'Displayed');
ALTER TABLE `ObjTitles` ADD INDEX `Displayed` ( `Displayed` );
CALL sp_DropIndex ('ObjTitles', 'Active');
ALTER TABLE `ObjTitles` ADD INDEX `Active` ( `Active` );

-- DDLanguages
ALTER TABLE `DDLanguages` CHANGE `LanguageID` `LanguageID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `DDLanguages` CHANGE `ISO369v1Code` `ISO369v1Code` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('DDLanguages', 'LanguageID');
ALTER TABLE `DDLanguages` ADD INDEX `LanguageID` ( `LanguageID` );
CALL sp_DropIndex ('DDLanguages', 'ISO369v1Code');
ALTER TABLE `DDLanguages` ADD INDEX `ISO369v1Code` ( `ISO369v1Code` );

-- Classifications

ALTER TABLE `Classifications` CHANGE `ClassificationID` `ClassificationID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Classifications` CHANGE `Classification` `Classification` VARCHAR( 255 ) NULL DEFAULT NULL ;
CALL sp_DropIndex ('Classifications', 'ClassificationID');
ALTER TABLE `Classifications` ADD INDEX `ClassificationID` ( `ClassificationID` , `Classification` );

-- ClassificationXRefs

ALTER TABLE `ClassificationXRefs` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ClassificationXRefs` CHANGE `ClassificationID` `ClassificationID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ClassificationXRefs', 'ClassificationID');
ALTER TABLE `ClassificationXRefs` ADD INDEX `ClassificationID` ( `ClassificationID`, `ID`);

-- ConXrefDetails

ALTER TABLE `ConXrefDetails` CHANGE `ConXrefDetailID` `ConXrefDetailID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefDetails` CHANGE `ConXrefID` `ConXrefID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefDetails` CHANGE `RoleTypeID` `RoleTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefDetails` CHANGE `ConstituentID` `ConstituentID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ConXrefDetails', 'ConXrefID');
ALTER TABLE `ConXrefDetails` ADD INDEX `ConXrefID` (`ConXrefID` );
CALL sp_DropIndex ('ConXrefDetails', 'ConstituentID');
ALTER TABLE `ConXrefDetails` ADD INDEX `ConstituentID` ( `ConstituentID` );

-- ConXrefs

ALTER TABLE `ConXrefs` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `ConXrefID` `ConXrefID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `RoleID` `RoleID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `RoleTypeID` `RoleTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `TableID` `TableID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `DisplayOrder` `DisplayOrder` INT NULL DEFAULT NULL;
CALL sp_DropIndex ('ConXrefs', 'ID');
ALTER TABLE `ConXrefs` ADD INDEX `ID` ( `ID` );
CALL sp_DropIndex ('ConXrefs', 'ConXrefID');
ALTER TABLE `ConXrefs` ADD INDEX `ConXrefID` ( `ConXrefID` );
CALL sp_DropIndex ('ConXrefs', 'RoleID');
ALTER TABLE `ConXrefs` ADD INDEX `RoleID` ( `RoleID` );
CALL sp_DropIndex ('ConXrefs', 'RoleTypeID');
ALTER TABLE `ConXrefs` ADD INDEX `RoleTypeID` ( `RoleTypeID` );
CALL sp_DropIndex ('ConXrefs', 'TableID');
ALTER TABLE `ConXrefs` ADD INDEX `TableID` ( `TableID` );
CALL sp_DropIndex ('ConXrefs', 'DisplayOrder');
ALTER TABLE `ConXrefs` ADD INDEX `DisplayOrder` ( `DisplayOrder` );

-- ObjContext (ObjectID)

ALTER TABLE `ObjContext` CHANGE `Period` `Period` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ObjContext', 'ObjectID');
ALTER TABLE `ObjContext` ADD INDEX `ObjectID` ( `ObjectID` , `Period` );

-- Objects

ALTER TABLE `Objects` CHANGE `ObjectID` `ObjectID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Objects` CHANGE `ObjectNumber` `ObjectNumber` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Objects', 'ObjectID');
ALTER TABLE `Objects` ADD INDEX `ObjectID` ( `ObjectID` );
CALL sp_DropIndex ('Objects', 'ObjectNumber');
ALTER TABLE `Objects` ADD INDEX `ObjectNumber` ( `ObjectNumber` );

-- Constituents

ALTER TABLE `Constituents` CHANGE `ConstituentID` `ConstituentID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Constituents', 'ConstituentID');
ALTER TABLE `Constituents` ADD INDEX `ConstituentID` ( `ConstituentID` );

-- Dimensions

ALTER TABLE `Dimensions` CHANGE `DimItemElemXrefID` `DimItemElemXrefID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Dimensions` CHANGE `DimensionTypeID` `DimensionTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Dimensions` CHANGE `PrimaryUnitID` `PrimaryUnitID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Dimensions', 'DimItemElemXrefID');
ALTER TABLE `Dimensions` ADD INDEX `DimItemElemXrefID` ( `DimItemElemXrefID` , `DimensionTypeID` ,  `PrimaryUnitID`);

-- DimensionTypes

ALTER TABLE `DimensionTypes` CHANGE `DimensionTypeID` `DimensionTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('DimensionTypes', 'DimensionTypeID');
ALTER TABLE `DimensionTypes` ADD INDEX `DimensionTypeID` ( `DimensionTypeID` );

-- DimensionElements

ALTER TABLE `DimensionElements` CHANGE `ElementID` `ElementID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('DimensionElements', 'ElementID');
ALTER TABLE `DimensionElements` ADD INDEX `ElementID` ( `ElementID` );

-- DimensionUnits

ALTER TABLE `DimensionUnits` CHANGE `UnitID` `UnitID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('DimensionUnits', 'UnitID');
ALTER TABLE `DimensionUnits` ADD INDEX `UnitID` ( `UnitID` );

-- DimItemElemXrefs

ALTER TABLE `DimItemElemXrefs` CHANGE `DimItemElemXrefID` `DimItemElemXrefID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `DimItemElemXrefs` CHANGE `TableID` `TableID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `DimItemElemXrefs` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `DimItemElemXrefs` CHANGE `ElementID` `ElementID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('DimItemElemXrefs', 'DimItemElemXrefID');
ALTER TABLE `DimItemElemXrefs` ADD INDEX `DimItemElemXrefID` ( `DimItemElemXrefID` );
CALL sp_DropIndex ('DimItemElemXrefs', 'TableID');
ALTER TABLE `DimItemElemXrefs` ADD INDEX `TableID` ( `TableID` );
CALL sp_DropIndex ('DimItemElemXrefs', 'ID');
ALTER TABLE `DimItemElemXrefs` ADD INDEX `ID` ( `ID` );
CALL sp_DropIndex ('DimItemElemXrefs', 'ElementID');
ALTER TABLE `DimItemElemXrefs` ADD INDEX `ElementID` ( `ElementID` );

-- Roles

ALTER TABLE `Roles` CHANGE `RoleID` `RoleID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Roles', 'RoleID');
ALTER TABLE `Roles` ADD INDEX `RoleID` ( `RoleID` );

-- Terms

ALTER TABLE `Terms` CHANGE `TermID` `TermID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Terms', 'TermID');
ALTER TABLE `Terms` ADD INDEX `TermID` ( `TermID` );

-- ThesXrefs

ALTER TABLE `ThesXrefs` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ThesXrefs` CHANGE `TermID` `TermID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ThesXrefs` CHANGE `ThesXrefTypeID` `ThesXrefTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ThesXrefs` CHANGE `TableID` `TableID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ThesXrefs', 'ID');
ALTER TABLE `ThesXrefs` ADD INDEX `ID` ( `ID` );
CALL sp_DropIndex ('ThesXrefs', 'TermID');
ALTER TABLE `ThesXrefs` ADD INDEX `TermID` ( `TermID` );
CALL sp_DropIndex ('ThesXrefs', 'ThesXrefTypeID');
ALTER TABLE `ThesXrefs` ADD INDEX `ThesXrefTypeID` ( `ThesXrefTypeID` );
CALL sp_DropIndex ('ThesXrefs', 'TableID');
ALTER TABLE `ThesXrefs` ADD INDEX `TableID` ( `TableID` );

-- UserFieldXrefs

ALTER TABLE `UserFieldXrefs` CHANGE `UserFieldID` `UserFieldID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `UserFieldXrefs` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('UserFieldXrefs', 'UserFieldID');
ALTER TABLE `UserFieldXrefs` ADD INDEX `UserFieldID` ( `UserFieldID` );
CALL sp_DropIndex ('UserFieldXrefs', 'ID');
ALTER TABLE `UserFieldXrefs` ADD INDEX `ID` ( `ID` );

-- Associations

ALTER TABLE `Associations` CHANGE `AssociationID` `AssociationID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Associations` CHANGE `ID1` `ID1` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Associations` CHANGE `ID2` `ID2` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Associations` CHANGE `RelationshipID` `RelationshipID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Associations', 'AssociationID');
ALTER TABLE `Associations` ADD INDEX `AssociationID` ( `AssociationID`, `ID1`, `ID2`, `RelationshipID` );

-- Relationships

ALTER TABLE `Relationships` CHANGE `RelationshipID` `RelationshipID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Relationships', 'RelationshipID');
ALTER TABLE `Relationships` ADD INDEX `RelationshipID` ( `RelationshipID` );

-- AltNums

ALTER TABLE `AltNums` CHANGE `AltNumID` `AltNumID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `AltNums` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('AltNums', 'AltNumID');
ALTER TABLE `AltNums` ADD INDEX `AltNumID` ( `AltNumID` , `ID` );

-- Departments

ALTER TABLE `Departments` CHANGE `DepartmentID` `DepartmentID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Departments', 'DepartmentID');
ALTER TABLE `Departments` ADD INDEX `DepartmentID` ( `DepartmentID` );

-- Locations

ALTER TABLE `Locations` CHANGE `LocationID` `LocationID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Locations', 'LocationID');
ALTER TABLE `Locations` ADD INDEX `LocationID` ( `LocationID` );

-- ObjLocations

ALTER TABLE `ObjLocations` CHANGE `ObjLocationID` `ObjLocationID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ObjLocations` CHANGE `LocationID` `LocationID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ObjLocations', 'ObjLocationID');
ALTER TABLE `ObjLocations` ADD INDEX `ObjLocationID` ( `ObjLocationID` , `LocationID` );

-- ObjComponents

ALTER TABLE `ObjComponents` CHANGE `ComponentID` `ComponentID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ObjComponents` CHANGE `CurrentObjLocID` `CurrentObjLocID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ObjComponents` CHANGE `ObjectID` `ObjectID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ObjComponents', 'ComponentID');
ALTER TABLE `ObjComponents` ADD INDEX `ComponentID` ( `ComponentID` , `CurrentObjLocID` , `ObjectID` );

-- MediaFiles

ALTER TABLE `MediaFiles` CHANGE `FileID` `FileID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `MediaFiles` CHANGE `RenditionID` `RenditionID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `MediaFiles` CHANGE `PathID` `PathID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('MediaFiles', 'FileID');
ALTER TABLE `MediaFiles` ADD INDEX `FileID` ( `FileID` , `RenditionID` , `PathID` );

-- MediaRenditions

ALTER TABLE `MediaRenditions` CHANGE `RenditionID` `RenditionID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `MediaRenditions` CHANGE `MediaMasterID` `MediaMasterID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('MediaRenditions', 'RenditionID');
ALTER TABLE `MediaRenditions` ADD INDEX `RenditionID` ( `RenditionID` , `MediaMasterID` );

-- MediaXrefs

ALTER TABLE `MediaXrefs` CHANGE `MediaXrefID` `MediaXrefID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `MediaXrefs` CHANGE `MediaMasterID` `MediaMasterID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `MediaXrefs` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `MediaXrefs` CHANGE `TableID` `TableID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('MediaXrefs', 'MediaXrefID');
ALTER TABLE `MediaXrefs` ADD INDEX `MediaXrefID` ( `MediaXrefID` , `MediaMasterID`, `ID`, `TableID` );

-- TextEntries

ALTER TABLE `TextEntries` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `TextEntries` CHANGE `TextTypeID` `TextTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('TextEntries', 'ID');
ALTER TABLE `TextEntries` ADD INDEX `ID` ( `ID` );
CALL sp_DropIndex ('TextEntries', 'TextTypeID');
ALTER TABLE `TextEntries` ADD INDEX `TextTypeID` ( `TextTypeID` );

-- ClassificationNotations

ALTER TABLE `ClassificationNotations` CHANGE `TermMasterID` `TermMasterID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ClassificationNotations', 'TermMasterID');
ALTER TABLE `ClassificationNotations` ADD INDEX `TermMasterID` ( `TermMasterID` );

-- StatusFlags

ALTER TABLE `StatusFlags` CHANGE `ObjectID` `ObjectID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('StatusFlags', 'ObjectID');
ALTER TABLE `StatusFlags` ADD INDEX `ObjectID` ( `ObjectID` );

-- AuthorityTranslations

ALTER TABLE `AuthorityTranslations` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('AuthorityTranslations', 'ID');
ALTER TABLE `AuthorityTranslations` ADD INDEX `ID` ( `ID` );

-- TermMasterThes

ALTER TABLE `TermMasterThes` CHANGE `TermMasterID` `TermMasterID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('TermMasterThes', 'TermMasterID');
ALTER TABLE `TermMasterThes` ADD INDEX `TermMasterID` ( `TermMasterID` );

-- Exhibitions

ALTER TABLE `Exhibitions` CHANGE `ExhibitionID` `ExhibitionID` VARCHAR(255) NULL DEFAULT NULL;
ALTER TABLE `Exhibitions` CHANGE `ProjectNumber` `ProjectNumber` VARCHAR(255) NULL DEFAULT NULL;
ALTER TABLE `Exhibitions` CHANGE `ExhibitionTitleID` `ExhibitionTitleID` VARCHAR(255) NULL DEFAULT NULL;
CALL sp_DropIndex ('Exhibitions', 'ExhibitionID');
ALTER TABLE `Exhibitions` ADD INDEX `ExhibitionID` ( `ExhibitionID` );
CALL sp_DropIndex ('Exhibitions', 'ProjectNumber');
ALTER TABLE `Exhibitions` ADD INDEX `ProjectNumber` ( `ProjectNumber` );
CALL sp_DropIndex ('Exhibitions', 'ExhibitionTitleID');
ALTER TABLE `Exhibitions` ADD INDEX `ExhibitionTitleID` ( `ExhibitionTitleID` );

-- ExhObjXrefs

ALTER TABLE `ExhObjXrefs` CHANGE `ExhibitionID` `ExhibitionID` VARCHAR(255) NULL DEFAULT NULL;
ALTER TABLE `ExhObjXrefs` CHANGE `ObjectID` `ObjectID` VARCHAR(255) NULL DEFAULT NULL;
CALL sp_DropIndex ('ExhObjXrefs', 'ExhibitionID');
ALTER TABLE `ExhObjXrefs` ADD INDEX `ExhibitionID` ( `ExhibitionID` );
CALL sp_DropIndex ('ExhObjXrefs', 'ObjectID');
ALTER TABLE `ExhObjXrefs` ADD INDEX `ObjectID` ( `ObjectID` );

-- ExhibitionTitles

ALTER TABLE `ExhibitionTitles` CHANGE `ExhibitionTitleID` `ExhibitionTitleID` VARCHAR(255) NULL DEFAULT NULL;
CALL sp_DropIndex ('ExhibitionTitles', 'ExhibitionTitleID');
ALTER TABLE `ExhibitionTitles` ADD INDEX `ExhibitionTitleID` ( `ExhibitionTitleID` );


--
-- VIEWS

-- VIEW Constituents

CREATE OR REPLACE VIEW vconstituents AS
SELECT o.ObjectID as _id, o.ObjectNumber, c.ConstituentID, c.AlphaSort, c.DisplayName, c.BeginDate, c.EndDate, c.BeginDateISO, c.EndDateISO, r.Role as role_nl, at.Translation1 as role_en, at.Translation2 as role_fr, cr.DisplayOrder,
    IF(te.TextEntry <> 'CC0', CONCAT(te.TextEntry, ', ', YEAR(NOW())), te.TextEntry) as copyright
FROM Objects o
   INNER JOIN ConXrefs cr ON cr.ID = o.ObjectID AND cr.TableID = 108 AND cr.RoleTypeID = 1
   INNER JOIN (SELECT DISTINCT ConXrefID, ConstituentID FROM ConXrefDetails) cd ON cd.ConXRefID = cr.ConXrefID
   LEFT JOIN Roles r ON r.RoleID = cr.RoleID
   INNER JOIN Constituents c ON c.ConstituentID = cd.ConstituentID
   LEFT JOIN TextEntries te ON te.ID = c.ConstituentID AND te.TextTypeID = 64
   LEFT JOIN AuthorityTranslations at ON (r.RoleID = at.ID AND at.TableID = 149)
ORDER BY cr.DisplayOrder;

-- VIEW Classifications

CREATE OR REPLACE VIEW vclassifications AS
SELECT o.ObjectID as _id, o.ObjectNumber, c.ClassificationID, c.Classification as classification_nl, at.Translation1 as classification_en, at.Translation2 as classification_fr FROM Objects o
  INNER JOIN ClassificationXRefs cr ON o.ObjectID = cr.ID
  INNER JOIN Classifications c ON c.ClassificationID = cr.ClassificationID
  LEFT JOIN AuthorityTranslations at ON (at.ID = c.ClassificationID AND at.TableID = 10)
ORDER BY cr.DisplayOrder;

-- VIEW Periods

CREATE OR REPLACE VIEW vperiods AS
SELECT ObjectID as _id,
    Period as term
FROM ObjContext;

-- VIEW Dimensions

CREATE OR REPLACE VIEW vdimensions AS
SELECT o.ObjectID as _id,
    d.Dimension as dimension,
    t.DimensionType as type,
    e.Element as element,
    u.UnitName as unit,
    x.DisplayDimensions as display
FROM Objects o
LEFT JOIN
    DimItemElemXrefs x ON x.ID = o.ObjectID
INNER JOIN
    Dimensions d ON d.DimItemElemXrefID = x.DimItemElemXrefID
INNER JOIN
    DimensionUnits u ON u.UnitID = d.PrimaryUnitID
INNER JOIN
    DimensionTypes t ON t.DimensionTypeID = d.DimensionTypeID
INNER JOIN
    DimensionElements e ON e.ElementID = x.ElementID
WHERE
    x.TableID = '108'
ORDER BY
    e.Element = 'Dagmaat' DESC,
    e.Element = 'Volledig' DESC;

-- VIEW Objects

CREATE OR REPLACE VIEW vobjects AS
SELECT DISTINCT o.ObjectID as _id,
    t.Term as object,
    t.TermID,
    x.DisplayOrder
FROM Terms t,
    Objects o,
    ThesXrefs x
WHERE
    x.ID = o.ObjectID AND
    x.TermID = t.TermID AND
    x.ThesXrefTypeID = 3 AND
    x.DisplayOrder = (SELECT MIN(DisplayOrder) FROM ThesXrefs AS r WHERE r.ID = o.ObjectID AND r.TermID = t.TermID AND r.ThesXrefTypeID = 3)
ORDER BY x.DisplayOrder;

-- VIEW Subjects

CREATE OR REPLACE VIEW vsubjects AS
SELECT DISTINCT o.ObjectID as _id,
    t.Term as subject,
    t.TermID,
    x.DisplayOrder
FROM Terms t,
    Objects o,
    ThesXrefs x
WHERE
    x.TermID = t.TermID AND
    x.ID = o.ObjectID AND
    x.ThesXrefTypeID = 30 AND
    x.DisplayOrder = (SELECT MIN(DisplayOrder) FROM ThesXrefs AS r WHERE r.ID = o.ObjectID AND r.TermID = t.TermID AND r.ThesXrefTypeID = 30)
ORDER BY x.DisplayOrder;

-- VIEW Materials

CREATE OR REPLACE VIEW vmaterials AS
SELECT DISTINCT o.ObjectID as _id,
    t.Term as material,
    t.TermID,
    x.DisplayOrder
FROM Terms t,
    Objects o,
    ThesXrefs x
WHERE
    x.TermID = t.TermID AND
    x.ID = o.ObjectID AND
    x.ThesXrefTypeID = 5 AND
    x.DisplayOrder = (SELECT MIN(DisplayOrder) FROM ThesXrefs AS r WHERE r.ID = o.ObjectID AND r.TermID = t.TermID AND r.ThesXrefTypeID = 5)
ORDER BY x.DisplayOrder;

-- VIEW Techniques

CREATE OR REPLACE VIEW vtechniques AS
SELECT DISTINCT o.ObjectID as _id,
    t.Term as technique,
    t.TermID,
    x.DisplayOrder
FROM Terms t,
    Objects o,
    ThesXrefs x
WHERE
    x.TermID = t.TermID AND
    x.ID = o.ObjectID AND
    x.ThesXrefTypeID = 6 AND
    x.DisplayOrder = (SELECT MIN(DisplayOrder) FROM ThesXrefs AS r WHERE r.ID = o.ObjectID AND r.TermID = t.TermID AND r.ThesXrefTypeID = 6)
ORDER BY x.DisplayOrder;

-- VIEW Data PIDS

CREATE OR REPLACE VIEW vdatapids AS
SELECT o.ObjectNumber as _id,
    ref.ID,
    ref.fieldValue as dataPid
FROM UserFieldXrefs ref
INNER JOIN
    Objects o ON o.ObjectID = ref.ID
WHERE userFieldID = '44';

-- VIEW Work PIDS

CREATE OR REPLACE VIEW vworkpids AS
SELECT o.ObjectNumber as _id,
    ref.ID,
    ref.fieldValue as workPid
FROM UserFieldXrefs ref
INNER JOIN
    Objects o ON o.ObjectID = ref.ID
WHERE userFieldID = '46';

-- VIEW Representation PIDS

CREATE OR REPLACE VIEW vrepresentationpids AS
SELECT o.ObjectNumber as _id,
    ref.ID,
    ref.fieldValue as representationPid
FROM UserFieldXrefs ref
INNER JOIN
    Objects o ON o.ObjectID = ref.ID
WHERE userFieldID = '48';

-- VIEW ObjTitles

CREATE OR REPLACE VIEW vobjtitles AS
SELECT obj.ObjectNumber as _id,
    tit.titleID as titleid,
    tit.Title as title,
    l.ISO369v1Code as language,
    tit.TitleTypeID as titletypeid,
    tit.Displayed as displayed,
    tit.Active as active
FROM
    Objects obj
LEFT JOIN
    (
        SELECT ObjTitles.ObjectID,
            ObjTitles.titleID,
            ObjTitles.Title,
            ObjTitles.LanguageID,
            ObjTitles.TitleTypeID,
            ObjTitles.Displayed,
            ObjTitles.Active,
            ObjTitles.DisplayOrder
        FROM
            (
                SELECT ObjTitles.ObjectID,
                    ObjTitles.LanguageID,
                    ObjTitles.TitleTypeID,
                    MIN(ObjTitles.DisplayOrder) as displayorder
                FROM
                    (
                        SELECT ObjectID,
                            LanguageID,
                            MIN(TitleTypeID) as TitleTypeID
                        FROM
                            ObjTitles
                        WHERE
                            (TitleTypeID = 1 OR TitleTypeID = 2) AND Displayed = 1 AND Active = 1
                        GROUP BY
                            ObjectID,
                            LanguageID
                    ) AS lowestttid
                INNER JOIN ObjTitles ON ObjTitles.ObjectID = lowestttid.ObjectID
                           AND ObjTitles.LanguageID = lowestttid.LanguageID
                           AND ObjTitles.TitleTypeID = lowestttid.TitleTypeID
                GROUP BY
                    ObjectID,
                    LanguageID
            ) AS lowest
        INNER JOIN
            ObjTitles ON ObjTitles.ObjectID = lowest.ObjectID
            AND ObjTitles.LanguageID = lowest.LanguageID
            AND ObjTitles.TitleTypeID = lowest.TitleTypeID
            AND ObjTitles.DisplayOrder = lowest.displayorder
    ) AS tit ON tit.ObjectID = obj.ObjectID
INNER JOIN
    DDLanguages l ON l.LanguageID = tit.LanguageID AND l.ISO369v1Code <> ''
ORDER BY tit.DisplayOrder;

-- VIEW Departments

CREATE OR REPLACE VIEW vdepartments AS
SELECT o.ObjectID as _id,
    d.DepartmentID,
    d.Department as department
FROM Objects o,
    Departments d
WHERE
    o.DepartmentID = d.DepartmentID;

-- VIEW Relations

CREATE OR REPLACE VIEW vrelations AS
SELECT *,
IF(beforeSlash LIKE '%-%', SUBSTRING(beforeSlash, 1, INSTR(beforeSlash, '-') - 1), beforeSlash) AS first,
IF(beforeSlash LIKE '%-%', SUBSTRING(beforeSlash, INSTR(beforeSlash, '-') + 1), 999999999) AS second,
IF(afterSlash LIKE '%-%', SUBSTRING(afterSlash, 1, INSTR(afterSlash, '-') - 1), afterSlash) AS third,
IF(afterSlash LIKE '%-%', SUBSTRING(afterSlash, INSTR(afterSlash, '-') + 1), 999999999) AS fourth
FROM
(
    SELECT *,
    IF(relatedObjectNumber LIKE '%/%', SUBSTRING(relatedObjectNumber, 1, INSTR(relatedObjectNumber, '/') - 1), relatedObjectNumber) AS beforeSlash,
    IF(relatedObjectNumber LIKE '%/%', SUBSTRING(relatedObjectNumber, INSTR(relatedObjectNumber, '/') + 1), 0) AS afterSlash
    FROM
    (
        (
        SELECT DISTINCT o.ObjectID as _id,
            obj.ObjectNumber as relatedObjectNumber,
            r.Relation2 as relationship,
            r.RelationshipID as relationshipID1,
            NULL as relationshipID2,
            n.AltNum as numbering,
            n.Description as descriptionNumbering
        FROM Objects o,
            Associations a
        INNER JOIN
            Relationships r ON r.RelationshipID = a.RelationshipID
        INNER JOIN
            Objects obj ON obj.ObjectID = a.ID2
        LEFT JOIN
            AltNums n ON n.ID = a.ID2 AND n.Description = 'paginanummer'
        WHERE
            o.ObjectID = a.ID1 AND r.RelationshipID <> 8
        )
        UNION
        (
        SELECT DISTINCT o.ObjectID as _id,
            obj.ObjectNumber as relatedObjectNumber,
            r.Relation1 as relationship,
            NULL as relationshipID1,
            r.RelationshipID as relationshipID2,
            n.AltNum as numbering,
            n.Description as descriptionNumbering
        FROM Objects o,
            Associations a
        INNER JOIN
            Relationships r ON r.RelationshipID = a.RelationshipID
        INNER JOIN
            Objects obj ON obj.ObjectID = a.ID1
        LEFT JOIN
            AltNums n ON n.ID = a.ID1 AND n.Description = 'paginanummer'
        WHERE
            o.ObjectID = a.ID2 AND r.RelationshipID <> 8
        )
    ) AS rel
) AS rel1
ORDER BY
-CAST(numbering AS UNSIGNED) DESC,
IF(first REGEXP '^[0-9].*$', LPAD(uf_get_first_digits(first), 30, 0), first),
CAST(uf_get_first_digits(second) AS UNSIGNED),
CAST(uf_get_first_digits(third) AS UNSIGNED),
IF(third LIKE '%(%', CAST(uf_get_first_digits(SUBSTRING_INDEX(third, '(', -1)) AS UNSIGNED), 1),
CAST(uf_get_first_digits(fourth) AS UNSIGNED),
relatedObjectNumber,
_id;

-- VIEW PageNumbers

CREATE OR REPLACE VIEW vpagenumbers AS
SELECT o.ObjectID as _id,
    a.AltNum as pageNumber
FROM Objects o,
    AltNums a
WHERE o.ObjectID = a.ID AND a.Description = 'paginanummer';

-- VIEW Locations

CREATE OR REPLACE VIEW vlocations AS
SELECT o.ObjectID as _id,
    l.Room as room_nl,
    at.Translation1 as room_en,
    at.Translation2 as room_fr
FROM Locations l
INNER JOIN
    ObjLocations ol ON l.LocationID = ol.LocationID
INNER JOIN
    ObjComponents oc ON ol.ObjLocationID = oc.CurrentObjLocID
INNER JOIN
    Objects o ON oc.ObjectID = o.ObjectID
LEFT JOIN
    AuthorityTranslations at ON (at.ID = l.LocationID AND at.TableID = 83)
WHERE
    l.Site = 'publieksruimte';

-- VIEW TextEntries

CREATE OR REPLACE VIEW vtextentries AS
SELECT o.ObjectID as _id,
    REPLACE(t.TextEntry, '\r', '') as textEntry,
    t.LanguageID as languageid,
    t.TextTypeID as textTypeID
FROM TextEntries t
INNER JOIN
    Objects o ON t.ID = o.ObjectID
WHERE
    t.Purpose = 'Update Collectie-Informatie' AND t.TextTypeID IN(107, 110, 113, 117) AND t.TextStatusID = 8;

-- VIEW Clusters

-- CREATE OR REPLACE VIEW vclusters AS
-- SELECT o.ObjectID as _id,
--     u.FieldValue as cluster
-- FROM UserFieldXrefs u
-- INNER JOIN
--     Objects o ON u.ID = o.ObjectID
-- Where
--     u.UserFieldID = 108;

-- VIEW Halls

-- CREATE OR REPLACE VIEW vhalls AS
-- SELECT o.ObjectID as _id,
--     u.FieldValue as hall
-- FROM UserFieldXrefs u
-- INNER JOIN
--     Objects o ON u.ID = o.ObjectID
-- Where
--     u.UserFieldID = 107;

-- VIEW Provenance

CREATE OR REPLACE VIEW vprovenance AS
SELECT ObjectID as _id,
    ObjectNumber as objectNumber,
    REPLACE(Provenance, '\r', '') as provenance
FROM Objects;

-- VIEW AAT

CREATE OR REPLACE VIEW vaat AS
SELECT DISTINCT o.ObjectID as _id,
    o.ObjectNumber as objectNumber,
    t.Term as term,
    c.CN as path,
    tx.DisplayOrder
FROM ThesXrefs tx
INNER JOIN
    Terms t ON tx.TermID = t.TermID
INNER JOIN
    Objects o ON tx.ID = o.ObjectID
INNER JOIN
    ClassificationNotations c on t.TermMasterID = c.TermMasterID
WHERE
    tx.TableID = '108' AND tx.ThesXrefTypeID = '39' AND
    tx.DisplayOrder = (SELECT MIN(DisplayOrder) FROM ThesXrefs AS r WHERE r.ID = o.ObjectID AND r.TermID = t.TermID AND r.TableID = '108' AND r.ThesXrefTypeID = '39')
ORDER BY tx.DisplayOrder;

-- VIEW Iconclass

CREATE OR REPLACE VIEW viconclass AS
SELECT DISTINCT o.ObjectID AS _id,
    o.ObjectNumber AS objectNumber,
    t.Term AS term,
    c.CN AS path,
    tx.DisplayOrder,
    tm.SourceTermID,
    tm.TermSource
FROM ThesXrefs AS tx
INNER JOIN
    Terms AS t ON tx.TermID = t.TermID
INNER JOIN
    Objects AS o ON tx.ID = o.ObjectID
INNER JOIN
    ClassificationNotations AS c ON t.TermMasterID = c.TermMasterID
INNER JOIN
    TermMasterThes AS tm ON t.TermMasterID = tm.TermMasterID
WHERE
    tx.TableID = '108' AND tx.ThesXrefTypeID = '35' AND
    tx.DisplayOrder = (SELECT MIN(DisplayOrder) FROM ThesXrefs AS r WHERE r.ID = o.ObjectID AND r.TermID = t.TermID AND r.TableID = '108' AND r.ThesXrefTypeID = '35')
ORDER BY tx.DisplayOrder;

-- VIEW LinkLibrary

CREATE OR REPLACE VIEW vlinklibrary AS
SELECT ObjectID as _id,
    ObjectNumber as objectNumber,
    UserNumber1 as link
FROM Objects
WHERE
    UserNumber1 <> '';

-- VIEW LinkArchive

CREATE OR REPLACE VIEW vlinkarchive AS
SELECT o.ObjectID as _id,
    o.ObjectNumber as objectNumber,
    mf.FileName as link
FROM MediaXrefs m
INNER JOIN
    Objects o ON m.ID = o.ObjectID
INNER JOIN
    MediaRenditions mr ON m.MediaMasterID = mr.MediaMasterID
INNER JOIN
    MediaFiles mf ON mr.RenditionID = mf.RenditionID
WHERE
    m.TableID = '108' AND mf.PathID = 23
ORDER BY m.DisplayOrder;

-- VIEW Acquisition

CREATE OR REPLACE VIEW vacquisition AS
SELECT o.ObjectID as _id,
    o.ObjectNumber as objectNumber,
    r.Role as role_nl,
    at.Translation1 as role_en,
    at.Translation2 as role_fr,
    con.DisplayName AS name,
    con.ConstituentID AS constituentID,
    cd.DisplayDate as date
FROM
    Objects o
INNER JOIN
    ConXrefs c ON o.ObjectID = c.ID
INNER JOIN
    Roles r ON r.RoleID = c.RoleID
INNER JOIN
    ConXrefDetails cd ON cd.ConXrefID = c.ConXrefID
LEFT OUTER JOIN
    Constituents con ON cd.ConstituentID = con.ConstituentID
LEFT JOIN
    AuthorityTranslations at ON (at.ID = r.RoleID AND at.TableID = 149)
WHERE
    c.RoleTypeID = 2 AND c.TableID = 108 AND c.Displayed = 1 AND cd.UnMasked = 1 AND r.Role IS NOT NULL AND con.DisplayName IS NOT NULL AND at.TableID = 149
ORDER BY
    c.DisplayOrder;

-- VIEW ObjectNames

CREATE OR REPLACE VIEW vobjectnames AS
SELECT o.ObjectID as _id,
    o.ObjectNumber as objectNumber,
    n.ObjectName as objectName,
    n.ObjectNameID as objectNameID,
    n.ObjectNameTypeID as objectNameTypeID
FROM ObjectNames n
INNER JOIN
    Objects o ON n.ObjectID = o.ObjectID
ORDER BY n.DisplayOrder;

-- VIEW Handling

CREATE OR REPLACE VIEW vhandling AS
SELECT o.ObjectID as _id,
    REPLACE(t.TextEntry, '\r', '') as textEntry,
    l.ISO369v1Code as language
FROM TextEntries t
INNER JOIN
    Objects o ON t.ID = o.ObjectID
INNER JOIN
    DDLanguages l ON l.LanguageID = t.LanguageID AND l.ISO369v1Code <> ''
WHERE
    t.TextTypeID = 116;

-- VIEW highlights

CREATE OR REPLACE VIEW vhighlights AS
SELECT o.ObjectID as _id
FROM Objects o
INNER JOIN StatusFlags f ON f.ObjectID = o.ObjectID
WHERE f.FlagID = 31;

-- VIEW collectionpresentation

CREATE OR REPLACE VIEW vcollectionpresentation AS
SELECT o.ObjectID as _id
FROM Objects o
INNER JOIN StatusFlags f ON f.ObjectID = o.ObjectID
WHERE f.FlagID = 50;

-- VIEW Translations

CREATE OR REPLACE VIEW vtranslations AS
SELECT o.ObjectID as _id,
    REPLACE(t.TextEntry, '\r', '') as textEntry,
    t.TextTypeID as textTypeID
FROM Objects o
INNER JOIN TextEntries t ON t.ID = o.ObjectID
WHERE t.TableID = 726 AND t.TextTypeID BETWEEN 118 AND 179
GROUP BY CONCAT(_id, textEntry, textTypeID);

-- VIEW Exhibitions

CREATE OR REPLACE VIEW vexhibitions AS
SELECT eo.ObjectID AS _id,
    eo.ExhibitionID AS exhibitionID,
    o.ObjectNumber AS objectNumber
FROM ExhObjXrefs AS eo
INNER JOIN Exhibitions AS e ON e.ExhibitionID = eo.ExhibitionID
INNER JOIN Objects AS o ON o.ObjectID = eo.ObjectID
WHERE e.ProjectNumber = 'Collectiepresentatie2022';

-- VIEW ExhibitionTexts

CREATE OR REPLACE VIEW vexhibitiontexts AS
SELECT e.ExhibitionID AS _id,
    et.Title AS title,
    te.Remarks AS name,
    te.TextEntry AS textEntry,
    tt.TextTypeID AS textTypeID,
    tt.TextType AS textType
FROM TextEntries AS te
INNER JOIN Exhibitions AS e ON e.ExhibitionID = te.ID
INNER JOIN ExhibitionTitles AS et ON et.ExhibitionTitleID = e.ExhibitionTitleID
INNER JOIN TextTypes AS tt ON tt.TextTypeID = te.TextTypeID
WHERE e.ProjectNumber = 'Collectiepresentatie2022' AND te.Remarks IS NOT NULL;
