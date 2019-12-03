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

DELIMITER ;

-- CITvgsrpObjTombstoneD_RO

CALL sp_DropIndex ('CITvgsrpObjTombstoneD_RO', 'ObjectID');
ALTER TABLE `CITvgsrpObjTombstoneD_RO` ADD INDEX `ObjectID` ( `ObjectID` );
CALL sp_DropIndex ('CITvgsrpObjTombstoneD_RO', 'ClassificationID');
ALTER TABLE `CITvgsrpObjTombstoneD_RO` ADD INDEX `ClassificationID` ( `ClassificationID` );

-- ObjTitles

ALTER TABLE `ObjTitles` CHANGE `ObjectID` `ObjectID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ObjTitles` CHANGE `DisplayOrder` `DisplayOrder` INT NULL DEFAULT NULL;
CALL sp_DropIndex ('ObjTitles', 'ObjectID');
ALTER TABLE `ObjTitles` ADD INDEX `ObjectID` ( `ObjectID` );

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
CALL sp_DropIndex ('ConXrefDetails', 'ConXrefDetailID');
ALTER TABLE `ConXrefDetails` ADD INDEX `ConXrefDetailID` ( `ConXrefDetailID`, `ConXrefID`, `RoleTypeID`, `ConstituentID` );

-- ConXrefs

ALTER TABLE `ConXrefs` CHANGE `ConXrefID` `ConXrefID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `RoleID` `RoleID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `RoleTypeID` `RoleTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `TableID` `TableID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ConXrefs` CHANGE `DisplayOrder` `DisplayOrder` INT NULL DEFAULT NULL;
CALL sp_DropIndex ('ConXrefs', 'ConXrefID');
ALTER TABLE `ConXrefs` ADD INDEX `ConXrefID` ( `ConXrefID`, `RoleID`, `RoleTypeID`, `TableID` );

-- ObjContext (ObjectID)

ALTER TABLE `ObjContext` CHANGE `Period` `Period` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ObjContext', 'ObjectID');
ALTER TABLE `ObjContext` ADD INDEX `ObjectID` ( `ObjectID` , `Period` );

-- Objects

CALL sp_DropIndex ('Objects', 'ObjectID');
ALTER TABLE `Objects` CHANGE `ObjectID` `ObjectID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Objects` CHANGE `ObjectNumber` `ObjectNumber` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Objects` ADD INDEX `ObjectID` ( `ObjectID` , `ObjectNumber` );

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
ALTER TABLE `DimItemElemXrefs` ADD INDEX `DimItemElemXrefID` ( `DimItemElemXrefID` , `TableID` , `ID` , `ElementID` );

-- Terms

ALTER TABLE `Terms` CHANGE `TermID` `TermID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `Terms` CHANGE `TermTypeID` `TermTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('Terms', 'TermID');
ALTER TABLE `Terms` ADD INDEX `TermID` ( `TermID` , `TermTypeID` );

-- ThesXrefs

ALTER TABLE `ThesXrefs` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ThesXrefs` CHANGE `TermID` `TermID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `ThesXrefs` CHANGE `ThesXrefTypeID` `ThesXrefTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ThesXrefs', 'ID');
ALTER TABLE `ThesXrefs` ADD INDEX `ID` ( `ID` , `TermID` , `ThesXrefTypeID` );

-- ThesXrefTypes

ALTER TABLE `ThesXrefTypes` CHANGE `ThesXrefTypeID` `ThesXrefTypeID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('ThesXrefTypes', 'ThesXrefTypeID');
ALTER TABLE `ThesXrefTypes` ADD INDEX `ThesXrefTypeID` ( `ThesXrefTypeID` );

-- UserFieldXrefs

ALTER TABLE `UserFieldXrefs` CHANGE `UserFieldID` `UserFieldID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `UserFieldXrefs` CHANGE `ID` `ID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `UserFieldXrefs` CHANGE `ContextID` `ContextID` VARCHAR( 255 ) NULL DEFAULT NULL;
ALTER TABLE `UserFieldXrefs` CHANGE `LoginID` `LoginID` VARCHAR( 255 ) NULL DEFAULT NULL;
CALL sp_DropIndex ('UserFieldXrefs', 'UserFieldID');
ALTER TABLE `UserFieldXrefs` ADD INDEX `UserFieldID` ( `UserFieldID`, `ID`, `ContextID`, `LoginID` );

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

--
-- VIEWS

-- VIEW Constituents 

CREATE OR REPLACE VIEW vconstituents AS
SELECT o.ObjectID as _id, o.ObjectNumber, c.ConstituentID, c.AlphaSort, c.DisplayName, c.BeginDate, c.EndDate, c.BeginDateISO, c.EndDateISO, r.Role, cr.DisplayOrder, te.TextEntry as copyright FROM Objects o
   INNER JOIN ConXrefs cr ON cr.ID = o.ObjectID AND cr.TableID = 108 AND cr.RoleTypeID = 1
   INNER JOIN (SELECT DISTINCT ConXrefID, ConstituentID FROM ConXrefDetails) cd ON cd.ConXRefID = cr.ConXrefID
   LEFT JOIN Roles r ON r.RoleID = cr.RoleID
   INNER JOIN Constituents c ON c.ConstituentID = cd.ConstituentID
   LEFT JOIN TextEntries te ON te.ID = c.ConstituentID AND te.TextTypeID = 64
ORDER BY cr.DisplayOrder;

-- VIEW Classifications

CREATE OR REPLACE VIEW vclassifications AS
SELECT o.ObjectID as _id, o.ObjectNumber, c.ClassificationID, c.Classification FROM Objects o
  INNER JOIN ClassificationXRefs cr ON o.ObjectID = cr.ID
  INNER JOIN Classifications c ON c.ClassificationID = cr.ClassificationID;

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
FROM CITvgsrpObjTombstoneD_RO o
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
    x.TableID = '108';

-- VIEW Objects

CREATE OR REPLACE VIEW vobjects AS
SELECT o.ObjectID as _id,
    t.Term as object,
    t.TermID
FROM Terms t, 
    CITvgsrpObjTombstoneD_RO o,
    ThesXrefs x,
    ThesXrefTypes y
WHERE
    x.TermID = t.TermID AND
    x.ID = o.ObjectID AND
    x.ThesXrefTypeID = y.ThesXrefTypeID AND
    y.ThesXrefTypeID = 3;

-- VIEW Subjects

CREATE OR REPLACE VIEW vsubjects AS
SELECT o.ObjectID as _id,
    t.Term as subject,
    t.TermID
FROM Terms t, 
    CITvgsrpObjTombstoneD_RO o,
    ThesXrefs x,
    ThesXrefTypes y
WHERE
    x.TermID = t.TermID AND
    x.ID = o.ObjectID AND
    x.ThesXrefTypeID = y.ThesXrefTypeID AND
    y.ThesXrefTypeID = 30;

-- VIEW Materials

CREATE OR REPLACE VIEW vmaterials AS
SELECT o.ObjectID as _id,
    t.Term as material,
    t.TermID
FROM Terms t, 
    CITvgsrpObjTombstoneD_RO o,
    ThesXrefs x,
    ThesXrefTypes y
WHERE
    x.TermID = t.TermID AND
    x.ID = o.ObjectID AND
    x.ThesXrefTypeID = y.ThesXrefTypeID AND
    y.ThesXrefTypeID = 5;

-- VIEW Data PIDS

CREATE OR REPLACE VIEW vdatapids AS
SELECT o.ObjectNumber as _id, 
    ref.ID, 
    ref.fieldValue as dataPid
FROM UserFieldXrefs ref
INNER JOIN 
    CITvgsrpObjTombstoneD_RO o ON o.ObjectID = ref.ID
WHERE userFieldID = '44';

-- VIEW Work PIDS

CREATE OR REPLACE VIEW vworkpids AS
SELECT o.ObjectNumber as _id, 
    ref.ID, 
    ref.fieldValue as workPid
FROM UserFieldXrefs ref
INNER JOIN 
    CITvgsrpObjTombstoneD_RO o ON o.ObjectID = ref.ID
WHERE userFieldID = '46';

-- VIEW Representation PIDS

CREATE OR REPLACE VIEW vrepresentationpids AS
SELECT o.ObjectNumber as _id, 
    ref.ID, 
    ref.fieldValue as representationPid
FROM UserFieldXrefs ref
INNER JOIN 
    CITvgsrpObjTombstoneD_RO o ON o.ObjectID = ref.ID
WHERE userFieldID = '48';

-- VIEW ObjTitles

CREATE OR REPLACE VIEW vobjtitles AS
SELECT obj.ObjectNumber as _id, 
    tit.titleID as titleid,
    tit.Title as title,
    tit.LanguageID as languageid
FROM
    Objects obj
LEFT JOIN
    (
        SELECT ObjTitles.ObjectID,
            ObjTitles.titleID,
            ObjTitles.Title,
            ObjTitles.LanguageID
        FROM
            (
                SELECT ObjectID,
                    LanguageID,
                    MIN(DisplayOrder) as displayorder
                FROM
                    ObjTitles
                GROUP BY
                    ObjectID,
                    LanguageID
            ) AS lowest
        INNER JOIN
            ObjTitles ON ObjTitles.ObjectID = lowest.ObjectID
            AND ObjTitles.LanguageID = lowest.LanguageID
            AND ObjTitles.DisplayOrder = lowest.displayorder
    ) AS tit ON tit.ObjectID = obj.ObjectID;

-- VIEW Descriptions

CREATE OR REPLACE VIEW vdescriptions AS
SELECT o.ObjectID as _id,
    d.Chat as description
FROM CITvgsrpObjTombstoneD_RO o,
    Objects d
WHERE
    d.ObjectID = o.ObjectID;

-- VIEW Departments

CREATE OR REPLACE VIEW vdepartments AS
SELECT o.ObjectID as _id,
    d.DepartmentID,
    d.Department as department
FROM CITvgsrpObjTombstoneD_RO o,
    Departments d
WHERE
    o.DepartmentID = d.DepartmentID;

-- VIEW Iconclass

CREATE OR REPLACE VIEW viconclass AS
SELECT o.ObjectID as _id,
    obj.Notes as iconclass
FROM CITvgsrpObjTombstoneD_RO o,
    Objects obj
WHERE
    obj.ObjectID = o.ObjectID;

-- VIEW Relations

CREATE OR REPLACE VIEW vrelations AS
(
SELECT DISTINCT o.ObjectID as _id,
    obj.ObjectNumber as relatedObjectNumber,
    r.Relation2 as relationship,
    r.RelationshipID as relationshipID1,
    NULL as relationshipID2,
    n.AltNum as numbering,
    n.Description as descriptionNumbering
FROM CITvgsrpObjTombstoneD_RO o,
    Associations a
INNER JOIN
    Relationships r ON r.RelationshipID = a.RelationshipID
INNER JOIN
    CITvgsrpObjTombstoneD_RO obj ON obj.ObjectID = a.ID2
INNER JOIN
    AltNums n ON n.ID = a.ID2
WHERE
    o.ObjectID = a.ID1
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
FROM CITvgsrpObjTombstoneD_RO o,
    Associations a
INNER JOIN
    Relationships r ON r.RelationshipID = a.RelationshipID
INNER JOIN
    CITvgsrpObjTombstoneD_RO obj ON obj.ObjectID = a.ID1
INNER JOIN
    AltNums n ON n.ID = a.ID1
WHERE
    o.ObjectID = a.ID2
);
