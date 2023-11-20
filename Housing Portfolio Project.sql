/*
	Data Cleaning with SQL Queries
*/

SELECT
	*
FROM
	PortfolioProject..NashvilleHousing;

----------------------------------------------------------------
-- Change Datetime Format to Date Format
SELECT
	SaleDateConverted, CAST(SaleDate AS Date)
FROM
	PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS Date)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS Date);


-- Populate Property Address Data
SELECT
	*
FROM
	PortfolioProject..NashvilleHousing
WHERE
	PropertyAddress is null
ORDER BY
	ParcelID

------------------------------------------------------------------------------------
SELECT
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND
		a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null

	-- Updating the Null Property Address column with b.PropertyAddress data
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND
		a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null;

-----------------------------------------------------------------------------------------
-- Splitting Out Address into Individual Columns (Address, City, State)
SELECT
	PropertyAddress
FROM
	PortfolioProject..NashvilleHousing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM
	PortfolioProject..NashvilleHousing;

-- Update split tables to columns
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT
	*
FROM
	PortfolioProject..NashvilleHousing


-- Splitting OwnerAddress Column
SELECT
	OwnerAddress
FROM
	PortfolioProject..NashvilleHousing;

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), --NB: PARSENAME works from the back
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM
	PortfolioProject..NashvilleHousing

-- Update split OwnerAddress column
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing


-- Change Y to Yes and N to No in SoldAsVacant column
SELECT
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM
	PortfolioProject..NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	2

-- Updating Values
SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant =  'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM
	PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant =  'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Removing Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM
	PortfolioProject..NashvilleHousing
)
SELECT	-- DELETE to remove all duplicates
	*
FROM
	RowNumCTE
WHERE
	row_num > 1
ORDER BY PropertyAddress

--Delete unused columns
SELECT
	*
FROM
	PortfolioProject..NashvilleHousing

ALTER TABLE
	PortfolioProject..NashvilleHousing
DROP COLUMN
	OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE
	PortfolioProject..NashvilleHousing
DROP COLUMN
	SaleDate