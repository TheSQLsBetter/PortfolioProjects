--Cleaning Data in SQL Queries 
Select * 
From NashvilleHousingData




---------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT( Date, SaleDate)
From NashvilleHousingData

Update NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate )

ALTER TABLE NashvilleHousingData
add SaleDateConverted Date; 

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From NashvilleHousingData
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousingData a 
Join NashvilleHousingData b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousingData a 
Join NashvilleHousingData b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is null

--Used a Join to show use the relationship between ParcelID and Property Address to replace NULL values with the proper Address
---------------------------------------------------------------------


-- Breaking out Address into individual columns ( Address, City, State) 

Select PropertyAddress 
From NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING( PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) - 1) as Address
, SUBSTRING( PropertyAddress, CHARINDEX( ',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From NashvilleHousingData


ALTER TABLE NashvilleHousingData
add PropertySplitAddress nvarchar(255); 

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) - 1) 

ALTER TABLE NashvilleHousingData
add PropertySplitCity  nvarchar(255); 

Update NashvilleHousingData
SET PropertySplitCity= SUBSTRING( PropertyAddress, CHARINDEX( ',', PropertyAddress) + 1, LEN(PropertyAddress)) 

Select *
From NashvilleHousingData


Select OwnerAddress
From NashvilleHousingData

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHousingData


ALTER TABLE NashvilleHousingData
add OwnerSplitAddress nvarchar(255); 

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousingData
add OwnerSplitCity  nvarchar(255); 

Update NashvilleHousingData
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousingData
add OwnerSplitState nvarchar(255); 

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--Used SUBSTRING and PARSENAME to seperate out the Address values into more usuable data format
---------------------------------------------------------------------------------

--Change Y and N to 'Yes' and 'No' in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousingData
Group by SoldAsVacant
order by 2 

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Standardized the data inputs for the SoldAsVacant column
---------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

From NashvilleHousingData
--order by ParcelID
)
DELETE 
From RowNumCTE
Where row_num > 1 

--Removed duplicates using a CTE, ROW_Number, and PARTITION BY
-----------------------------------------------------------------

-- Delete Unused Columns

Select * 
From NashvilleHousingData

Alter Table NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousingData
DROP COLUMN SaleDate

--Deleted the redundant columns after making alterations