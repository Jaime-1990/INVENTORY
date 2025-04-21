-- TALLER: INVENTARIO
 SELECT
 * 
 FROM 
 cc_user.PARTS 
 LIMIT 
 10;
-- Mejorando seguimiento de piezas
-- Query 1
-- Modifica la columna `code`para que cada valor insertado en este campo sea único y no esté vacío.  

ALTER TABLE cc_user.parts
ADD UNIQUE (CODE);
ALTER TABLE cc_user.parts
ALTER COLUMN CODE 
SET NOT NULL;

SELECT * FROM cc_user.parts

-- Query 2
-- Modifica la tabla para que todas las filas tengan un valor en `description`
UPDATE cc_user.parts
SET description = 'GENERIC'
WHERE 
description = ' ';

ALTER TABLE cc_user.parts
ALTER COLUMN description
SET NOT NULL

--Query 3
--añade una restricción que asegure que todos los valores en `description` estén llenos y no sean vacíos. 
 INSERT INTO
 cc_user.parts (ID, description, code);
 VALUES
 (1019, 'GENERIC B', 'V901'),
 (1059, 'GENERIC B', 'V1001');
 
--Query 4:
 SELECT * FROM cc_user.parts WHERE description IS NULL;

 ALTER TABLE cc_user.parts
 ALTER COLUMN description
 SET NOT NULL;

-- 1. Evitar que se ingresen valores NULL en la columna "code"
  ALTER TABLE cc_user.parts
  ALTER COLUMN code
  SET NOT NULL;

-- 2. Asegurar que cada código sea único en la tabla
 ALTER TABLE cc_user.parts
 ADD CONSTRAINT unique_code UNIQUE (code);

-- 3. Evitar que el campo "code" esté vacío o lleno de espacios
 ALTER TABLE cc_user.parts
 ADD CONSTRAINT chk_code_not_empty
 CHECK (length(trim(code)) > 0);

 SELECT column_name, is_nullable
 FROM information_schema.columns
 WHERE table_schema = 'cc_user'
   AND table_name = 'parts'
   AND column_name = 'code';
-- 
 SELECT conname, pg_get_constraintdef(oid) AS constraint_definition
 FROM pg_constraint
 WHERE conrelid = 'cc_user.parts'::regclass
   AND contype = 'c';  -- 'c' = check

 ALTER TABLE cc_user.parts
 ADD CONSTRAINT chk_description_not_empty
 CHECK (length(trim(description)) > 0);

 SELECT id, description
 FROM cc_user.parts
 WHERE trim(description) = '';

 UPDATE cc_user.parts
 SET description = 'GENERIC'
 WHERE trim(description) = '';

-- 4 no se puede ingresar valor sin una descripcion.
 INSERT INTO cc_user.parts (id, code)
 VALUES (2001, 'X123');
 insertar valor:
 INSERT INTO cc_user.parts (id, code, description)
 VALUES (2003, 'X125', 'Pieza Nueva');

--  MEJORANDO LAS OPCIONES DE REORDENAMIENTO

-- consultemos lo que hay en la tabla reordanamiento de opciones
SELECT * FROM cc_user.reorder_options;

 verificar NOT NULL a price_usd y quantity
 ALTER TABLE cc_user.reorder_options
 ALTER COLUMN price_usd SET NOT NULL,
 ALTER COLUMN quantity SET NOT NULL;

 QUANTITY >=0
 ALTER TABLE cc_user.reorder_options
 ADD CONSTRAINT chk_price_positive
 CHECK (price_usd > 0);

--Asegurarse que no hallan productos duplicados
 ALTER TABLE cc_user.reorder_options
 ADD CONSTRAINT unique_part_supplier
 UNIQUE (part_id, manufacturer_id);

--prueba:
 SELECT column_name 
 FROM information_schema.columns 
 WHERE table_name = 'reorder_options' AND table_schema = 'cc_user';

--prueba
 SELECT conname, pg_get_constraintdef(oid)
 FROM pg_constraint
 WHERE conrelid = 'cc_user.reorder_options'::regclass;

--asegurar datos que no los violen
 SELECT * FROM cc_user.reorder_options WHERE price_usd <= 0 OR quantity < 0;

-- Implementemos una verificación que asegure que `price_usd` y `quantity` sean valores positivos.
 ALTER TABLE cc_user.reorder_options
 ADD CONSTRAINT chk_price_and_quantity_positive 
 CHECK (price_usd > 0 AND quantity >= 0);

-- restricions separadas:
 ALTER TABLE cc_user.reorder_options
 ADD CONSTRAINT chk_price_positive 
 CHECK (price_usd > 0);

 ALTER TABLE cc_user.reorder_options
 ADD CONSTRAINT chk_quantity_non_negative 
 CHECK (quantity >= 0);


-- --probar que los valores sean positivos
 SELECT conname, pg_get_constraintdef(oid)
 FROM pg_constraint
 WHERE conrelid = 'cc_user.reorder_options'::regclass;

--3. verificar el precio entre 0.02 y 25.00 USD:
 ALTER TABLE cc_user.reorder_options
 ADD CONSTRAINT chk_unit_price_range
 CHECK ((price_usd / quantity) BETWEEN 0.02 AND 25.00);

 SELECT *
 FROM cc_user.reorder_options
 WHERE (price_usd / quantity) < 0.02 OR (price_usd / quantity) > 25.00;

-- --4 crear una relacion parts y reorder_options
--prueba:
 SELECT ro.*
 FROM cc_user.reorder_options ro
 LEFT JOIN cc_user.parts p ON ro.part_id = p.id
 WHERE p.id IS NULL;

-- consulta: RESTRICCION  DE CLAVE foránea

 ALTER TABLE cc_user.reorder_options
 ADD CONSTRAINT fk_part_id
 FOREIGN KEY (part_id)
 REFERENCES cc_user.parts(id);

SELECT conname, pg_get_constraintdef(oid)
 FROM pg_constraint
 WHERE conrelid = 'cc_user.parts'::regclass AND contype = 'p';

--Agregamos clave primaria:

 ALTER TABLE cc_user.parts
 ADD CONSTRAINT pk_parts_id
 PRIMARY KEY (id);

--Agregamos clave foranea:

 ALTER TABLE cc_user.reorder_options
 ADD CONSTRAINT fk_part_id
 FOREIGN KEY (part_id)
 REFERENCES cc_user.parts(id);

--MEJORANDO EL SEGUIMIENTO DE UBICACIOONES--
-- 1:
--valor en qty que sea mayor que 0
 ALTER TABLE cc_user.locations
 ADD CONSTRAINT chk_qty_positive
 CHECK (qty > 0);

--probar que funciona: con un valor nulo
 INSERT INTO cc_user.locations (id, part_id, qty)
 VALUES (999, 1019, 0);

-- 2:Asegurémonos de que locations registre solo una fila por cada combinación de location y part. Esto facilitará el acceso a la información sobre una ubicación o pieza
 ALTER TABLE cc_user.locations
 ADD CONSTRAINT unique_location_part
 UNIQUE (location, part_id);

-- creamos una de prueba
 INSERT INTO cc_user.locations (id, location, part_id, qty)
 VALUES (888, 'A1', 1019, 10);

--preba
 INSERT INTO cc_user.locations (id, location, part_id, qty)
 VALUES (889, 'A1', 1019, 5);