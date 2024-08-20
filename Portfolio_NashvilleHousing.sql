-- The whole Table ordered by the ID

Select *
From Portfolio_Project_Data_Cleaning..NashvilleHousing
order by 1


-- Standartize Date Format / No Timestamp

Select SaleDate, CONVERT(Date, SaleDate)
From Portfolio_Project_Data_Cleaning..NashvilleHousing

--- By Updating the Table 

UPDATE NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

--- Or altering the Table by adding a new Column

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From Portfolio_Project_Data_Cleaning..NashvilleHousing

-------------------------------------------------------------
-- populate Property Adress Data 
--- Find out if there are NULL cells
Select *
From Portfolio_Project_Data_Cleaning..NashvilleHousing
Where PropertyAddress is null

Select *
From Portfolio_Project_Data_Cleaning..NashvilleHousing
Order by ParcelID

--- Join the Table with itself / Where the ParcelID is the same but not the UniqueID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From Portfolio_Project_Data_Cleaning..NashvilleHousing a
JOIN Portfolio_Project_Data_Cleaning..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--- populate the PropertyAddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project_Data_Cleaning..NashvilleHousing a
JOIN Portfolio_Project_Data_Cleaning..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

---- Update the PropertyAddress
UPDATE a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project_Data_Cleaning..NashvilleHousing a
JOIN Portfolio_Project_Data_Cleaning..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------------
-- Breaking out the Address into individual Columns ( Address, City, State )
--- PropertyAddress
Select PropertyAddress
From Portfolio_Project_Data_Cleaning..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
From Portfolio_Project_Data_Cleaning..NashvilleHousing

--- Updating the Table by adding two new Columns

ALTER TABLE Portfolio_Project_Data_Cleaning..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Portfolio_Project_Data_Cleaning..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE Portfolio_Project_Data_Cleaning..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity
From Portfolio_Project_Data_Cleaning..NashvilleHousing

--- Same for the OwnerAddress
Select
SUBSTRING(OwnerAddress, 1 , CHARINDEX(',', OwnerAddress) -1) AS Address,
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) +1, LEN(OwnerAddress)) AS City
From Portfolio_Project_Data_Cleaning..NashvilleHousing

---Part 1 Split Address 
ALTER TABLE Portfolio_Project_Data_Cleaning..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio_Project_Data_Cleaning..NashvilleHousing
Set OwnerSplitAddress = SUBSTRING(OwnerAddress, 1 , CHARINDEX(',', OwnerAddress) -1)

ALTER TABLE Portfolio_Project_Data_Cleaning..NashvilleHousing
ADD OwnerSplitTemp Nvarchar(255);

UPDATE Portfolio_Project_Data_Cleaning..NashvilleHousing
Set OwnerSplitTemp = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) +1, LEN(OwnerAddress))

Select OwnerSplitAddress, OwnerSplitTemp
From Portfolio_Project_Data_Cleaning..NashvilleHousing

--- Part 2 Split City and State

ALTER TABLE Portfolio_Project_Data_Cleaning..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Portfolio_Project_Data_Cleaning..NashvilleHousing
Set OwnerSplitCity = SUBSTRING(OwnerSplitTemp, 1 , CHARINDEX(',', OwnerSplitTemp) -1)

ALTER TABLE Portfolio_Project_Data_Cleaning..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE Portfolio_Project_Data_Cleaning..NashvilleHousing
Set OwnerSplitState = SUBSTRING(OwnerSplitTemp, CHARINDEX(',', OwnerSplitTemp) +1, LEN(OwnerSplitTemp))

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState 
From Portfolio_Project_Data_Cleaning..NashvilleHousing

--- Part 3 Drop the temporary Column

Alter Table Portfolio_Project_Data_Cleaning..NashvilleHousing
DROP COLUMN OwnerSplitTemp;

Select *
From Portfolio_Project_Data_Cleaning..NashvilleHousing

--- Alternative Way of Breaking the Address into Columns

Select 
PARSENAME(Replace(OwnerAddress, ',','.'),3) as OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',','.'),2) as OwnerCity,
PARSENAME(Replace(OwnerAddress, ',','.'),1) as OwnerState
From Portfolio_Project_Data_Cleaning..NashvilleHousing


----------------------------------------------------------------
-- Standardize the SoldAsVacant Column (Y and N -> Yes and No)

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project_Data_Cleaning..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant, 
	Case When SoldAsVacant = 'N' THEN 'No'
		 When SoldAsVacant = 'Y' THEN 'Yes'
		 Else SoldAsVacant
		 End
From Portfolio_Project_Data_Cleaning..NashvilleHousing
Where SoldAsVacant = 'N'
	or SoldAsVacant = 'Y'

Update Portfolio_Project_Data_Cleaning..NashvilleHousing
Set SoldAsVacant = 
	Case When SoldAsVacant = 'N' THEN 'No'
		 When SoldAsVacant = 'Y' THEN 'Yes'
		 Else SoldAsVacant
		 End

-------------------------------------------------------------------
-- Remove Duplicates

--- Creating a Query for all the Duplicates

Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From Portfolio_Project_Data_Cleaning..NashvilleHousing
order by ParcelID

--- Create a CTE for better Clarity
With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From Portfolio_Project_Data_Cleaning..NashvilleHousing
)
Select * 
FROM RowNumCTE
Where row_num > 1
order by [UniqueID ]

--- Delete Duplicates

With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From Portfolio_Project_Data_Cleaning..NashvilleHousing
)
Delete 
FROM RowNumCTE
Where row_num > 1

----------------------------------------------------------------
-- Delete Unused Columns for Userfriendly Experience

ALTER TABLE Portfolio_Project_Data_Cleaning..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE Portfolio_Project_Data_Cleaning..NashvilleHousing
DROP COLUMN SaleDate

Select*
From Portfolio_Project_Data_Cleaning..NashvilleHousing