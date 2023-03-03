/*
Data Cleaning in SQL Queries
*/

---------------------------------------------------------------------------------------
-- Standerizing Sale Date Column by inserting new column

Select SaleDate /*CONVERT(DATE, SaleDate)*/
FROM NashvilleHousing

Alter Table NashvilleHousing
ADD SaleDateCorrected Date;

Update NashvilleHousing
Set SaleDateCorrected = CONVERT(Date,SaleDate)

Select * 
From NashvilleHousing

---------------------------------------------------------------------------------------
-- Populate Property Address Data as we have NULL values in data set.

Select *
From NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing as a
Join NashvilleHousing as b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
--WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing as a
Join NashvilleHousing as b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL
---------------------------------------------------------------------------------------

-- Breaking Down Address Column into Individual Columns (Address,City,State)

Select PropertyAddress
From NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as SplitCity
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


-- Owner address Column:


Select OwnerAddress
From NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(Replace(OwnerAddress,',','.'),2) As City ,
PARSENAME(Replace(OwnerAddress,',','.'),1) As State
From PortfolioProject1..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.') , 2 )

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

----------------------------------------------------------------------------------------------
 
 
--Change Y and N to yes and No in "Sold as Vacant" Column.


Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From NashvilleHousing
---------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE
AS(
Select *, 
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order By UniqueID
	) r0w_num
From NashvilleHousing
--Order By ParcelID

)

--Delete
Select *
From RowNumCTE
Where r0w_num >1

--------------------------------------------------------------
--Deleting Unnecessary Columns
Alter Table NashvilleHousing
Drop Column OWnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate

Select * 
From NashvilleHousing