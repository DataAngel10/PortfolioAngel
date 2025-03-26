
	-- ** Data Cleaning in SQL queries ** --

Select *
from`nashville housing data`;


SELECT *
FROM `nashville housing data`
-- Where PropertyAddress is null
Order by ParcelID;



-- Identifying records with missing PropertyAddress by joining the table to itself
-- This query finds entries where PropertyAddress is NULL and attempts to retrieve 
-- The corresponding address from another row with the same ParcelID but a different UniqueID.

SELECT 
 a.ParcelID,
 a.PropertyAddress,
 b.ParcelID,
 b.PropertyAddress
FROM `nashville housing data` a
JOIN `nashville housing data` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE `nashville housing data` a
JOIN `nashville housing data` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;



-- ****Breaking out Address into Individual Columns (Address, City, State)**** -- 

Select PropertyAddress
From `nashville housing data`;


-- This query extracts the street and city from the PropertyAddress column --   

SELECT 
    PropertyAddress,
    -- Extract the street address (everything before the first comma)
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS PropertySplitAddress,  
    
    -- Extract the city (everything after the first comma)
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 2) AS PropertySplitCity  
FROM `nashville housing data`;



-- Add new columns to the dataset--

ALTER TABLE `nashville housing data`
Add PropertySplitAddress varchar(225);

Update `nashville housing data`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);


ALTER TABLE `nashville housing data`
Add PropertySplitCity varchar(225);

Update `nashville housing data`
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 2);


-- checking the result -- 
Select *
From `nashville housing data`;




-- **Owner Address** -- 

Select OwnerAddress
From `nashville housing data`;


-- Split in Street, City and State -- 

SELECT 
    -- Extract the street address (first part)
    SUBSTRING_INDEX(OwnerAddress, ',', 1),  
    
    -- Extract the city (second part)
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    
    -- Extract the state (third part)
    SUBSTRING_INDEX(OwnerAddress, ',', -1) 
FROM `nashville housing data`;



-- Adding new columns
ALTER TABLE `nashville housing data`
ADD COLUMN OwnerSplitAddress VARCHAR(225);

-- Updating OwnerSplitAddress with the street portion of the address
UPDATE `nashville housing data`
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);



-- Adding a new column for the city
ALTER TABLE `nashville housing data`
ADD COLUMN OwnerSplitCity VARCHAR(225);

-- Updating OwnerSplitCity with the city portion of the address
UPDATE `nashville housing data`
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);



-- Adding a new column for the state
ALTER TABLE `nashville housing data`
ADD COLUMN OwnerSplitState VARCHAR(225);

-- Updating OwnerSplitState with the state portion of the address
UPDATE `nashville housing data`
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

Select *
from `nashville housing data`;




-- *** Change Y and N to YES and NO on "Sold as Vacant" field *** -- 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From `nashville housing data`
Group by SoldAsVacant
order by 2;


SELECT
    CASE 
    
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM `nashville housing data`;


Update `nashville housing data`
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END; 
    
    
    
-- *** Remove Duplicates *** -- 
-- Uses a CTE to assign row numbers to potential duplicate records, enabling identification and retrieval of these duplicates --

WITH RowNumCTE AS(
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                ParcelID, 
                PropertyAddress, 
                SalePrice, 
                SaleDate, 
                LegalReference
				ORDER BY 
                UniqueID
        ) AS row_num
FROM `nashville housing data`
)
SELECT *
FROM RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress;




-- DELETE DUPLICATES -- 

DELETE FROM `nashville housing data`
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT 
            UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY 
                    ParcelID, 
                    PropertyAddress, 
                    SalePrice, 
                    SaleDate, 
                    LegalReference
                ORDER BY 
                    UniqueID
            ) AS row_num
        FROM `nashville housing data`
    ) AS RowNumCTE
    WHERE row_num > 1
);


-- *** Delete Unused Columns***  -- 

Select *
From `nashville housing data`; 

ALTER TABLE `nashville housing data`
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE `nashville housing data`
DROP COLUMN  SaleDate; 




