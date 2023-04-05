/*


CLEANING DATA IN SQL QUERIES


*/

SELECT * FROM ProjectPortfolio.dbo.Nashville_housing


---------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM ProjectPortfolio.dbo.Nashville_housing

UPDATE Nashville_housing
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE Nashville_housing
ADD SaleDateConverted Date;

UPDATE Nashville_housing
SET SaleDateConverted = CONVERT (Date, SaleDate)


----------------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM ProjectPortfolio.dbo.Nashville_housing
-- where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.Nashville_housing a
JOIN ProjectPortfolio.dbo.Nashville_housing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.Nashville_housing a
JOIN ProjectPortfolio.dbo.Nashville_housing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ]<>b.[UniqueID ]
  WHERE a.PropertyAddress is null


  ---------------------------------------------------------------------------------------

  -- Breaking out Address into Individual Column: (Address, City, State)

  SELECT PropertyAddress
  FROM ProjectPortfolio.dbo.Nashville_housing

  SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
  FROM ProjectPortfolio.dbo.Nashville_housing


ALTER TABLE Nashville_housing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_housing
ADD PropertySplitCity Nvarchar(225);

UPDATE Nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * 
FROM ProjectPortfolio.dbo.Nashville_housing;

-- NOW DOING THE ABOVE SAME THING FOR OWNER ADDRESS INSTEAD OF PROPERTY ADDRESS, (IN DIFFERENT WAY)

SELECT OwnerAddress
FROM ProjectPortfolio.dbo.Nashville_housing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM ProjectPortfolio.dbo.Nashville_housing

ALTER TABLE Nashville_housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE Nashville_housing
ADD OwnerSplitCity Nvarchar(225);

UPDATE Nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE Nashville_housing
ADD OwnerSplitState Nvarchar(225);

UPDATE Nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--SELECT * FROM ProjectPortfolio.dbo.Nashville_housing



---------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio.dbo.Nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
  CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM ProjectPortfolio.dbo.Nashville_housing

UPDATE Nashville_housing
SET SoldAsVacant =  CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------------------

--REMOVE DUPLICATION

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER ( 
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID
			 ) row_num
from ProjectPortfolio.dbo.Nashville_housing
--ORDER BY ParcelID
)
select *
FROM RowNumCTE
where row_num > 1
ORDER BY PropertyAddress

-----------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

SELECT * 
FROM ProjectPortfolio.dbo.Nashville_housing

ALTER TABLE ProjectPortfolio.dbo.Nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjectPortfolio.dbo.Nashville_housing
DROP COLUMN SaleDate