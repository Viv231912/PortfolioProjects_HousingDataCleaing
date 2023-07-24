/*
	Cleaning Data 
*/


Select *
From PortfolioProject..NashvilleHousing

-- Change Sale Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address data, If is NULL

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
order by ParcelID

Select N.ParcelID, N.PropertyAddress, NA.ParcelID, NA.PropertyAddress, ISNULL(N.PropertyAddress, NA.PropertyAddress)
From PortfolioProject..NashvilleHousing N
JOIN PortfolioProject..NashvilleHousing NA
	on N.ParcelID = NA.ParcelID
	AND N.[UniqueID ] <> NA.[UniqueID ]
Where N.PropertyAddress is Null

Update N
SET PropertyAddress = ISNULL(N.PropertyAddress, NA.PropertyAddress)
From PortfolioProject..NashvilleHousing N
JOIN PortfolioProject..NashvilleHousing NA
	on N.ParcelID = NA.ParcelID
	AND N.[UniqueID ] <> NA.[UniqueID ]


-- Breaking Address into Individual Columns 

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))



--Owner Address
Select *
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)



-- Sold as VACANT
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2
--Where SoldAsVacant = 'Yes'

Select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant =
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End

--Remove Duplicates with CTE
WITH RowNumCTE AS (

Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


SELECT *
From PortfolioProject..NashvilleHousing

--Delete Unused Columns

SELECT *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
Drop Column SaleDate