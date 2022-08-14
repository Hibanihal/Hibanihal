/** CLEANING DATA USING SQL QUERIES **/

SELECT * 
FROM portfolio..nashville;



--Converting SaleDate to standard Date:

ALTER TABLE portfolio..nashville
Alter COLUMN Saledate date;



--Populate property address data:

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio..nashville AS a
JOIN portfolio..nashville AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio..nashville AS a
JOIN portfolio..nashville AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;



--Breaking out Address to individual Columns (Address, City, State)
--Splitting Property Address:

SELECT PropertyAddress
FROM portfolio..nashville;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Propertyaddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS propertystate 
FROM portfolio..nashville;

ALTER TABLE portfolio..nashville
ADD PropertyLocation Nvarchar(250);

UPDATE portfolio..nashville
SET PropertyLocation = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE portfolio..nashville
ADD PropertyCity Nvarchar(250);

UPDATE portfolio..nashville
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

ALTER TABLE portfolio..nashville
DROP COLUMN PropertyAddress;



--Splitting Owner Address:

SELECT OwnerAddress
FROM portfolio..nashville;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
FROM portfolio..nashville;

ALTER TABLE portfolio..nashville
ADD OwnerLocation Nvarchar(250);

UPDATE portfolio..nashville
SET OwnerLocation = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3);

ALTER TABLE portfolio..nashville
ADD OwnerCity Nvarchar(250);

UPDATE portfolio..nashville
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2);

ALTER TABLE portfolio..nashville
ADD OwnerState Nvarchar(250);

UPDATE portfolio..nashville
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1);

ALTER TABLE portfolio..nashville
DROP COLUMN OwnerAddress;



-- Change y and n to Yes and No in SoldAsVacant field:

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM portfolio..nashville
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
     WHEN SoldAsVacant = 'n' THEN 'No'
	 ELSE SoldAsVacant END
FROM portfolio..nashville;

UPDATE portfolio..nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
						WHEN SoldAsVacant = 'n' THEN 'No'
						ELSE SoldAsVacant END



--Removing duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 PropertyLocation,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Portfolio..nashville
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyLocation;

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 PropertyLocation,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Portfolio..nashville
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



--Deleting Unwanted/Unused columns:

ALTER TABLE Portfolio..nashville
DROP COLUMN TaxDistrict, SaleDate;

