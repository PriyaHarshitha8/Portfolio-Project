---* Cleaning data using SQL *---

select * from [Portfolio Project 2]..NashvilleHousing

--1. Standardizing date format

SELECT SaleDate from [Portfolio Project 2]..NashvilleHousing

	--adding a new column
ALTER TABLE [Portfolio Project 2]..NashvilleHousing
ADD SaleDate2 date;

	--updating the column with values
UPDATE [Portfolio Project 2]..NashvilleHousing
SET SaleDate2=CONVERT(date,SaleDate)

SELECT * from [Portfolio Project 2]..NashvilleHousing

 --Removing the original saledate column

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
DROP COLUMN SaleDate 

--2.Populate Property address data

SELECT * from [Portfolio Project 2]..NashvilleHousing
WHERE PropertyAddress is null

	--using parcel id to full null values(If parcelID is same to a null and a not null address - not null addresss can be used)
SELECT * from [Portfolio Project 2]..NashvilleHousing
order by 2

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project 2]..NashvilleHousing a 
join [Portfolio Project 2]..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

	--updating the property address column
update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project 2]..NashvilleHousing a 
join [Portfolio Project 2]..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]


SELECT * from [Portfolio Project 2]..NashvilleHousing
where PropertyAddress is null

--3. Breaking address columns into Individual Columns(Address,City,State)

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 
from [Portfolio Project 2]..NashvilleHousing

	--updating values
ALTER TABLE [Portfolio Project 2]..NashvilleHousing
ADD Address nvarchar(255)

UPDATE [Portfolio Project 2]..NashvilleHousing
SET Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
ADD City nvarchar(255)

UPDATE [Portfolio Project 2]..NashvilleHousing
SET City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT * from [Portfolio Project 2]..NashvilleHousing

-- 4.Breaking Owneraddress columns into Individual Columns(Address,City,State)

SELECT OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from [Portfolio Project 2]..NashvilleHousing

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
ADD AddressofOwner nvarchar(255)

UPDATE [Portfolio Project 2]..NashvilleHousing
SET AddressofOwner=PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
ADD OwnerCity nvarchar(255)

UPDATE [Portfolio Project 2]..NashvilleHousing
SET OwnerCity=PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE [Portfolio Project 2]..NashvilleHousing
SET OwnerState=PARSENAME(replace(OwnerAddress,',','.'),1)



SELECT * from [Portfolio Project 2]..NashvilleHousing

--Change Y,N to Yes,No in SoldAsVaccant

SELECT DISTINCT SoldAsVacant from [Portfolio Project 2]..NashvilleHousing
 

SELECT SoldAsVacant,
CASE SoldASVacant
WHEN 'Y' THEN 'Yes'
WHEN 'N' THEN 'No'
WHEN 'Yes' THEN 'Yes'
ELSE 'No'
END 
from [Portfolio Project 2]..NashvilleHousing

UPDATE [Portfolio Project 2]..NashvilleHousing
SET SoldAsVacant=
CASE SoldASVacant
WHEN 'Y' THEN 'Yes'
WHEN 'N' THEN 'No'
ELSE SoldAsVacant
END 
from [Portfolio Project 2]..NashvilleHousing


--5.Removing Duplicates

SELECT *,ROW_NUMBER() OVER 
		(PARTITION BY ParcelID,
		PropertyAddress,SalePrice,SaleDate,LegalReference
		ORDER BY UniqueId) row_num
from [Portfolio Project 2]..NashvilleHousing

	--finding rows with row_num >1

WITH RowNumCTE AS (
SELECT *,ROW_NUMBER() OVER 
		(PARTITION BY ParcelID,
		PropertyAddress,SalePrice,SaleDate2,LegalReference
		ORDER BY UniqueId) row_num
from [Portfolio Project 2]..NashvilleHousing)

SELECT * FROM RowNumCTE
WHERE row_num>1
order by ParcelID



DELETE FROM RowNumCTE
WHERE row_num>1






