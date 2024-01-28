DELIMITER $$

CREATE PROCEDURE convert_json_to_table(IN input_json TEXT)
BEGIN
    IF NOT JSON_VALID(input_json) OR JSON_TYPE(input_json) != 'OBJECT' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid JSON format', MYSQL_ERRNO = 333;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS json_keys_temp;
    CREATE TEMPORARY TABLE json_keys_temp (
        key_id INT AUTO_INCREMENT PRIMARY KEY, 
        json_key VARCHAR(255)
    );

    -- Populate the temp table with keys from the JSON input
    SET @counter = 0;
    REPEAT
        INSERT INTO json_keys_temp (json_key) 
        VALUES (JSON_UNQUOTE(JSON_EXTRACT(JSON_KEYS(input_json), CONCAT('$[', @counter, ']'))));
        SET @counter = @counter + 1;
    UNTIL @counter >= JSON_LENGTH(input_json)
    END REPEAT;

    -- Retrieve and display keys with their corresponding values
    SELECT 
        jk.json_key, 
        JSON_UNQUOTE(JSON_EXTRACT(input_json, CONCAT('$.', jk.json_key))) AS json_value
    FROM 
        json_keys_temp jk;
    
    DROP TEMPORARY TABLE IF EXISTS json_keys_temp;
END $$

DELIMITER ;
